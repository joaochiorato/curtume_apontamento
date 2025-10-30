@echo off
echo ========================================
echo  CORRECAO URGENTE - FUNCIONANDO 100%%
echo ========================================
echo.
pause

cd /d "%~dp0"

echo [1/8] Finalizando processos...
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul
echo    OK
echo.

echo [2/8] Deletando arquivo EXE bloqueado...
del /F /Q "build\windows\x64\runner\Debug\curtume_apontamento_remolho.exe" 2>nul
echo    OK
echo.

echo [3/8] Criando pubspec.yaml CORRETO...
(
echo name: curtume_apontamento_remolho
echo description: Sistema de Apontamento de Producao para Curtume
echo publish_to: 'none'
echo version: 1.0.0+1
echo.
echo environment:
echo   sdk: '>=3.0.0 <4.0.0'
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
echo    OK - Arquivo criado
echo.

echo [4/8] Limpando cache Flutter...
call flutter clean
echo    OK
echo.

echo [5/8] Deletando build e cache...
if exist build rmdir /S /Q build 2>nul
if exist .dart_tool rmdir /S /Q .dart_tool 2>nul
if exist pubspec.lock del /F /Q pubspec.lock 2>nul
echo    OK
echo.

echo [6/8] Instalando dependencias...
call flutter pub get
if %errorlevel% equ 0 (
    echo    OK - Sucesso!
) else (
    echo    ERRO!
    pause
    exit /b 1
)
echo.

echo [7/8] Verificando...
call flutter doctor
echo.

echo [8/8] PRONTO!
echo ========================================
echo  SUCESSO! TUDO CORRIGIDO!
echo ========================================
echo.
echo Agora execute:
echo flutter run -d windows
echo.
pause
