$ErrorActionPreference = 'Stop'

Write-Host '=== Satva Dhara ERP / Phase 1 Setup ===' -ForegroundColor Green

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host 'Flutter command was not found in PATH.' -ForegroundColor Yellow
    Write-Host 'Install Flutter and add its bin folder to PATH, then run this script again.'
    exit 1
}

Write-Host 'Creating native platform folders...' -ForegroundColor Cyan
flutter create .

Write-Host 'Getting packages...' -ForegroundColor Cyan
flutter pub get

Write-Host 'Running analyzer...' -ForegroundColor Cyan
flutter analyze

Write-Host 'Running tests...' -ForegroundColor Cyan
flutter test

Write-Host ''
Write-Host 'Phase 1 source is ready.' -ForegroundColor Green
Write-Host 'Next backend step: run flutterfire configure after the Firebase project is created.'
Write-Host 'Then run: flutter run -d windows'
