# 📋 ATUALIZAÇÃO - OF 18283 QUARTZO

## 🎯 Baseado no PDF: ORDEM_QUARTZO.pdf

Atualização completa do sistema com dados reais da OF 18283 (QUARTZO) da Vancouros.

---

## ✅ MUDANÇAS IMPLEMENTADAS

### 1. **Dados Reais da OF 18283**

Todos os dados foram extraídos do PDF oficial:

| Campo | Valor (do PDF) |
|-------|----------------|
| **OF Nº** | 18283 |
| **Artigo** | QUARTZO |
| **PVE** | 7315 |
| **Cor** | E - BROWN |
| **Classe** | G119 |
| **PO** | 7315CK08 |
| **Crust Item** | 1165 |
| **Esp Final** | 1.1/1.5 |
| **Lote WET BLUE** | 32666 |
| **Nº Pçs NF** | 350 |
| **Metragem NF** | 21.295,25 |
| **AVG** | 60,84 |
| **Peso Líquido** | 9.855,00 kg |
| **Cliente** | Vancouros |
| **Data** | 14/10/2025 |

---

### 2. **Estágios Atualizados**

#### ✅ Estágios Implementados (5 estágios):

```
1. REMOLHO
   └─ Fulão: 1, 2, 3, 4
   └─ Tempo: 120 min +/- 60 min
   └─ Variáveis:
      • Volume de Água (100% peso líquido do lote)
      • Temperatura da Água (60 +/- 10 ºC)
      • Tensoativo (5 +/- 0,200 L)

2. ENXUGADEIRA
   └─ Máquina: 1, 2
   └─ Variáveis:
      • Pressão do Rolo (1º manômetro): 40 a 110 Bar
      • Pressão do Rolo (2º manômetro): 60 a 110 Bar
      • Pressão do Rolo (3º manômetro): 60 a 110 Bar
      • Velocidade do Feltro: 15 +/- 3 mt/min
      • Velocidade do Tapete: 13 +/- 3 mt/min

3. DIVISORA
   └─ Máquina: 1, 2
   └─ Espessura: 1.5/1.6 mm
   └─ Variáveis:
      • Espessura de Divisão
      • Peso Bruto
      • Peso Líquido
      • Velocidade da Máquina: 23 +/- 2 metro/minuto
      • Distância da Navalha: 8,0 a 8,5 mm
      • Fio da Navalha Inferior: 5,0 +/- 0,5 mm
      • Fio da Navalha Superior: 6,0 +/- 0,5 mm

4. REBAIXADEIRA
   └─ Máquina: 1, 2, 3, 4, 5, 6
   └─ 10 PLTs (Pallets)
   └─ Espessura: 1.2/1.3+1.2 mm
   └─ Variáveis:
      • Velocidade do Rolo de Transporte: 10/12
      • Espessura de Rebaixe
      • 10 PLTs individuais

5. REFILA
   └─ Nome do Refilador
   └─ Variáveis:
      • Peso Líquido (kg)
      • Peso do Refile (kg)
      • Peso do Cupim (kg)
```

#### ❌ Estágio Removido:

```
DESCANSO (Mínimo 4 horas)
└─ Removido conforme solicitação
└─ Não será implementado no sistema
```

---

### 3. **Modelo de Dados Expandido**

O `ArtigoModel` agora inclui todos os campos do PDF:

```dart
class ArtigoModel {
  // Campos básicos
  final String codigo;
  final String descricao;
  final int quantidade;
  
  // ✅ NOVOS: Campos do PDF
  final String? pve;              // PVE: 7315
  final String? cor;              // Cor: E - BROWN
  final String? classe;           // Classe: G119
  final String? po;               // PO: 7315CK08
  final String? crustItem;        // Crust Item: 1165
  final String? espFinal;         // Esp Final: 1.1/1.5
  final String? loteWetBlue;      // Lote WET BLUE: 32666
  final double? metragemNF;       // Metragem NF: 21.295,25
  final double? avg;              // AVG: 60,84
  final double? pesoLiquido;      // Peso Líquido: 9.855,00
}
```

