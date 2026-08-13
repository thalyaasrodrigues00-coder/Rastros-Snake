# AdMob — Anúncios reais (produção)

## 1. Android App ID (`local.properties`)

Edite `android/local.properties` e adicione:

```properties
admob.android.app.id=ca-app-pub-SEU_PUBLISHER~SEU_APP_ANDROID
```

> Obtenha em [AdMob](https://admob.google.com) → Apps → Rastros Snake → App settings

## 2. iOS App ID (`Info.plist`)

Edite `ios/Runner/Info.plist` → `GADApplicationIdentifier`:

```xml
<string>ca-app-pub-SEU_PUBLISHER~SEU_APP_IOS</string>
```

## 3. IDs dos blocos (banner, interstitial, app open)

Ofusque cada ID:

```bash
dart run tool/obfuscate_key.dart "ca-app-pub-xxx/banner" ad
```

Cole o resultado em `lib/app/constants/api_keys.dart` nos campos `_rawAndroidBanner`, etc.

## 4. Gemini

Ofusque a chave API:

```bash
dart run tool/obfuscate_key.dart "AIzaSy..." gemini
```

Cole em `_rawGeminiKey` em `api_keys.dart`.

Ou use build com variável:

```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=AIzaSy...
```

## 5. Modo produção

Em `api_keys.dart`: `useTestAds = false` (já ativo).

Build release:

```bash
flutter build apk --release
```
