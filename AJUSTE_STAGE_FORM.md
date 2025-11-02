# AJUSTE MANUAL no stage_form.dart

## 🎯 Localização:

No método `build()` da classe `_StageFormState`, procure por:

```dart
_timeRow(),
const SizedBox(height: 12),
_fulaoSelector(),
const SizedBox(height: 10),
```

## ✏️ Modificação:

**ANTES:**
```dart
_timeRow(),
const SizedBox(height: 12),
_fulaoSelector(),
const SizedBox(height: 10),

// RESPONSÁVEL - SEM ÍCONE
DropdownButtonFormField<String>(
```

**DEPOIS:**
```dart
_timeRow(),
const SizedBox(height: 12),

// Mostra Fulão e Químicos APENAS no REMOLHO
if (widget.stage.hasFulao) ...[
  _fulaoSelector(),
  const SizedBox(height: 10),
],

// RESPONSÁVEL - SEM ÍCONE
DropdownButtonFormField<String>(
```

## 📝 Explicação:

1. O `if (widget.stage.hasFulao)` verifica se o estágio tem Fulão
2. O spread operator `...[]` permite incluir múltiplos widgets condicionalmente
3. `hasFulao` é `true` apenas no REMOLHO
4. Outros estágios não exibirão os campos de Fulão e Químicos

## ✅ Resultado Esperado:

### REMOLHO:
```
[Barra de Ações]
[Início/Término]
[Fulão] [Químicos]  ← APARECE
[Responsável]
[Responsável Superior]
```

### ENXUGADEIRA, DIVISORA, REBAIXADEIRA, REFILA:
```
[Barra de Ações]
[Início/Término]
                    ← NÃO APARECE
[Responsável]
[Responsável Superior]
```

## ⚠️ IMPORTANTE:

- Certifique-se de que o `stage.dart` foi atualizado PRIMEIRO
- O `stage.dart` deve ter a propriedade `hasFulao` adicionada
- Não remova o método `_fulaoSelector()` - ele ainda é usado pelo REMOLHO

## 🔧 Teste:

Após aplicar:
1. Execute o app
2. Entre em REMOLHO → deve mostrar Fulão e Químicos
3. Entre em ENXUGADEIRA → não deve mostrar Fulão e Químicos
4. Entre em outros estágios → também não devem mostrar

---

✅ Ajuste simples e direto!
