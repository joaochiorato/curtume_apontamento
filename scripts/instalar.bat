@echo off
cls
echo ==========================================
echo  INSTALACAO PROJETO v2.0 - ATUALIZADO
echo ==========================================
echo.
echo Projeto: Curtume Apontamento Vancouros
echo Versao: 2.0.1
echo Estagios: 5 (Remolho ate Refila)
echo.
echo Este script vai:
echo [1] Matar processos bloqueados
echo [2] Limpar cache
echo [3] Instalar dependencias
echo [4] Verificar instalacao
echo.
pause

cd /d "%~dp0\.."

echo.
echo [1/4] Matando processos...
taskkill /F /IM curtume_apontamento_remolho.exe 2>nul >nul
taskkill /F /IM dart.exe 2>nul >nul
echo OK
echo.

echo [2/4] Limpando cache...
flutter clean >nul 2>&1
if exist pubspec.lock del /F /Q pubspec.lock 2>nul
if exist build rmdir /S /Q build 2>nul
if exist .dart_tool rmdir /S /Q .dart_tool 2>nul
echo OK
echo.
pause

echo [3/4] Instalando dependencias...
echo.
flutter pub get
echo.

if %errorlevel% neq 0 (
    echo.
    echo ERRO ao instalar dependencias!
    pause
    exit /b 1
)

echo [4/4] Verificando instalacao...
flutter doctor
echo.

echo ==========================================
echo  INSTALACAO CONCLUIDA!
echo ==========================================
echo.
echo Projeto instalado com sucesso!
echo.
echo Recursos:
echo [OK] 5 Estagios (Remolho ate Refila)
echo [OK] Responsavel Superior
echo [OK] Selecao de Maquina
echo [OK] Nome do Refilador (Refila)
echo.
echo Agora execute:
echo   flutter run -d windows
echo.
pause
