import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'wallpaper_service.dart';

/// Sets the desktop wallpaper on Windows through the `IDesktopWallpaper` COM
/// interface (Windows 8+): instant, per-monitor aware and without restarting
/// the shell.
///
/// The COM object is instantiated manually through `dart:ffi`
/// (`CoCreateInstance` + vtable call) so no extra packages are needed.
/// GUIDs come from the Windows SDK (`shobjidl_core.h`):
///   CLSID_DesktopWallpaper = C2CF3110-460E-4FC1-B9D0-8A1C0C9CC4BD
///   IID_IDesktopWallpaper  = B92B56A9-8B55-4E14-9A89-0199BBB6F93B
///
/// If COM fails for any reason we fall back to the legacy
/// `SystemParametersInfoW(SPI_SETDESKWALLPAPER)` path.
class WindowsWallpaperService implements WallpaperService {
  static const String _clsidDesktopWallpaper =
      'C2CF3110-460E-4FC1-B9D0-8A1C0C9CC4BD';
  static const String _iidIDesktopWallpaper =
      'B92B56A9-8B55-4E14-9A89-0199BBB6F93B';

  static const int _clsctxServer = 5; // INPROC_SERVER | LOCAL_SERVER
  static const int _coinitApartmentThreaded = 2;
  static const int _rpcEChangedMode = -2147417850; // 0x80010106

  // IDesktopWallpaper vtable slots (0-2 are IUnknown).
  static const int _vtableSetWallpaper = 3;
  static const int _vtableRelease = 2;
  static const int _vtableSetPosition = 10;

  // DESKTOP_WALLPAPER_POSITION
  static const int _positionCenter = 0;
  static const int _positionTile = 1;
  static const int _positionStretch = 2;
  static const int _positionFit = 3;
  static const int _positionFill = 4;

  bool _comInitialized = false;

  @override
  Future<void> setWallpaper(String filePath, WallpaperFit fit) async {
    try {
      _applyViaDesktopWallpaper(filePath, fit);
      return;
    } on WallpaperException {
      // Fall through to the legacy API.
    } on Exception {
      // COM unavailable: fall through.
    }
    _applyLegacySpi(filePath);
  }

  void _applyViaDesktopWallpaper(String filePath, WallpaperFit fit) {
    final ole32 = DynamicLibrary.open('ole32.dll');

    final coInitializeEx = ole32
        .lookupFunction<Int32 Function(Pointer<Void>, Uint32),
            int Function(Pointer<Void>, int)>('CoInitializeEx');
    final coUninitialize = ole32
        .lookupFunction<Void Function(), void Function()>('CoUninitialize');
    final coCreateInstance = ole32.lookupFunction<
        Int32 Function(Pointer<Uint8>, Pointer<Void>, Uint32, Pointer<Uint8>,
            Pointer<Pointer<Void>>),
        int Function(Pointer<Uint8>, Pointer<Void>, int, Pointer<Uint8>,
            Pointer<Pointer<Void>>)>('CoCreateInstance');

    if (!_comInitialized) {
      final hr = coInitializeEx(nullptr, _coinitApartmentThreaded);
      // 0 = S_OK, 1 = S_FALSE (already initialized), both fine.
      // RPC_E_CHANGED_MODE means COM is already up in another mode: fine too.
      if (hr == 0 || hr == 1 || hr == _rpcEChangedMode) {
        _comInitialized = true;
      }
    }

    final clsid = _guidBytes(_clsidDesktopWallpaper);
    final iid = _guidBytes(_iidIDesktopWallpaper);
    final ppv = calloc<Pointer<Void>>();
    try {
      final hr = coCreateInstance(
          clsid, nullptr, _clsctxServer, iid, ppv);
      if (hr != 0) {
        throw WallpaperException(
          'CoCreateInstance(IDesktopWallpaper) failed '
          '(0x${hr.toRadixString(16)}).',
        );
      }

      final object = ppv.value;
      // The first field of a COM object is the pointer to its vtable.
      final vtable = object.cast<Pointer<Void>>().value.cast<Pointer<Void>>();

      // HRESULT SetPosition(DESKTOP_WALLPAPER_POSITION) - slot 10.
      final setPosition = vtable[_vtableSetPosition]
          .cast<NativeFunction<Int32 Function(Pointer, Uint32)>>()
          .asFunction<int Function(Pointer, int)>();
      setPosition(object, _positionFromFit(fit));

      // HRESULT SetWallpaper(LPCWSTR monitorId, LPCWSTR wallpaper) - slot 3.
      // monitorId = NULL applies to every monitor.
      final setWallpaper = vtable[_vtableSetWallpaper]
          .cast<
              NativeFunction<
                  Int32 Function(
                      Pointer, Pointer<Uint16>, Pointer<Uint16>)>>()
          .asFunction<int Function(Pointer, Pointer<Uint16>, Pointer<Uint16>)>();
      final pathPtr = filePath.toNativeUtf16().cast<Uint16>();
      try {
        final hrSet = setWallpaper(object, nullptr, pathPtr);
        if (hrSet != 0) {
          throw WallpaperException(
            'IDesktopWallpaper::SetWallpaper failed '
            '(0x${hrSet.toRadixString(16)}).',
          );
        }
      } finally {
        malloc.free(pathPtr);
      }

      // IUnknown::Release - slot 2.
      final release = vtable[_vtableRelease]
          .cast<NativeFunction<Uint32 Function(Pointer)>>()
          .asFunction<int Function(Pointer)>();
      release(object);
    } finally {
      calloc.free(ppv);
      calloc.free(clsid);
      calloc.free(iid);
      if (_comInitialized) coUninitialize();
    }
  }

