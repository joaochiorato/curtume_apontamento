@echo off
echo ========================================
echo   CORRECAO DE CORES - Order Info Card
echo ========================================
echo.

echo [1/2] Copiando arquivo com cores melhoradas...
if exist lib\widgets\order_info_card.dart (
    copy lib\widgets\order_info_card.dart lib\widgets\order_info_card.dart.backup
    echo Backup criado: order_info_card.dart.backup
)
xcopy /Y lib\widgets\order_info_card.dart lib\widgets\
echo Arquivo copiado!
echo.

echo [2/2] Pronto para rodar...
echo.

echo ========================================
echo   INSTALACAO CONCLUIDA!
echo ========================================
echo.
echo As cores agora estao muito melhores!
echo Execute: flutter run
echo.
pause
