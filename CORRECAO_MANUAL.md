# 🔧 CORREÇÃO MANUAL - Stage Form

## 📍 ARQUIVO A EDITAR

`lib/widgets/stage_form.dart`

---

## 🎨 CORREÇÕES NECESSÁRIAS

### 1️⃣ Container de Variáveis (linha ~290)

**ENCONTRE ESTE CÓDIGO:**
```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white24, width: 1.2),  // ← APAGADO
  ),
  child: Column(
```

**SUBSTITUA POR:**
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,  // ← FUNDO BRANCO
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: const Color(0xFF424242),  // ← BORDA FORTE
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
```

---

### 2️⃣ Título "Variáveis" (linha ~299)

**ENCONTRE:**
```dart
Text('Variáveis',
    style: Theme.of(context).textTheme.titleMedium),
```

**SUBSTITUA POR:**
```dart
Text(
  'Variáveis',
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF424242),  // ← COR FORTE
  ),
),
```

---

### 3️⃣ Labels das Variáveis (dentro do loop)

**PROCURE por TextFormField dos nomes das variáveis**

Adicione nas `decoration`:
```dart
decoration: InputDecoration(
  labelText: v.name,
  suffixText: v.unit,
  hintText: v.hint,
  filled: true,  // ← ADICIONE
  fillColor: const Color(0xFFF5F5F5),  // ← ADICIONE (fundo cinza claro)
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: Color(0xFFE0E0E0),  // ← BORDA VISÍVEL
    ),
  ),
  // ... resto do código
),
```

---

### 4️⃣ Indicador de Padrão (fora do padrão)

**ENCONTRE:**
```dart
if (_isOutOfRange(val, min, max))
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.2),  // ← APAGADO
```

**SUBSTITUA POR:**
```dart
if (_isOutOfRange(val, min, max))
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFF9800).withOpacity(0.15),  // ← LARANJA FORTE
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: const Color(0xFFFF9800),  // ← BORDA LARANJA
        width: 1.5,
      ),
    ),
```

---

### 5️⃣ Indicador de Padrão (dentro do padrão)

**ENCONTRE:**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.2),  // ← APAGADO
```

**SUBSTITUA POR:**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: const Color(0xFF4CAF50).withOpacity(0.15),  // ← VERDE FORTE
    borderRadius: BorderRadius.circular(4),
    border: Border.all(
      color: const Color(0xFF4CAF50),  // ← BORDA VERDE
      width: 1.5,
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(
        Icons.check_circle,
        size: 14,
        color: Color(0xFF4CAF50),  // ← VERDE FORTE
      ),
```

---

### 6️⃣ Campo de Observação

**ENCONTRE:**
```dart
TextFormField(
  controller: _obs,
  maxLines: 3,
  enabled: canEdit,
  decoration: const InputDecoration(
    labelText: 'Observação',
    hintText: 'Tempo de Remolho 120 minutos +/- 60 min',
    prefixIcon: Icon(Icons.notes),
  ),
),
```

**ADICIONE:**
```dart
TextFormField(
  controller: _obs,
  maxLines: 3,
  enabled: canEdit,
  decoration: const InputDecoration(
    labelText: 'Observação',
    hintText: 'Tempo de Remolho 120 minutos +/- 60 min',
    prefixIcon: Icon(Icons.notes),
    filled: true,  // ← ADICIONE
    fillColor: Color(0xFFF5F5F5),  // ← ADICIONE
    border: OutlineInputBorder(),  // ← ADICIONE
  ),
),
```

---

## ✅ RESUMO DAS MUDANÇAS

| Elemento | Antes | Depois |
|----------|-------|--------|
| Container variáveis | `Colors.white24` | `Colors.white` + borda forte |
| Título variáveis | Tema padrão | Cinza escuro #424242 |
| Campos input | Sem fundo | Fundo cinza claro #F5F5F5 |
| Bordas campos | Padrão | Cinza #E0E0E0 visível |
| Indicador laranja | `withOpacity(0.2)` | `withOpacity(0.15)` + borda |
| Indicador verde | `withOpacity(0.2)` | `withOpacity(0.15)` + borda |

---

## 🎯 RESULTADO ESPERADO

Após as mudanças:
- ✅ Container branco bem visível
- ✅ Borda preta forte (2px)
- ✅ Campos com fundo cinza claro
- ✅ Labels pretos legíveis
- ✅ Indicadores coloridos com borda

---

## 📝 DEPOIS DAS ALTERAÇÕES

```bash
flutter clean
flutter pub get
flutter run
```

---

**Siga passo a passo e o formulário ficará perfeitamente legível!** 🎨
