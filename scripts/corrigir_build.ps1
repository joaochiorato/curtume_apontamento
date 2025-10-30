# Script de Correção de Build Windows Flutter
# Execute com: powershell -ExecutionPolicy Bypass -File corrigir_build.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CORRECAO DO BUILD WINDOWS - FLUTTER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Finalizar processos
Write-Host "[1/7] Finalizando processos..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*curtume_apontamento*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process | Where-Object {$_.ProcessName -like "*flutter*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process | Where-Object {$_.ProcessName -like "*dart*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   OK - Processos finalizados" -ForegroundColor Green
Write-Host ""

# 2. Deletar arquivo EXE problemático
Write-Host "[2/7] Liberando arquivo EXE..." -ForegroundColor Yellow
$exePath = "build\windows\x64\runner\Debug\curtume_apontamento_remolho.exe"
if (Test-Path $exePath) {
    Remove-Item -Path $exePath -Force -ErrorAction SilentlyContinue
    Write-Host "   OK - Arquivo EXE deletado" -ForegroundColor Green
} else {
    Write-Host "   OK - Arquivo EXE nao existe" -ForegroundColor Green
}
Write-Host ""

# 3. Flutter clean
Write-Host "[3/7] Limpando cache do Flutter..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "   OK - Cache limpo" -ForegroundColor Green
Write-Host ""

# 4. Deletar pasta build
Write-Host "[4/7] Deletando pasta build..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   OK - Pasta build deletada" -ForegroundColor Green
} else {
    Write-Host "   OK - Pasta build nao existe" -ForegroundColor Green
}
Write-Host ""

# 5. Deletar cache Dart
Write-Host "[5/7] Deletando cache Dart..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") {
    Remove-Item -Path ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   OK - Cache Dart deletado" -ForegroundColor Green
} else {
    Write-Host "   OK - Cache Dart nao existe" -ForegroundColor Green
}
Write-Host ""

# 6. Pub get
Write-Host "[6/7] Atualizando dependencias..." -ForegroundColor Yellow
flutter pub get | Out-Null
Write-Host "   OK - Dependencias atualizadas" -ForegroundColor Green
Write-Host ""

# 7. Flutter doctor
Write-Host "[7/7] Verificando instalacao..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CORRECAO CONCLUIDA!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Agora execute: flutter run" -ForegroundColor Green
Write-Host ""
Read-Host "Pressione ENTER para sair"
