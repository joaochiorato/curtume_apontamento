enum StageStatus {
  idle,
  running,
  paused,
  closed,
}

class StageModel {
  final String code;
  final String title;
  final List<VariableModel> variables;
  final List<String>? machines;
  final bool needsResponsibleSuperior;
  final bool hasPallets;
  final bool hasRefilador;
  final bool hasFulao;         // ✅ NOVO: Indica se tem campo Fulão
  final bool hasQuimicos;       // ✅ NOVO: Indica se tem campo Químicos

  StageModel({
    required this.code,
    required this.title,
    required this.variables,
    this.machines,
    this.needsResponsibleSuperior = true,
    this.hasPallets = false,
    this.hasRefilador = false,
    this.hasFulao = false,       // ✅ Padrão: false
    this.hasQuimicos = false,    // ✅ Padrão: false
  });
}

class VariableModel {
  final String name;
  final String unit;
  final double? min;
  final double? max;
  final String? hint;

  VariableModel({
    required this.name,
    required this.unit,
    this.min,
    this.max,
    this.hint,
  });
}

// ✅ 5 ESTÁGIOS - BASEADO NO PDF OF 18283 QUARTZO
// ❌ REMOVIDO: Estágio "Descanso" conforme solicitado
// ✅ APENAS REMOLHO tem Fulão e Químicos
final List<StageModel> availableStages = [
  // 1. REMOLHO - ✅ ÚNICO COM FULÃO E QUÍMICOS
  StageModel(
    code: 'REMOLHO',
    title: 'REMOLHO',
    machines: ['1', '2', '3', '4'],
    hasFulao: true,        // ✅ TEM Fulão
    hasQuimicos: true,     // ✅ TEM Químicos
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
        hint: '100% peso líquido do lote',
      ),
      VariableModel(
        name: 'Temperatura da Água',
        unit: 'ºC',
        min: 50,
        max: 70,
        hint: 'Dentro do fulão remolho (60 +/- 10)',
      ),
      VariableModel(
        name: 'Tensoativo',
        unit: 'L',
        min: 4.8,
        max: 5.2,
        hint: '5 +/- 0.200',
      ),
    ],
  ),

  // 2. ENXUGADEIRA - ❌ SEM Fulão e Químicos
  StageModel(
    code: 'ENXUGADEIRA',
    title: 'ENXUGADEIRA',
    machines: ['1', '2'],
    hasFulao: false,       // ❌ NÃO tem Fulão
    hasQuimicos: false,    // ❌ NÃO tem Químicos
    variables: [
      VariableModel(
        name: 'Pressão do Rolo (1º manômetro)',
        unit: 'Bar',
        min: 40,
        max: 110,
      ),
      VariableModel(
        name: 'Pressão do Rolo (2º manômetro)',
        unit: 'Bar',
        min: 60,
        max: 110,
      ),
      VariableModel(
        name: 'Pressão do Rolo (3º manômetro)',
        unit: 'Bar',
        min: 60,
        max: 110,
      ),
      VariableModel(
        name: 'Velocidade do Feltro',
        unit: 'mt/min',
        min: 12,
        max: 18,
        hint: '15 +/- 3',
      ),
      VariableModel(
        name: 'Velocidade do Tapete',
        unit: 'mt/min',
        min: 10,
        max: 16,
        hint: '13 +/- 3',
      ),
    ],
  ),

  // 3. DIVISORA - ❌ SEM Fulão e Químicos
  StageModel(
    code: 'DIVISORA',
    title: 'DIVISORA',
    machines: ['1', '2'],
    hasFulao: false,       // ❌ NÃO tem Fulão
    hasQuimicos: false,    // ❌ NÃO tem Químicos
    variables: [
      VariableModel(
        name: 'Espessura de Divisão',
        unit: 'mm',
        hint: '1.5/1.6',
      ),
      VariableModel(
        name: 'Peso Bruto',
        unit: 'kg',
      ),
      VariableModel(
        name: 'Peso Líquido',
        unit: 'kg',
      ),
      VariableModel(
        name: 'Velocidade da Máquina',
        unit: 'metro/minuto',
        min: 21,
        max: 25,
        hint: '23 +/- 2',
      ),
      VariableModel(
        name: 'Distância da Navalha',
        unit: 'mm',
        min: 8.0,
        max: 8.5,
      ),
      VariableModel(
        name: 'Fio da Navalha Inferior',
        unit: 'mm',
        min: 4.5,
        max: 5.5,
        hint: '5.0 +/- 0.5',
      ),
      VariableModel(
        name: 'Fio da Navalha Superior',
        unit: 'mm',
        min: 5.5,
        max: 6.5,
        hint: '6.0 +/- 0.5',
      ),
    ],
  ),

  // 4. REBAIXADEIRA - ❌ SEM Fulão e Químicos
  StageModel(
    code: 'REBAIXADEIRA',
    title: 'REBAIXADEIRA',
    machines: ['1', '2', '3', '4', '5', '6'],
    hasPallets: true,
    hasFulao: false,       // ❌ NÃO tem Fulão
    hasQuimicos: false,    // ❌ NÃO tem Químicos
    variables: [
      VariableModel(
        name: 'Velocidade do Rolo de Transporte',
        unit: 'mt/min',
        hint: '10/12',
      ),
      VariableModel(
        name: 'Espessura de Rebaixe',
        unit: 'mm',
        hint: '1.2/1.3+1.2',
      ),
    ],
  ),

  // 5. REFILA - ❌ SEM Fulão e Químicos
  StageModel(
    code: 'REFILA',
    title: 'REFILA',
    machines: null,
    needsResponsibleSuperior: false,
    hasRefilador: true,
    hasFulao: false,       // ❌ NÃO tem Fulão
    hasQuimicos: false,    // ❌ NÃO tem Químicos
    variables: [
      VariableModel(
        name: 'Peso Líquido',
        unit: 'kg',
      ),
      VariableModel(
        name: 'Peso do Refile',
        unit: 'kg',
      ),
      VariableModel(
        name: 'Peso do Cupim',
        unit: 'kg',
      ),
    ],
  ),
];

