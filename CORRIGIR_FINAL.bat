@echo off
echo ==========================================
echo  CORRECAO FINAL - SDK ^3.9.0
echo ==========================================
echo.

cd /d "%~dp0"

echo [1/5] Matando processos...
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul
taskkill /F /IM dart.exe 2>nul
echo OK
echo.

echo [2/5] Criando pubspec.yaml CORRETO...
(
echo name: curtume_apontamento_remolho
echo description: Sistema de Apontamento de Producao para Curtume
echo publish_to: 'none'
echo version: 1.0.0+1
echo.
echo environment:
echo   sdk: '^3.9.0'
echo.
echo dependencies:
echo   flutter:
echo     sdk: flutter
echo   flutter_localizations:
echo     sdk: flutter
echo   intl: ^0.20.2
echo.
echo dev_dependencies:
echo   flutter_test:
echo     sdk: flutter
echo   flutter_lints: ^3.0.0
echo.
echo flutter:
echo   uses-material-design: true
echo.
echo   assets:
echo     - assets/images/logo_atak.png
) > pubspec.yaml
echo OK - Criado com sdk: ^3.9.0
echo.

echo [3/5] Limpando tudo...
flutter clean >nul 2>&1
if exist pubspec.lock del /F /Q pubspec.lock
if exist build rmdir /S /Q build 2>nul
if exist .dart_tool rmdir /S /Q .dart_tool 2>nul
echo OK
echo.

echo [4/5] Instalando dependencias...
flutter pub get
echo.

echo [5/5] PRONTO!
echo ==========================================
echo  SUCESSO!
echo ==========================================
echo.
echo Agora execute:
echo   flutter run -d windows
echo.
pause
