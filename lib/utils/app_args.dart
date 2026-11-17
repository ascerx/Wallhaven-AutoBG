import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Command-line arguments of the running app.
///
/// Flutter desktop apps don't receive argv in `main()`, so we read it
/// ourselves: `kernel32!GetCommandLineW` on Windows and
/// `/proc/self/cmdline` on Linux.
List<String> commandLineArgs() {
  try {
    if (Platform.isWindows) {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final getCommandLineW = kernel32.lookupFunction<
          Pointer<Uint16> Function(),
          Pointer<Uint16> Function()>('GetCommandLineW');
      final full = getCommandLineW().cast<Utf16>().toDartString();
      final tokens = RegExp('([^\\s"]+|"([^"]*)")').allMatches(full);
      final args = <String>[];
      for (final match in tokens) {
        final token = match.group(0)!;
        args.add(
          token.startsWith('"')
              ? token.substring(1, token.length - 1)
              : token,
        );
      }
      return args.skip(1).toList(); // Skip the executable path.
    }
    if (Platform.isLinux) {
      final bytes = File('/proc/self/cmdline').readAsBytesSync();
      final parts = utf8
          .decode(bytes, allowMalformed: true)
          .split('\x00')
          .where((s) => s.isNotEmpty)
          .toList();
      return parts.skip(1).toList();
    }
  } on Exception {
    // Fall through to empty args.
  }
  return const [];
}

/// True when the app should start hidden in the system tray.
bool shouldStartHidden() => commandLineArgs().contains('--hidden');