  int _positionFromFit(WallpaperFit fit) => switch (fit) {
        WallpaperFit.fill => _positionFill,
        WallpaperFit.stretch => _positionStretch,
        WallpaperFit.fit => _positionFit,
        WallpaperFit.center => _positionCenter,
        WallpaperFit.tile => _positionTile,
      };

  /// Parses "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" into the 16-byte binary
  /// layout COM expects (Data1/Data2/Data3 little-endian, Data4 verbatim).
  Pointer<Uint8> _guidBytes(String guid) {
    final hex = guid.replaceAll('-', '');
    final bytes = calloc<Uint8>(16);
    int readHex(int offset) =>
        int.parse(hex.substring(offset, offset + 2), radix: 16);

    // Data1: 4 bytes, little-endian.
    for (var i = 0; i < 4; i++) {
      bytes[i] = readHex((3 - i) * 2);
    }
    // Data2, Data3: 2 bytes each, little-endian.
    for (var i = 0; i < 2; i++) {
      bytes[4 + i] = readHex(8 + (1 - i) * 2);
      bytes[6 + i] = readHex(12 + (1 - i) * 2);
    }
    // Data4: 8 bytes, verbatim.
    for (var i = 0; i < 8; i++) {
      bytes[8 + i] = readHex(16 + i * 2);
    }
    return bytes;
  }

  /// Legacy fallback for older Windows where the COM interface may be
  /// unavailable: `user32!SystemParametersInfoW(SPI_SETDESKWALLPAPER)`.
  void _applyLegacySpi(String filePath) {
    const int spiSetDeskWallpaper = 0x0015;
    const int spifUpdateIniFile = 0x01;
    const int spifSendChange = 0x02;

    final user32 = DynamicLibrary.open('user32.dll');
    final systemParametersInfoW = user32.lookupFunction<
        Int32 Function(Uint32, Uint32, Pointer<Uint16>, Uint32),
        int Function(
            int, int, Pointer<Uint16>, int)>('SystemParametersInfoW');

    final pathPtr = filePath.toNativeUtf16().cast<Uint16>();
    try {
      final result = systemParametersInfoW(
        spiSetDeskWallpaper,
        0,
        pathPtr,
        spifUpdateIniFile | spifSendChange,
      );
      if (result == 0) {
        throw WallpaperException(
          'SystemParametersInfoW(SPI_SETDESKWALLPAPER) failed.',
        );
      }
    } finally {
      malloc.free(pathPtr);
    }
  }
}
