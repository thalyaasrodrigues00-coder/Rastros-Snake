class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static bool get isSupported => false;

  Future<void> init() async {}

  void loadAppOpenAd() {}

  void loadInterstitialAd() {}

  void showInterstitialAd() {}

  void incrementGameOverAndShowAd() {}

  Object? buildBannerAd({void Function()? onLoaded, void Function(Object)? onFailed}) => null;
}
