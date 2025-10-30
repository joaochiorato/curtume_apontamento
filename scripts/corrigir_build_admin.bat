@echo off
echo ========================================
echo  CORRECAO AVANCADA - COM ADMINISTRADOR
echo ========================================
echo.
echo Este script precisa de permissoes de administrador.
echo Clique com botao direito e escolha "Executar como administrador"
echo.
pause

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERRO: Execute como Administrador!
    pause
    exit /b 1
)

echo [OK] Executando como Administrador
echo.

echo [1/8] Finalizando TODOS os processos Flutter...
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul
echo    OK - Processos finalizados
echo.

echo [2/8] Liberando arquivo EXE...
del /F /Q "build\windows\x64\runner\Debug\curtume_apontamento_remolho.exe" 2>nul
echo    OK - Arquivo liberado
echo.

echo [3/8] Limpando cache do Flutter...
call flutter clean
echo    OK - Cache limpo
echo.

echo [4/8] Deletando pasta build...
if exist build (
    rmdir /S /Q build
    echo    OK - Pasta build deletada
)
echo.

echo [5/8] Deletando cache do Dart...
if exist .dart_tool (
    rmdir /S /Q .dart_tool
    echo    OK - Cache Dart deletado
)
echo.

echo [6/8] Deletando cache do pub...
if exist "%LOCALAPPDATA%\Pub\Cache" (
    rmdir /S /Q "%LOCALAPPDATA%\Pub\Cache"
    echo    OK - Cache Pub deletado
)
echo.

echo [7/8] Reinstalando dependencias...
call flutter pub get
echo    OK - Dependencias instaladas
echo.

echo [8/8] Verificando configuracao...
call flutter doctor -v
echo.

echo ========================================
echo  CORRECAO COMPLETA!
echo ========================================
echo.
echo IMPORTANTE: Feche TODAS as janelas do app antes de rodar!
echo.
echo Agora execute: flutter run
echo.
pause
