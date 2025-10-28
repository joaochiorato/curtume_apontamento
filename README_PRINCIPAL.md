# 🎨 CORREÇÃO DE CORES - Formulário

## ⚡ CORREÇÃO MANUAL GUIADA

Este ZIP contém um **guia passo a passo** para corrigir as cores apagadas do formulário.

---

## 📁 ARQUIVOS INCLUÍDOS

- **README.md** - Este arquivo
- **CORRECAO_MANUAL.md** - **GUIA COMPLETO** com todas as alterações

---

## 🔧 COMO USAR

### 1️⃣ Leia o Guia

Abra o arquivo `CORRECAO_MANUAL.md` que contém:
- ✅ Código exato para encontrar
- ✅ Código exato para substituir
- ✅ Explicação de cada mudança
- ✅ Cores utilizadas

### 2️⃣ Edite o Arquivo

Abra no seu editor:
```
lib/widgets/stage_form.dart
```

### 3️⃣ Aplique as Correções

Siga o guia passo a passo substituindo os trechos de código.

### 4️⃣ Teste

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🎯 PRINCIPAIS MUDANÇAS

### Container de Variáveis:
- **Fundo:** Branco sólido
- **Borda:** Cinza escuro 2px
- **Sombra:** Leve

### Campos de Input:
- **Fundo:** Cinza claro (#F5F5F5)
- **Borda:** Cinza (#E0E0E0)
- **Texto:** Preto

### Indicadores:
- **Fora do padrão:** Laranja com borda
- **Dentro do padrão:** Verde com borda

---

## 📸 ANTES vs DEPOIS

### ANTES (apagado):
```
┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐  ← Borda quase invisível
  Variáveis (apagado)
  [campo transparente]
└─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
```

### DEPOIS (visível):
```
┌═══════════════════════┐  ← Borda forte preta
║ 🔬 Variáveis          ║
║ ┌─────────────────┐   ║
║ │ Volume de Água  │   ║  ← Campo com fundo
║ │ [________]  L   │   ║
║ └─────────────────┘   ║
└═══════════════════════┘
```

---

## ⏱️ TEMPO ESTIMADO

**5-10 minutos** para aplicar todas as correções.

---

## ✅ CHECKLIST

- [ ] Li o CORRECAO_MANUAL.md
- [ ] Abri lib/widgets/stage_form.dart
- [ ] Apliquei correção 1 (Container)
- [ ] Apliquei correção 2 (Título)
- [ ] Apliquei correção 3 (Labels)
- [ ] Apliquei correção 4 (Indicador laranja)
- [ ] Apliquei correção 5 (Indicador verde)
- [ ] Apliquei correção 6 (Observação)
- [ ] Testei com `flutter run`
- [ ] Cores estão perfeitas! 🎉

---

## 🐛 PROBLEMAS?

Se após as mudanças ainda estiver apagado:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 💡 DICA

Faça as mudanças uma por vez e teste após cada uma para identificar facilmente qualquer problema.

---

**Siga o guia CORRECAO_MANUAL.md para todas as instruções detalhadas!** 📖

Data: Outubro 2025  
Versão: 1.0.3 (Correção formulário)  
Tipo: Correção manual guiada
