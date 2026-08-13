import 'dart:convert';

class ApiKeys {
  /// `false` = anúncios reais (produção). `true` = IDs de teste Google.
  static const bool useTestAds = false;

  static String _decrypt(String encoded, int key) {
    if (encoded.isEmpty) return '';
    final List<int> bytes = base64.decode(encoded);
    final List<int> result = [];
    for (int i = 0; i < bytes.length; i++) {
      result.add(bytes[i] ^ key);
    }
    return utf8.decode(result);
  }

  static String _fromEnv(String key, String raw, int xorKey) {
    final env = String.fromEnvironment(key);
    if (env.isNotEmpty) return env;
    if (raw.startsWith('ca-app-pub-')) return raw;
    if (raw.isEmpty) return '';
    return _decrypt(raw, xorKey);
  }

  /// Gera string ofuscada (XOR + Base64) para colar em [_raw*].
  static String obfuscate(String plain, int key) {
    return base64.encode(utf8.encode(plain).map((b) => b ^ key).toList());
  }

  static bool get isGeminiConfigured {
    final key = geminiApiKey.trim();
    if (key.isEmpty) return false;
    if (key.contains('SUA_CHAVE')) return false;
    if (key.contains('GEMINI_AQUI')) return false;
    return key.length >= 20;
  }

  // === GEMINI (XOR 0x5A) ===
  static const String _rawGeminiKey = 'CQ8bBRkSGwwfBRsKEwUdHxcTFBMFGwsPEw==';
  static String get geminiApiKey =>
      _fromEnv('GEMINI_API_KEY', _rawGeminiKey, 0x5A);

  // === ADMOB APP IDs (XOR 0x3C) — usados no AndroidManifest / Info.plist ===
  static const String _rawAndroidAdMobAppId = '';
  static const String _rawIosAdMobAppId = '';

  static const String _rawTestAndroidAdMobAppId =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwUOCQsPBQkFDg0=';
  static const String _rawTestIosAdMobAppId =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwkKDw4IDwkNDg4=';

  static String get androidAdMobAppId {
    if (useTestAds) {
      return _fromEnv('ADMOB_ANDROID_APP_ID', _rawTestAndroidAdMobAppId, 0x3C);
    }
    final env = String.fromEnvironment('ADMOB_ANDROID_APP_ID');
    if (env.isNotEmpty) return env;
    if (_rawAndroidAdMobAppId.isNotEmpty) {
      return _decrypt(_rawAndroidAdMobAppId, 0x3C);
    }
    return _fromEnv('ADMOB_ANDROID_APP_ID', _rawTestAndroidAdMobAppId, 0x3C);
  }

  static String get iosAdMobAppId {
    if (useTestAds) {
      return _fromEnv('ADMOB_IOS_APP_ID', _rawTestIosAdMobAppId, 0x3C);
    }
    final env = String.fromEnvironment('ADMOB_IOS_APP_ID');
    if (env.isNotEmpty) return env;
    if (_rawIosAdMobAppId.isNotEmpty) {
      return _decrypt(_rawIosAdMobAppId, 0x3C);
    }
    return _fromEnv('ADMOB_IOS_APP_ID', _rawTestIosAdMobAppId, 0x3C);
  }

  // === ADMOB ANDROID — PRODUÇÃO (XOR 0x3C) ===
  static const String _rawAndroidAppOpen = 'ca-app-pub-6054757399473825/4767374384';
  static const String _rawAndroidBanner = 'ca-app-pub-6054757399473825/3932538938';
  static const String _rawAndroidInterstitial = 'ca-app-pub-6054757399473825/6754143394';

  // === ADMOB ANDROID — TESTE ===
  static const String _rawTestAndroidAppOpen =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwUOCQsPBQkFDg0=';
  static const String _rawTestAndroidBanner =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwoPDAwFCwQNDQ0=';
  static const String _rawTestAndroidInterstitial =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEw0MDw8NCw8LDQ4=';

  static String get androidAppOpenAdId => useTestAds
      ? _fromEnv('ADMOB_ANDROID_APP_OPEN', _rawTestAndroidAppOpen, 0x3C)
      : _fromEnv('ADMOB_ANDROID_APP_OPEN', _rawAndroidAppOpen, 0x3C);

  static String get androidBannerAdId => useTestAds
      ? _fromEnv('ADMOB_ANDROID_BANNER', _rawTestAndroidBanner, 0x3C)
      : _fromEnv('ADMOB_ANDROID_BANNER', _rawAndroidBanner, 0x3C);

  static String get androidInterstitialAdId => useTestAds
      ? _fromEnv('ADMOB_ANDROID_INTERSTITIAL', _rawTestAndroidInterstitial, 0x3C)
      : _fromEnv('ADMOB_ANDROID_INTERSTITIAL', _rawAndroidInterstitial, 0x3C);

  // === ADMOB IOS — PRODUÇÃO (XOR 0x3C) ===
  static const String _rawIosAppOpen = 'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwkKDw4IDwkNDg4=';
  static const String _rawIosBanner = 'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEw4FDwgLDwkLDQo=';
  static const String _rawIosInterstitial = 'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwgIDQ0ICgQFDQw=';

  // === ADMOB IOS — TESTE ===
  static const String _rawTestIosAppOpen =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwkKDw4IDwkNDg4=';
  static const String _rawTestIosBanner =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEw4FDwgLDwkLDQo=';
  static const String _rawTestIosInterstitial =
      'X10RXUxMEUxJXhEPBQgMDgkKDAUFBQgOCQgIEwgIDQ0ICgQFDQw=';

  static String get iosAppOpenAdId => useTestAds
      ? _fromEnv('ADMOB_IOS_APP_OPEN', _rawTestIosAppOpen, 0x3C)
      : _fromEnv('ADMOB_IOS_APP_OPEN', _rawIosAppOpen, 0x3C);

  static String get iosBannerAdId => useTestAds
      ? _fromEnv('ADMOB_IOS_BANNER', _rawTestIosBanner, 0x3C)
      : _fromEnv('ADMOB_IOS_BANNER', _rawIosBanner, 0x3C);

  static String get iosInterstitialAdId => useTestAds
      ? _fromEnv('ADMOB_IOS_INTERSTITIAL', _rawTestIosInterstitial, 0x3C)
      : _fromEnv('ADMOB_IOS_INTERSTITIAL', _rawIosInterstitial, 0x3C);
}
