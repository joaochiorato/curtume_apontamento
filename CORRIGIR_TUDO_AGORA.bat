@echo off
echo ==========================================
echo  CORRECAO COMPLETA - PUBSPEC + THEME
echo ==========================================
echo.
echo Vai corrigir:
echo [1] pubspec.yaml - SDK e intl
echo [2] lib/theme.dart - CardTheme erro
echo.
pause

cd /d "%~dp0"

echo [1/6] Matando processos...
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul
taskkill /F /IM dart.exe 2>nul
echo OK
echo.

echo [2/6] Corrigindo pubspec.yaml...
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
echo OK - pubspec.yaml criado
echo.

echo [3/6] Corrigindo lib/theme.dart...
if not exist lib mkdir lib
(
echo import 'package:flutter/material.dart';
echo.
echo ThemeData buildTheme^(^) {
echo   return ThemeData^(
echo     useMaterial3: true,
echo     colorScheme: ColorScheme.fromSeed^(
echo       seedColor: const Color^(0xFF546E7A^),
echo       brightness: Brightness.light,
echo     ^),
echo     appBarTheme: const AppBarTheme^(
echo       backgroundColor: Color^(0xFF37474F^),
echo       foregroundColor: Colors.white,
echo       elevation: 0,
echo       centerTitle: false,
echo     ^),
echo     inputDecorationTheme: InputDecorationTheme^(
echo       filled: true,
echo       fillColor: const Color^(0xFFF5F5F5^),
echo       border: OutlineInputBorder^(
echo         borderRadius: BorderRadius.circular^(8^),
echo         borderSide: const BorderSide^(color: Color^(0xFFE0E0E0^)^),
echo       ^),
echo       enabledBorder: OutlineInputBorder^(
echo         borderRadius: BorderRadius.circular^(8^),
echo         borderSide: const BorderSide^(color: Color^(0xFFE0E0E0^)^),
echo       ^),
echo       focusedBorder: OutlineInputBorder^(
echo         borderRadius: BorderRadius.circular^(8^),
echo         borderSide: const BorderSide^(color: Color^(0xFF546E7A^), width: 2^),
echo       ^),
echo       contentPadding: const EdgeInsets.symmetric^(horizontal: 16, vertical: 12^),
echo     ^),
echo     cardTheme: CardThemeData^(
echo       elevation: 2,
echo       shape: RoundedRectangleBorder^(
echo         borderRadius: BorderRadius.circular^(12^),
echo       ^),
echo     ^),
echo     elevatedButtonTheme: ElevatedButtonThemeData^(
echo       style: ElevatedButton.styleFrom^(
echo         elevation: 2,
echo         padding: const EdgeInsets.symmetric^(horizontal: 24, vertical: 12^),
echo         shape: RoundedRectangleBorder^(
echo           borderRadius: BorderRadius.circular^(8^),
echo         ^),
echo       ^),
echo     ^),
echo     filledButtonTheme: FilledButtonThemeData^(
echo       style: FilledButton.styleFrom^(
echo         elevation: 0,
echo         padding: const EdgeInsets.symmetric^(horizontal: 24, vertical: 12^),
echo         shape: RoundedRectangleBorder^(
echo           borderRadius: BorderRadius.circular^(8^),
echo         ^),
echo       ^),
echo     ^),
echo   ^);
echo }
) > lib\theme.dart
echo OK - theme.dart corrigido (CardThemeData)
echo.

echo [4/6] Limpando cache...
flutter clean >nul 2>&1
if exist pubspec.lock del /F /Q pubspec.lock
if exist build rmdir /S /Q build 2>nul
if exist .dart_tool rmdir /S /Q .dart_tool 2>nul
echo OK
echo.

echo [5/6] Instalando dependencias...
flutter pub get
echo.

echo [6/6] PRONTO!
echo ==========================================
echo  TUDO CORRIGIDO!
echo ==========================================
echo.
echo Arquivos corrigidos:
echo [OK] pubspec.yaml - sdk: ^3.9.0, intl: ^0.20.2
echo [OK] lib/theme.dart - CardThemeData
echo.
echo Agora execute:
echo   flutter run -d windows
echo.
pause
