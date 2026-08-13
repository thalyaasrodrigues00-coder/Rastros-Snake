import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdFooter extends StatefulWidget {
  const BannerAdFooter({super.key});

  @override
  State<BannerAdFooter> createState() => _BannerAdFooterState();
}

class _BannerAdFooterState extends State<BannerAdFooter> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService.isSupported) {
      _bannerAd = AdService().buildBannerAd(
        onLoaded: () {
          if (mounted) setState(() => _isLoaded = true);
        },
      ) as BannerAd?;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.isSupported || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
