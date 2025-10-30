@echo off
chcp 65001 >nul
echo ========================================
echo  CORREÇÃO COMPLETA - VERSÃO CORRIGIDA
echo ========================================
echo.
echo Este script vai resolver:
echo [1] Arquivo EXE bloqueado
echo [2] Erro de dependência intl
echo.
pause

cd /d "%~dp0"

echo.
echo [1/8] Finalizando processos...
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul
echo    OK - Processos finalizados
echo.

echo [2/8] Deletando arquivo EXE bloqueado...
del /F /Q "build\windows\x64\runner\Debug\curtume_apontamento_remolho.exe" 2>nul
echo    OK - Arquivo deletado
echo.

echo [3/8] Copiando pubspec.yaml correto...
copy /Y pubspec.yaml pubspec.yaml.backup 2>nul
copy /Y pubspec_correto.yaml pubspec.yaml
if %errorlevel% equ 0 (
    echo    OK - pubspec.yaml corrigido
) else (
    echo    ERRO - Arquivo pubspec_correto.yaml nao encontrado
    echo    Execute este script na pasta do projeto!
    pause
    exit /b 1
)
echo.

echo [4/8] Limpando cache Flutter...
call flutter clean
echo    OK - Cache limpo
echo.

echo [5/8] Deletando pasta build...
if exist build (
    rmdir /S /Q build 2>nul
    echo    OK - Build deletado
) else (
    echo    OK - Build não existe
)
echo.

echo [6/8] Deletando pubspec.lock...
if exist pubspec.lock (
    del /F /Q pubspec.lock
    echo    OK - pubspec.lock deletado
)
echo.

echo [7/8] Instalando dependências corrigidas...
call flutter pub get
if %errorlevel% equ 0 (
    echo    OK - Dependências instaladas
) else (
    echo    ERRO - Falha ao instalar dependências
    pause
    exit /b 1
)
echo.

echo [8/8] Verificando instalação...
call flutter doctor
echo.

echo ========================================
echo  CORREÇÃO COMPLETA CONCLUÍDA!
echo ========================================
echo.
echo Problemas resolvidos:
echo [OK] Arquivo EXE bloqueado
echo [OK] Dependência intl corrigida (0.20.2)
echo [OK] Cache limpo
echo [OK] Dependências reinstaladas
echo.
echo Agora execute: flutter run -d windows
echo.
pause
