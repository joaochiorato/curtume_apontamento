@echo off
echo ========================================
echo  CORRECAO DO BUILD WINDOWS - FLUTTER
echo ========================================
echo.

echo [1/6] Finalizando processos do app...
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul
if %errorlevel% equ 0 (
    echo    OK - Processo finalizado
) else (
    echo    OK - Nenhum processo em execucao
)
echo.

echo [2/6] Limpando cache do Flutter...
call flutter clean
echo    OK - Cache limpo
echo.

echo [3/6] Deletando pasta build...
if exist build (
    rmdir /S /Q build
    echo    OK - Pasta build deletada
) else (
    echo    OK - Pasta build nao existe
)
echo.

echo [4/6] Deletando cache do Dart...
if exist .dart_tool (
    rmdir /S /Q .dart_tool
    echo    OK - Cache Dart deletado
) else (
    echo    OK - Cache Dart nao existe
)
echo.

echo [5/6] Atualizando dependencias...
call flutter pub get
echo    OK - Dependencias atualizadas
echo.

echo [6/6] Verificando instalacao...
call flutter doctor
echo.

echo ========================================
echo  CORRECAO CONCLUIDA!
echo ========================================
echo.
echo Agora execute: flutter run
echo.
pause
