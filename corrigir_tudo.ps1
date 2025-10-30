# Script de Correção Completa - Windows + Dependências
# Execute: powershell -ExecutionPolicy Bypass -File corrigir_tudo.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CORRECAO COMPLETA - TODOS OS PROBLEMAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Este script vai resolver:" -ForegroundColor Yellow
Write-Host "[1] Arquivo EXE bloqueado" -ForegroundColor Yellow
Write-Host "[2] Erro de dependencia intl" -ForegroundColor Yellow
Write-Host ""
Read-Host "Pressione ENTER para continuar"

# 1. Finalizar processos
Write-Host ""
Write-Host "[1/9] Finalizando processos..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*curtume_apontamento*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process | Where-Object {$_.ProcessName -like "*flutter*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process | Where-Object {$_.ProcessName -like "*dart*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   OK - Processos finalizados" -ForegroundColor Green

# 2. Deletar EXE bloqueado
Write-Host ""
Write-Host "[2/9] Deletando arquivo EXE bloqueado..." -ForegroundColor Yellow
$exePath = "build\windows\x64\runner\Debug\curtume_apontamento_remolho.exe"
if (Test-Path $exePath) {
    Remove-Item -Path $exePath -Force -ErrorAction SilentlyContinue
    Write-Host "   OK - Arquivo EXE deletado" -ForegroundColor Green
} else {
    Write-Host "   OK - Arquivo EXE nao existe" -ForegroundColor Green
}

# 3. Corrigir pubspec.yaml
Write-Host ""
Write-Host "[3/9] Corrigindo pubspec.yaml..." -ForegroundColor Yellow

$pubspecContent = @"
name: curtume_apontamento_remolho
description: Sistema de Apontamento de Producao para Curtume
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/logo_atak.png
"@

$pubspecContent | Out-File -FilePath "pubspec.yaml" -Encoding UTF8
Write-Host "   OK - pubspec.yaml corrigido (intl: ^0.20.2)" -ForegroundColor Green

# 4. Flutter clean
Write-Host ""
Write-Host "[4/9] Limpando cache Flutter..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "   OK - Cache limpo" -ForegroundColor Green

# 5. Deletar build
Write-Host ""
Write-Host "[5/9] Deletando pasta build..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   OK - Build deletado" -ForegroundColor Green
} else {
    Write-Host "   OK - Build nao existe" -ForegroundColor Green
}

# 6. Deletar .dart_tool
Write-Host ""
Write-Host "[6/9] Deletando cache Dart..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") {
    Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   OK - Cache Dart deletado" -ForegroundColor Green
} else {
    Write-Host "   OK - Cache Dart nao existe" -ForegroundColor Green
}

# 7. Deletar pubspec.lock
Write-Host ""
Write-Host "[7/9] Deletando pubspec.lock..." -ForegroundColor Yellow
if (Test-Path "pubspec.lock") {
    Remove-Item -Path "pubspec.lock" -Force
    Write-Host "   OK - pubspec.lock deletado" -ForegroundColor Green
}

# 8. Pub get
Write-Host ""
Write-Host "[8/9] Instalando dependencias corrigidas..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Dependencias instaladas com sucesso!" -ForegroundColor Green
} else {
    Write-Host "   ERRO - Falha ao instalar dependencias" -ForegroundColor Red
    Read-Host "Pressione ENTER para sair"
    exit 1
}

# 9. Flutter doctor
Write-Host ""
Write-Host "[9/9] Verificando instalacao..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CORRECAO COMPLETA CONCLUIDA!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Problemas resolvidos:" -ForegroundColor Green
Write-Host "[OK] Arquivo EXE bloqueado" -ForegroundColor Green
Write-Host "[OK] Dependencia intl corrigida (0.20.2)" -ForegroundColor Green
Write-Host "[OK] Cache limpo" -ForegroundColor Green
Write-Host "[OK] Dependencias reinstaladas" -ForegroundColor Green
Write-Host ""
Write-Host "Agora execute: flutter run -d windows" -ForegroundColor Yellow
Write-Host ""
Read-Host "Pressione ENTER para sair"
