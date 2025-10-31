#!/bin/bash

echo "========================================"
echo " INSTALACAO - SISTEMA DE STATUS ATAK"
echo "========================================"
echo ""

# Verificar se está na raiz do projeto
if [ ! -d "lib" ]; then
    echo "ERRO: Execute este script na raiz do projeto Flutter!"
    echo ""
    exit 1
fi

echo "[1/5] Criando backups..."
mkdir -p backups
if [ -f "lib/models/order.dart" ]; then
    cp "lib/models/order.dart" "backups/order.dart.backup"
    echo "   OK - Backup de order.dart criado"
fi
if [ -f "lib/pages/orders_page.dart" ]; then
    cp "lib/pages/orders_page.dart" "backups/orders_page.backup"
    echo "   OK - Backup de orders_page.dart criado"
fi
echo ""

echo "[2/5] Copiando novo arquivo status_ordem.dart..."
cp "sistema_status_atak/lib/models/status_ordem.dart" "lib/models/"
echo "   OK - status_ordem.dart copiado"
echo ""

echo "[3/5] Atualizando order.dart..."
cp "sistema_status_atak/lib/models/order.dart" "lib/models/"
echo "   OK - order.dart atualizado"
echo ""

echo "[4/5] Atualizando orders_page.dart..."
cp "sistema_status_atak/lib/pages/orders_page.dart" "lib/pages/"
echo "   OK - orders_page.dart atualizado"
echo ""

echo "[5/5] Limpando cache do Flutter..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1
echo "   OK - Cache limpo e dependências atualizadas"
echo ""

echo "========================================"
echo " INSTALACAO CONCLUIDA COM SUCESSO!"
echo "========================================"
echo ""
echo "Backups salvos em: backups/"
echo ""
echo "Próximos passos:"
echo "  1. Execute: flutter run"
echo "  2. Verifique a tela de ordens"
echo ""
echo "Recursos instalados:"
echo "  [x] Sistema de 4 estados (Aguardando, Em Produção, Finalizado, Cancelado)"
echo "  [x] Transição automática de status"
echo "  [x] Barra de progresso visual"
echo "  [x] Layout padronizado ATAK"
echo ""
