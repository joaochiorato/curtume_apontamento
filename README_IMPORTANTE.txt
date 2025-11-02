# ⚠️ IMPORTANTE - LEIA PRIMEIRO

## O campo Fulão ainda aparece nos outros estágios?

Se sim, siga EXATAMENTE estes passos:

---

## 📝 PASSO 1: Substitua o `stage.dart`

1. Vá até: `lib/models/stage.dart`
2. **APAGUE** o arquivo completamente
3. **COPIE** o arquivo `stage.dart` deste ZIP
4. **COLE** em `lib/models/stage.dart`

---

## 📝 PASSO 2: Edite o `stage_form.dart`

1. Abra: `lib/widgets/stage_form.dart`
2. Pressione `Ctrl+F` (ou `Cmd+F` no Mac)
3. Procure por: `_fulaoSelector(),`
4. Você vai encontrar algo assim (linha ~296):

```dart
_timeRow(),
const SizedBox(height: 12),
_fulaoSelector(),              ← LINHA A SUBSTITUIR
const SizedBox(height: 10),
```

5. **DELETE** estas 2 linhas:
```dart
_fulaoSelector(),
const SizedBox(height: 10),
```

6. **COLE** no lugar:
```dart
// Fulão e Químicos APENAS no REMOLHO
if (widget.stage.hasFulao) ...[
  _fulaoSelector(),
  const SizedBox(height: 10),
],
```

7. **Salve** o arquivo (`Ctrl+S`)

---

## 📝 PASSO 3: Limpe e Recompile

Abra o terminal na pasta do projeto e execute:

```bash
flutter clean
flutter pub get
flutter run -d windows
```

**AGUARDE** a recompilação completa (pode levar 1-2 minutos)

---

## ✅ Como Verificar se Funcionou:

1. Abra o app
2. Entre em **REMOLHO** → Deve mostrar Fulão e Químicos
3. Entre em **ENXUGADEIRA** → NÃO deve mostrar Fulão nem Químicos
4. Entre em **DIVISORA** → NÃO deve mostrar Fulão nem Químicos
5. Entre em **REBAIXADEIRA** → NÃO deve mostrar Fulão nem Químicos
6. Entre em **REFILA** → NÃO deve mostrar Fulão nem Químicos

---

## 🔍 Ainda não funcionou?

### Verifique se o `stage.dart` foi atualizado:

1. Abra `lib/models/stage.dart`
2. Procure por: `final bool hasFulao;`
3. Se **NÃO encontrar**, o arquivo não foi substituído!

### Verifique se o `stage_form.dart` foi editado:

1. Abra `lib/widgets/stage_form.dart`
2. Procure por: `if (widget.stage.hasFulao)`
3. Se **NÃO encontrar**, a edição não foi feita!

---

## 💡 Dica:

Use `Ctrl+F` (buscar) no seu editor para encontrar as linhas rapidamente!

---

✅ Sucesso? Os campos agora só aparecem no REMOLHO!
