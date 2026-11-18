import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/ads.dart';

/// AdMob banner shown at the bottom of screens on Android.
///
/// Compliance note: ads are hidden while NSFW content can be displayed
/// ([nsfwActive]) — AdMob policies forbid ads alongside sexually explicit
/// material. Uses Google's test ad unit until the real IDs are configured
/// (see `lib/config/ads.dart`).
class AdBanner extends StatefulWidget {
  const AdBanner({super.key, this.nsfwActive = false});

  final bool nsfwActive;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _ready = false;
  bool _failed = false;

  bool get _supported => Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    if (_supported && !widget.nsfwActive) {
      _load();
    }
  }

  @override
  void didUpdateWidget(AdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when NSFW turns off (it was hidden before).
    if (_supported && oldWidget.nsfwActive && !widget.nsfwActive) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      await MobileAds.instance.initialize();
      final banner = BannerAd(
        adUnitId: admobBannerUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _banner = ad as BannerAd;
                _ready = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) setState(() => _failed = true);
          },
        ),
      );
      await banner.load();
      if (!mounted) {
        banner.dispose();
      } else {
        setState(() => _banner = banner);
      }
    } on Exception {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported || widget.nsfwActive || _failed) {
      return const SizedBox.shrink();
    }
    if (!_ready || _banner == null) {
      return const SizedBox(height: 60);
    }
    return SizedBox(
      height: _banner!.size.height.toDouble(),
      width: double.infinity,
      child: AdWidget(ad: _banner!),
    );
  }
}
