@echo off
echo ========================================
echo  INSTALACAO - SISTEMA DE STATUS ATAK
echo ========================================
echo.

REM Verificar se esta na raiz do projeto
if not exist "lib" (
    echo ERRO: Execute este script na raiz do projeto Flutter!
    echo.
    pause
    exit /b 1
)

echo [1/5] Criando backups...
if not exist "backups" mkdir backups
if exist "lib\models\order.dart" (
    copy "lib\models\order.dart" "backups\order.dart.backup" >nul
    echo    OK - Backup de order.dart criado
)
if exist "lib\pages\orders_page.dart" (
    copy "lib\pages\orders_page.dart" "backups\orders_page.backup" >nul
    echo    OK - Backup de orders_page.dart criado
)
echo.

echo [2/5] Copiando novo arquivo status_ordem.dart...
copy "sistema_status_atak\lib\models\status_ordem.dart" "lib\models\" >nul
echo    OK - status_ordem.dart copiado
echo.

echo [3/5] Atualizando order.dart...
copy "sistema_status_atak\lib\models\order.dart" "lib\models\" >nul
echo    OK - order.dart atualizado
echo.

echo [4/5] Atualizando orders_page.dart...
copy "sistema_status_atak\lib\pages\orders_page.dart" "lib\pages\" >nul
echo    OK - orders_page.dart atualizado
echo.

echo [5/5] Limpando cache do Flutter...
call flutter clean >nul 2>&1
call flutter pub get >nul 2>&1
echo    OK - Cache limpo e dependencias atualizadas
echo.

echo ========================================
echo  INSTALACAO CONCLUIDA COM SUCESSO!
echo ========================================
echo.
echo Backups salvos em: backups\
echo.
echo Proximos passos:
echo   1. Execute: flutter run
echo   2. Verifique a tela de ordens
echo.
echo Recursos instalados:
echo   [x] Sistema de 4 estados (Aguardando, Em Producao, Finalizado, Cancelado)
echo   [x] Transicao automatica de status
echo   [x] Barra de progresso visual
echo   [x] Layout padronizado ATAK
echo.
pause
