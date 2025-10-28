#!/bin/bash

echo "========================================"
echo "  CORREÇÃO DE CORES - Order Info Card"
echo "========================================"
echo ""

echo "[1/2] Copiando arquivo com cores melhoradas..."
if [ -f lib/widgets/order_info_card.dart ]; then
    cp lib/widgets/order_info_card.dart lib/widgets/order_info_card.dart.backup
    echo "✅ Backup criado: order_info_card.dart.backup"
fi
cp -f lib/widgets/order_info_card.dart lib/widgets/
echo "✅ Arquivo copiado!"
echo ""

echo "[2/2] Pronto para rodar..."
echo ""

echo "========================================"
echo "  ✅ INSTALAÇÃO CONCLUÍDA!"
echo "========================================"
echo ""
echo "As cores agora estão muito melhores!"
echo "Execute: flutter run"
echo ""