---

### 4. **Sistema de Status Mantido**

O sistema de gerenciamento de status permanece ativo:

```
AGUARDANDO → EM PRODUÇÃO → FINALIZADO
           ↘ CANCELADO ↙
```

---

## 📁 ARQUIVOS ATUALIZADOS

### 1. `order_of18283.dart`
- ✅ Model atualizado com campos do PDF
- ✅ Factory `ArtigoModel.of18283Quartzo()` com dados reais
- ✅ Sistema de status integrado

### 2. `orders_page_com_status.dart`
- ✅ OF 18283 carregada com dados reais
- ✅ Cliente: Vancouros
- ✅ Data: 14/10/2025
- ✅ Artigo: QUARTZO com todos os dados

### 3. `stage_of18283.dart`
- ✅ 5 estágios baseados no PDF
- ❌ Estágio "Descanso" removido
- ✅ Todos os padrões e limites do PDF
- ✅ Documentação inline completa

---

## 🔄 COMPARATIVO: ANTES vs DEPOIS

### ANTES (dados mockados):
```dart
OrdemModel(
  of: '18283',
  cliente: 'Cliente A',
  artigos: [
    ArtigoModel(codigo: 'ART001', descricao: 'QUARTZO', quantidade: 350),
  ],
)
```

### DEPOIS (dados reais do PDF):
```dart
OrdemModel(
  of: '18283',
  cliente: 'Vancouros',
  data: DateTime(2025, 10, 14),
  artigos: [
    ArtigoModel(
      codigo: 'QUARTZO',
      descricao: 'QUARTZO',
      quantidade: 350,
      pve: '7315',
      cor: 'E - BROWN',
      classe: 'G119',
      po: '7315CK08',
      crustItem: '1165',
      espFinal: '1.1/1.5',
      loteWetBlue: '32666',
      metragemNF: 21295.25,
      avg: 60.84,
      pesoLiquido: 9855.00,
    ),
  ],
)
```

---

## 🎨 VISUALIZAÇÃO NA TELA

### Card da OF 18283 (Como Aparecerá):

```
┌─────────────────────────────────────┐
│ OF 18283                            │
├─────────────────────────────────────┤
│ 👤 Cliente: Vancouros               │
│ 📅 Data: 14/10/2025                 │
│ 📦 Artigos: 1 artigo(s)             │
├─────────────────────────────────────┤
│ Aguardando                       ▶  │
└─────────────────────────────────────┘
```

### Ao Clicar no Artigo QUARTZO:

```
┌─────────────────────────────────────┐
│ OF 18283                            │
├─────────────────────────────────────┤
│ ARTIGO: QUARTZO                     │
│ PVE: 7315                           │
│ COR: E - BROWN                      │
│ CLASSE: G119                        │
│ PO: 7315CK08                        │
│ CRUST ITEM: 1165                    │
│ ESP FINAL: 1.1/1.5                  │
├─────────────────────────────────────┤
│ LOTE WET BLUE: 32666                │
│ Nº PÇS NF: 350                      │
│ METRAGEM NF: 21.295,25              │
│ AVG: 60,84                          │
│ PESO LÍQUIDO: 9.855,00 kg           │
└─────────────────────────────────────┘
```

---

## 🔧 ESTRUTURA DE ESTÁGIOS

### Fluxo Completo (5 estágios):

```
OF 18283 - QUARTZO
    ↓
[1] REMOLHO (Fulão 1-4)
    ↓
[2] ENXUGADEIRA (Máquina 1-2)
    ↓
[3] DIVISORA (Máquina 1-2)
    ↓
[❌ DESCANSO REMOVIDO]
    ↓
[4] REBAIXADEIRA (Máquina 1-6, 10 PLTs)
    ↓
[5] REFILA (Nome do Refilador)
    ↓
✅ FINALIZADO
```

