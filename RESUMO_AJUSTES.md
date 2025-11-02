# 🔧 AJUSTE: Fulão e Químicos APENAS no REMOLHO

## 📝 Arquivos Modificados:

### 1. `lib/models/stage.dart`
**Mudança:** Adiciona propriedade `hasFulao` ao modelo

**Linhas alteradas:**
- Linha 10: Adiciona `final bool hasFulao;`
- Linha 21: Adiciona `this.hasFulao = false,` no construtor  
- Linha 51: Define `hasFulao: true,` APENAS no REMOLHO
- Linhas 74, 130, 187, 219: Define `hasFulao: false,` nos demais estágios

### 2. `lib/widgets/stage_form.dart`  
**Mudança:** Exibe Fulão e Químicos condicionalmente

**Linhas alteradas:**
- Linha 296: Envolve `_fulaoSelector()` com condicional:
  ```dart
  // Antes:
  _fulaoSelector(),
  
  // Depois:
  if (widget.stage.hasFulao) _fulaoSelector(),
  ```

## ✅ Resultado:

- ✅ REMOLHO: Mostra Fulão + Químicos
- ✅ ENXUGADEIRA: Não mostra Fulão nem Químicos
- ✅ DIVISORA: Não mostra Fulão nem Químicos
- ✅ REBAIXADEIRA: Não mostra Fulão nem Químicos
- ✅ REFILA: Não mostra Fulão nem Químicos

## 📦 Como Aplicar:

1. Substitua `lib/models/stage.dart`
2. Substitua `lib/widgets/stage_form.dart`
3. Execute: `flutter pub get`
4. Execute: `flutter run`