// 📋 RESUMO DOS ESTÁGIOS (baseado no PDF OF 18283)
/*
┌────────────────────────────────────────────────────────────┐
│ ESTÁGIOS DA OF 18283 - QUARTZO                             │
├────────────────────────────────────────────────────────────┤
│                                                            │
│ 1. REMOLHO                                                 │
│    ✅ TEM Fulão (1-4)                                      │
│    ✅ TEM Químicos                                         │
│    └─ Tempo: 120 minutos +/- 60 min                       │
│    └─ 3 variáveis de controle                             │
│                                                            │
│ 2. ENXUGADEIRA                                             │
│    ❌ SEM Fulão                                            │
│    ❌ SEM Químicos                                         │
│    └─ Máquina: 1, 2                                       │
│    └─ 5 variáveis de controle                             │
│                                                            │
│ 3. DIVISORA                                                │
│    ❌ SEM Fulão                                            │
│    ❌ SEM Químicos                                         │
│    └─ Máquina: 1, 2                                       │
│    └─ Espessura: 1.5/1.6 mm                               │
│    └─ 7 variáveis de controle                             │
│                                                            │
│ ❌ DESCANSO (REMOVIDO)                                     │
│    └─ Não será implementado no sistema                    │
│                                                            │
│ 4. REBAIXADEIRA                                            │
│    ❌ SEM Fulão                                            │
│    ❌ SEM Químicos                                         │
│    └─ Máquina: 1, 2, 3, 4, 5, 6                          │
│    └─ 10 PLTs (Pallets)                                   │
│    └─ Espessura: 1.2/1.3+1.2 mm                           │
│    └─ 2 variáveis + 10 PLTs                               │
│                                                            │
│ 5. REFILA                                                  │
│    ❌ SEM Fulão                                            │
│    ❌ SEM Químicos                                         │
│    └─ Nome do Refilador                                   │
│    └─ 3 variáveis (pesos)                                 │
│                                                            │
└────────────────────────────────────────────────────────────┘

IMPORTANTE:
✅ Apenas REMOLHO tem os campos Fulão e Químicos
❌ Todos os outros estágios NÃO têm esses campos
*/