---

## 📊 DADOS TÉCNICOS DO PDF

### Seção REMOLHO:
```
Fulão: 1 □  2 □  3 □  4 □
Tempo: 120 minutos +/- 60 min

Volume de Água: 100% peso líquido do lote (L)
Temperatura da Água: 60 +/- 10 ºC (dentro do fulão)
Tensoativo: 5 +/- 0,200 L
```

### Seção ENXUGADEIRA:
```
Máquina: 1 □  2 □

Pressão do Rolo (1º manômetro): 40 a 110 Bar
Pressão do Rolo (2º e 3º manômetro): 60 a 110 Bar
Velocidade do Feltro: 15 +/- 3 mt/min
Velocidade do Tapete: 13 +/- 3 mt/min
```

### Seção DIVISORA:
```
Máquina: 1 □  2 □
Espessura de Divisão: 1.5/1.6 mm

Velocidade da Máquina: 23 +/- 2 metro/minuto
Distância da Navalha: 8,0 a 8,5 mm
Fio da Navalha Inferior: 5,0 +/- 0,5 mm
Fio da Navalha Superior: 6,0 +/- 0,5 mm
```

### ❌ Seção DESCANSO (REMOVIDA):
```
Mínimo 4 horas
└─ NÃO IMPLEMENTADO
```

### Seção REBAIXADEIRA:
```
Máquina: 1 □  2 □  3 □  4 □  5 □  6 □
Espessura de Rebaixe: 1.2/1.3+1.2

Velocidade do Rolo de Transporte: 10/12
Espessura e rebaixe: de acordo com TAB 001

10 PLTs:
1º PLT  |  2º PLT  |  3º PLT  |  4º PLT  |  5º PLT
6º PLT  |  7º PLT  |  8º PLT  |  9º PLT  |  10º PLT
```

### Seção REFILA:
```
Peso Líquido: _______ KGS
Peso do Refile: _______ KGS
Peso do Cupim: _______ KGS

Nome do(a) Refilador(a): _____________
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### Dados da OF:
- [x] OF Nº: 18283
- [x] Cliente: Vancouros
- [x] Data: 14/10/2025
- [x] Artigo: QUARTZO
- [x] Todos os campos do PDF

### Estágios:
- [x] 1. REMOLHO
- [x] 2. ENXUGADEIRA
- [x] 3. DIVISORA
- [x] ❌ DESCANSO (removido)
- [x] 4. REBAIXADEIRA (10 PLTs)
- [x] 5. REFILA (nome refilador)

### Sistema:
- [x] Sistema de status funcional
- [x] Transições automáticas
- [x] Barra de progresso
- [x] Layout padronizado ATAK

---

## 📝 NOTAS IMPORTANTES

1. ✅ **Estágio Descanso Removido**
   - Conforme solicitado, o estágio "Descanso (Mínimo 4 horas)" não está implementado
   - O fluxo pula direto de DIVISORA para REBAIXADEIRA

2. ✅ **Dados Reais**
   - Todos os valores são baseados no PDF oficial da OF 18283
   - Padrões e limites extraídos do formulário original

3. ✅ **10 Pallets na Rebaixadeira**
   - Sistema suporta entrada de dados para cada um dos 10 PLTs
   - Conforme especificado no PDF

4. ✅ **Nome do Refilador**
   - Campo específico no estágio REFILA
   - Permite registro do responsável pela refila

---

## 🚀 PRÓXIMOS PASSOS

Para aplicar as atualizações:

```bash
# 1. Substituir arquivos
cp order_of18283.dart lib/models/order.dart
cp stage_of18283.dart lib/models/stage.dart
cp orders_page_com_status.dart lib/pages/orders_page.dart

# 2. Limpar e executar
flutter clean
flutter pub get
flutter run
```

---

**Sistema atualizado com dados reais da OF 18283! 🎉**
**Estágio Descanso removido conforme solicitado! ✅**
