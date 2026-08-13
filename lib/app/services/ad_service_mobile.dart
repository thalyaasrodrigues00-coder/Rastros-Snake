import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/api_keys.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (!isSupported) return;

    await MobileAds.instance.initialize();

    if (!ApiKeys.useTestAds) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: []),
      );
    }

    loadAppOpenAd();
    loadInterstitialAd();
  }

  void loadAppOpenAd() {
    if (!isSupported) return;
    final adUnitId = Platform.isAndroid ? ApiKeys.androidAppOpenAdId : ApiKeys.iosAppOpenAdId;
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenAd!.show();
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  void loadInterstitialAd() {
    if (!isSupported) return;
    final adUnitId = Platform.isAndroid ? ApiKeys.androidInterstitialAdId : ApiKeys.iosInterstitialAdId;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void showInterstitialAd() {
    if (!isSupported) return;
    final ad = _interstitialAd;
    if (ad != null) {
      _interstitialAd = null;
      ad.show();
    }
  }

  void incrementGameOverAndShowAd() {
    showInterstitialAd();
  }

  BannerAd buildBannerAd({VoidCallback? onLoaded, void Function(LoadAdError)? onFailed}) {
    final adUnitId = Platform.isAndroid ? ApiKeys.androidBannerAdId : ApiKeys.iosBannerAdId;
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed?.call(error);
        },
      ),
    )..load();
  }
}
