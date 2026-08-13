# Como colocar o download no seu site

## Arquivos necessários

Envie estes dois arquivos para a hospedagem do seu site (mesma pasta):

1. `index.html` — página de download (ou copie só o botão)
2. `rastros-snake-release.apk` — o APK gerado pelo build

## Link direto do APK

Se o site já tiver uma página, use apenas o link do arquivo:

```html
<a href="https://SEU-SITE.com/rastros-snake-release.apk" download>
  Baixar Rastros Snake (Android)
</a>
```

## Página completa

Faça upload da pasta `web_download/` inteira ou renomeie `index.html` para a URL desejada (ex.: `/download`).

## Atualizar versão

1. Rode `flutter build apk --release`
2. Copie `build/app/outputs/flutter-apk/app-release.apk` para `web_download/rastros-snake-release.apk`
3. Atualize a versão no `index.html` se mudou
