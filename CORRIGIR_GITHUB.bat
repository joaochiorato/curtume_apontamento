@echo off
cls
echo ==========================================
echo  CORRECAO PROJETO GITHUB - DEFINITIVA
echo ==========================================
echo.
echo Repositorio: curtume_apontamento_final
echo.
echo Problemas identificados:
echo [1] SDK: ^3.9.0 (incompativel com 3.9.2)
echo [2] theme.dart linha 33: CardTheme (erro)
echo [3] intl: precisa ser ^0.20.2
echo.
echo Solucoes:
echo [1] SDK: '>=3.0.0 <4.0.0' (flexivel)
echo [2] CardThemeData (correto)
echo [3] intl: ^0.20.2
echo.
pause

cd /d "%~dp0"

echo.
echo [1/7] Matando processos...
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul >nul
taskkill /F /IM dart.exe 2>nul >nul
echo OK
echo.

echo [2/7] Deletando EXE bloqueado...
del /F /Q "..\build\windows\x64\runner\Debug\curtume_apontamento_remolho.exe" 2>nul
echo OK
echo.

echo [3/7] Copiando pubspec.yaml corrigido...
copy /Y pubspec.yaml ..\ >nul
echo OK - SDK: '>=3.0.0 <4.0.0'
echo.

echo [4/7] Copiando lib/theme.dart corrigido...
if not exist ..\lib mkdir ..\lib
copy /Y theme.dart ..\lib\ >nul
echo OK - CardThemeData (linha 33)
echo.

echo [5/7] Limpando cache...
cd ..
flutter clean >nul 2>&1
if exist pubspec.lock del /F /Q pubspec.lock 2>nul
if exist build rmdir /S /Q build 2>nul
if exist .dart_tool rmdir /S /Q .dart_tool 2>nul
echo OK
echo.

echo [6/7] Instalando dependencias...
echo.
flutter pub get
echo.

if %errorlevel% neq 0 (
    echo.
    echo ERRO! Verifique a saida acima.
    pause
    exit /b 1
)

echo [7/7] Verificando...
flutter doctor
echo.

echo ==========================================
echo  SUCESSO! PROJETO CORRIGIDO!
echo ==========================================
echo.
echo Arquivos corrigidos:
echo [OK] pubspec.yaml - SDK flexivel
echo [OK] pubspec.yaml - intl ^0.20.2
echo [OK] lib/theme.dart - CardThemeData
echo.
echo Agora execute:
echo   flutter run -d windows
echo.
echo Se der erro de EXE bloqueado,
echo execute este script novamente!
echo.
pause
