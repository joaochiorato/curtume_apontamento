# 🎯 CAMPOS FULÃO E QUÍMICOS - APENAS NO REMOLHO

## 📋 REGRA IMPLEMENTADA

**✅ Apenas o estágio REMOLHO tem os campos Fulão e Químicos**

**❌ Todos os outros estágios NÃO têm esses campos**

---

## 🔧 MUDANÇAS NO CÓDIGO

### 1. Model de Estágio Atualizado (`stage.dart`)

Adicionadas duas flags no `StageModel`:

```dart
class StageModel {
  final bool hasFulao;      // Indica se tem campo Fulão
  final bool hasQuimicos;   // Indica se tem campo Químicos
  
  StageModel({
    // ...
    this.hasFulao = false,     // Padrão: false
    this.hasQuimicos = false,  // Padrão: false
  });
}
```

---

## 📊 CONFIGURAÇÃO POR ESTÁGIO

### ✅ REMOLHO (ÚNICO COM FULÃO E QUÍMICOS)

```dart
StageModel(
  code: 'REMOLHO',
  title: 'REMOLHO',
  hasFulao: true,        // ✅ TEM Fulão
  hasQuimicos: true,     // ✅ TEM Químicos
  machines: ['1', '2', '3', '4'],
  // ...
)
```

**Campos exibidos:**
- ✅ Dropdown "Fulão" (opções: 1, 2, 3, 4)
- ✅ Botão "Químicos" (abre dialog com lista de químicos)

---

### ❌ ENXUGADEIRA (SEM FULÃO E QUÍMICOS)

```dart
StageModel(
  code: 'ENXUGADEIRA',
  title: 'ENXUGADEIRA',
  hasFulao: false,       // ❌ NÃO tem Fulão
  hasQuimicos: false,    // ❌ NÃO tem Químicos
  machines: ['1', '2'],
  // ...
)
```

**Campos NÃO exibidos:**
- ❌ Dropdown "Fulão"
- ❌ Botão "Químicos"

---

### ❌ DIVISORA (SEM FULÃO E QUÍMICOS)

```dart
StageModel(
  code: 'DIVISORA',
  title: 'DIVISORA',
  hasFulao: false,       // ❌ NÃO tem Fulão
  hasQuimicos: false,    // ❌ NÃO tem Químicos
  machines: ['1', '2'],
  // ...
)
```

**Campos NÃO exibidos:**
- ❌ Dropdown "Fulão"
- ❌ Botão "Químicos"

---

### ❌ REBAIXADEIRA (SEM FULÃO E QUÍMICOS)

```dart
StageModel(
  code: 'REBAIXADEIRA',
  title: 'REBAIXADEIRA',
  hasFulao: false,       // ❌ NÃO tem Fulão
  hasQuimicos: false,    // ❌ NÃO tem Químicos
  machines: ['1', '2', '3', '4', '5', '6'],
  hasPallets: true,      // ✅ TEM 10 PLTs
  // ...
)
```

**Campos NÃO exibidos:**
- ❌ Dropdown "Fulão"
- ❌ Botão "Químicos"

**Campos exibidos:**
- ✅ 10 PLTs (Pallets)

---

### ❌ REFILA (SEM FULÃO E QUÍMICOS)

```dart
StageModel(
  code: 'REFILA',
  title: 'REFILA',
  hasFulao: false,       // ❌ NÃO tem Fulão
  hasQuimicos: false,    // ❌ NÃO tem Químicos
  hasRefilador: true,    // ✅ TEM Nome do Refilador
  machines: null,
  // ...
)
```

**Campos NÃO exibidos:**
- ❌ Dropdown "Fulão"
- ❌ Botão "Químicos"

**Campos exibidos:**
- ✅ Campo "Nome do Refilador"

---

## 🎨 LÓGICA NO FORMULÁRIO (`stage_form.dart`)

O formulário verifica as flags antes de renderizar os campos:

```dart
// Widget do formulário
Widget build(BuildContext context) {
  return Column(
    children: [
      // ... outros campos ...
      
      // ✅ Só mostra se o estágio tiver hasFulao ou hasQuimicos
      if (widget.stage.hasFulao || widget.stage.hasQuimicos)
        _fulaoSelector(),
      
      // ... resto do formulário ...
    ],
  );
}

// Widget específico de Fulão e Químicos
Widget _fulaoSelector() {
  return Row(
    children: [
      // ✅ Só mostra dropdown se hasFulao = true
      if (widget.stage.hasFulao)
        Expanded(
          child: DropdownButtonFormField<int>(
            // Dropdown Fulão
          ),
        ),
      
      // ✅ Só mostra botão se hasQuimicos = true
      if (widget.stage.hasQuimicos)
        Expanded(
          child: FilledButton(
            onPressed: _openQuimicosDialog,
            child: Text('Químicos'),
          ),
        ),
    ],
  );
}
```

