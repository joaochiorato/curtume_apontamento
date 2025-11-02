# 🏭 SISTEMA DE APONTAMENTO DE PRODUÇÃO - CURTUME VANCOUROS

## 📋 Versão 2.0.1 - ATUALIZADA

Sistema de apontamento de produção para curtume desenvolvido em Flutter.

---

## ✨ RECURSOS DO SISTEMA

### ✅ 5 Estágios Completos
1. **REMOLHO** - 4 Fulões disponíveis
2. **ENXUGADEIRA** - 2 Máquinas
3. **DIVISORA** - 2 Máquinas  
4. **REBAIXADEIRA** - 6 Máquinas
5. **REFILA** - Identificação do Refilador

### ✅ Funcionalidades Principais
- ✅ Controle de Responsável
- ✅ Responsável Superior (Remolho, Enxugadeira, Divisora e Rebaixadeira)
- ✅ Seleção de Máquina/Fulão
- ✅ Contador de Quantidade Processada (peças)
- ✅ Campo de Observações
- ✅ Registro de Variáveis com validação de padrões
- ✅ Controle de status: Iniciar, Pausar, Reabrir, Fechar
- ✅ Início e Término Automáticos
- ✅ Interface inspirada no Frigosoft

### ✅ Rebaixadeira
- 6 máquinas disponíveis
- Variáveis: Velocidade do Rolo de Transporte e Espessura de Rebaixe
- **SEM sistema de pallets**

---

## 🚀 INSTALAÇÃO

### Windows
```bash
# Execute o script de instalação
scripts\instalar.bat
```

### Linux/Mac
```bash
# Dê permissão de execução
chmod +x scripts/instalar.sh

# Execute o script
./scripts/instalar.sh
```

### Manual
```bash
# Limpar cache
flutter clean

# Instalar dependências
flutter pub get

# Executar
flutter run -d windows
```

---

## 📁 ESTRUTURA DO PROJETO

```
lib/
├── main.dart                 # Ponto de entrada
├── theme.dart               # Tema do app
├── models/
│   ├── order.dart           # Modelo de Ordem
│   ├── article.dart         # Modelo de Artigo
│   └── stage.dart           # Modelo de Estágio (ATUALIZADO)
├── pages/
│   ├── home_page.dart       # Tela inicial
│   ├── orders_page.dart     # Lista de ordens
│   ├── articles_page.dart   # Lista de artigos
│   └── stage_page.dart      # Página dos estágios
└── widgets/
    ├── stage_button.dart    # Botão de estágio
    ├── stage_form.dart      # Formulário do estágio
    ├── stage_action_bar.dart # Barra de ações
    └── qty_counter.dart     # Contador customizado
```

---

## 🔄 CHANGELOG v2.0.1

### Removido
- ❌ Sistema de 10 pallets da Rebaixadeira
- ❌ Referências a pallets nos scripts de instalação

### Mantido
- ✅ Todos os 5 estágios funcionais
- ✅ Sistema de variáveis com validação
- ✅ Contador de peças processadas
- ✅ Interface visual do Frigosoft
- ✅ Scripts de instalação e correção

---

## 🛠️ CORREÇÃO DE PROBLEMAS

### Arquivo EXE bloqueado
```bash
# Windows
scripts\corrigir_build.bat

# PowerShell
scripts\corrigir_build.ps1

# Como Administrador
scripts\corrigir_build_admin.bat
```

---

## 📱 PLATAFORMAS SUPORTADAS

- ✅ Windows Desktop
- ✅ Linux
- ✅ macOS
- ⚠️ Android/iOS (necessita ajustes)

---

## 🎨 DESIGN

Interface baseada no sistema **Frigosoft** da ATAK Sistemas:
- Header cinza escuro (#424242)
- Fundo cinza claro (#F5F5F5)
- Cards brancos com sombra
- Botões de ação no rodapé
- Logo ATAK em destaque

---

## 📄 LICENÇA

Uso interno - Curtume Vancouros

---

## 👥 SUPORTE

Para dúvidas ou problemas:
- Consulte a documentação
- Verifique os scripts de correção
- Execute `flutter doctor` para diagnóstico

---

**Sistema desenvolvido para controle de produção industrial de curtume.**

*Última atualização: v2.0.1 - Outubro 2025*
