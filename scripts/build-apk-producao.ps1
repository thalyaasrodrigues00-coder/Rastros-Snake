param(
  [Parameter(Mandatory = $true)]
  [string]$ServerUrl
)

$ServerUrl = $ServerUrl.TrimEnd('/')

Write-Host "Build APK producao -> $ServerUrl"

Set-Location $PSScriptRoot\..

flutter build apk --release --dart-define=SERVER_URL=$ServerUrl

Copy-Item -Force `
  "build\app\outputs\flutter-apk\app-release.apk" `
  "web_download\RastrosSnake.apk"

Write-Host "OK: web_download\RastrosSnake.apk"
