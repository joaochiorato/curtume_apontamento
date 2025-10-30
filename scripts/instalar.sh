#!/bin/bash

clear
echo "=========================================="
echo "  INSTALACAO PROJETO v2.0 - COMPLETO"
echo "=========================================="
echo ""
echo "Projeto: Curtume Apontamento Vancouros"
echo "Versao: 2.0.0"
echo "Estagios: 5 (Remolho ate Refila)"
echo ""
read -p "Pressione ENTER para continuar..."

cd "$(dirname "$0")/.."

echo ""
echo "[1/4] Matando processos..."
pkill -f curtume_apontamento_remolho 2>/dev/null || true
pkill -f dart 2>/dev/null || true
echo "OK"

echo ""
echo "[2/4] Limpando cache..."
flutter clean >/dev/null 2>&1
rm -f pubspec.lock
rm -rf build .dart_tool
echo "OK"

echo ""
echo "[3/4] Instalando dependencias..."
echo ""
flutter pub get

if [ $? -ne 0 ]; then
    echo ""
    echo "ERRO ao instalar dependencias!"
    read -p "Pressione ENTER para sair"
    exit 1
fi

echo ""
echo "[4/4] Verificando instalacao..."
flutter doctor
echo ""

echo "=========================================="
echo "  INSTALACAO CONCLUIDA!"
echo "=========================================="
echo ""
echo "Projeto instalado com sucesso!"
echo ""
echo "Recursos:"
echo "[OK] 5 Estagios (Remolho ate Refila)"
echo "[OK] Responsavel Superior"
echo "[OK] Selecao de Maquina"
echo "[OK] 10 PLTs (Rebaixadeira)"
echo "[OK] Nome do Refilador (Refila)"
echo ""
echo "Agora execute:"
echo "  flutter run"
echo ""
read -p "Pressione ENTER para sair"