---

## 📋 TABELA RESUMO

| Estágio | Fulão | Químicos | Máquina | Outros |
|---------|-------|----------|---------|--------|
| **REMOLHO** | ✅ Sim (1-4) | ✅ Sim | ✅ Sim | - |
| **ENXUGADEIRA** | ❌ Não | ❌ Não | ✅ Sim (1-2) | - |
| **DIVISORA** | ❌ Não | ❌ Não | ✅ Sim (1-2) | - |
| **REBAIXADEIRA** | ❌ Não | ❌ Não | ✅ Sim (1-6) | ✅ 10 PLTs |
| **REFILA** | ❌ Não | ❌ Não | ❌ Não | ✅ Nome Refilador |

---

## 🔄 FLUXO DE DADOS

### No REMOLHO:
```json
{
  "fulao": 2,
  "quimicos": {
    "Cal virgem": "10.5",
    "Sulfeto de sódio": "5.2",
    "Tensoativo": "8.0"
  },
  "variables": { ... },
  // ... outros campos ...
}
```

### Nos OUTROS estágios:
```json
{
  // ❌ Sem "fulao"
  // ❌ Sem "quimicos"
  "variables": { ... },
  // ... outros campos ...
}
```

---

## ✅ VALIDAÇÕES

### REMOLHO:
- ✅ Exige seleção de Fulão (1, 2, 3 ou 4)
- ⚠️ Químicos são opcionais (podem ser vazios)

### OUTROS ESTÁGIOS:
- ❌ Não validam Fulão (campo não existe)
- ❌ Não validam Químicos (campo não existe)

---

## 🎯 INTERFACE VISUAL

### Tela do REMOLHO:
```
┌─────────────────────────────────────┐
│ REMOLHO                             │
├─────────────────────────────────────┤
│ [Iniciar] [Pausar] [Encerrar]      │
│                                     │
│ Início / Término / Duração          │
│                                     │
│ ┌──────────┐  ┌──────────┐        │
│ │ Fulão: 2 │  │Químicos  │ ✅      │
│ └──────────┘  │  3/6     │        │
│               └──────────┘        │
│                                     │
│ Responsável: [______]               │
│ Responsável Superior: [______]      │
│ QTD Processada: [______]            │
│ Observação: [______]                │
│                                     │
│ Variáveis:                          │
│ • Volume de Água: [______] L        │
│ • Temperatura: [______] ºC          │
│ • Tensoativo: [______] L            │
└─────────────────────────────────────┘
```

### Tela da ENXUGADEIRA (ou outros):
```
┌─────────────────────────────────────┐
│ ENXUGADEIRA                         │
├─────────────────────────────────────┤
│ [Iniciar] [Pausar] [Encerrar]      │
│                                     │
│ Início / Término / Duração          │
│                                     │
│ ❌ SEM Fulão                        │
│ ❌ SEM Químicos                     │
│                                     │
│ Máquina: [1] [2]                    │
│                                     │
│ Responsável: [______]               │
│ Responsável Superior: [______]      │
│ QTD Processada: [______]            │
│ Observação: [______]                │
│                                     │
│ Variáveis:                          │
│ • Pressão Rolo 1º: [______] Bar     │
│ • Pressão Rolo 2º: [______] Bar     │
│ • Pressão Rolo 3º: [______] Bar     │
│ • Velocidade Feltro: [______]       │
│ • Velocidade Tapete: [______]       │
└─────────────────────────────────────┘
```

---

## 📦 ARQUIVOS AFETADOS

### Modificado:
1. `lib/models/stage.dart`
   - Adicionadas flags `hasFulao` e `hasQuimicos`
   - REMOLHO configurado com `true`
   - Outros estágios com `false`

### Mantido (sem alteração):
2. `lib/widgets/stage_form.dart`
   - Já tem lógica condicional para verificar flags
   - Código existente funciona automaticamente

---

## ✅ RESULTADO FINAL

**REMOLHO:**
- ✅ Mostra dropdown Fulão (1, 2, 3, 4)
- ✅ Mostra botão Químicos (dialog com lista)
- ✅ Todas as funcionalidades presentes

**ENXUGADEIRA, DIVISORA, REBAIXADEIRA, REFILA:**
- ❌ NÃO mostra dropdown Fulão
- ❌ NÃO mostra botão Químicos
- ✅ Formulários mais limpos e focados

---

## 🚀 COMO APLICAR

```bash
# 1. Substituir arquivo
cp stage_final.dart lib/models/stage.dart

# 2. Limpar e executar
flutter clean
flutter pub get
flutter run
```

---

**Implementação concluída! ✅**
**Apenas REMOLHO tem Fulão e Químicos! 🎯**
