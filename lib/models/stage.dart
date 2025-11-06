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
  final bool hasFulao;

  StageModel({
    required this.code,
    required this.title,
    required this.variables,
    this.machines,
    this.needsResponsibleSuperior = true,
    this.hasPallets = false,
    this.hasRefilador = false,
    this.hasFulao = false,
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

// ═══════════════════════════════════════════════════════════════
// 5 ESTÁGIOS COMPLETOS - Sistema de Apontamento Curtume
// ═══════════════════════════════════════════════════════════════

final List<StageModel> availableStages = [
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. REMOLHO - Único estágio com Fulão e Químicos
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'REMOLHO',
    title: 'REMOLHO',
    machines: ['1', '2', '3', '4'],
    hasFulao: true, // ← ÚNICO com Fulão e Químicos
    needsResponsibleSuperior: true,
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
        hint: '100% do peso líquido do lote',
      ),
      VariableModel(
        name: 'Temperatura da Água',
        unit: 'ºC',
        min: 50,
        max: 70,
        hint: 'Dentro do fulão (60 +/- 10)',
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. ENXUGADEIRA
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'ENXUGADEIRA',
    title: 'ENXUGADEIRA',
    machines: ['1', '2'],
    hasFulao: false,
    needsResponsibleSuperior: true,
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. DIVISORA
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'DIVISORA',
    title: 'DIVISORA',
    machines: ['1', '2'],
    hasFulao: false,
    needsResponsibleSuperior: true,
    variables: [
      VariableModel(
        name: 'Espessura Final',
        unit: 'mm',
        min: 0.8,
        max: 2.5,
        hint: 'Conforme especificação do artigo',
      ),
      VariableModel(
        name: 'Velocidade da Máquina',
        unit: 'mt/min',
        min: 5,
        max: 15,
        hint: '10 +/- 5',
      ),
      VariableModel(
        name: 'Pressão do Cilindro',
        unit: 'Bar',
        min: 80,
        max: 150,
      ),
    ],
  ),

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. REBAIXADEIRA
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'REBAIXADEIRA',
    title: 'REBAIXADEIRA',
    machines: ['1', '2'],
    hasFulao: false,
    hasPallets: false, // ← SEM sistema de pallets
    needsResponsibleSuperior: true,
    variables: [
      VariableModel(
        name: 'Altura da Lixa',
        unit: 'mm',
        min: 0.5,
        max: 3.0,
        hint: 'Ajustar conforme necessidade',
      ),
      VariableModel(
        name: 'Velocidade da Esteira',
        unit: 'mt/min',
        min: 3,
        max: 12,
        hint: '7 +/- 4',
      ),
      VariableModel(
        name: 'Granulometria da Lixa',
        unit: 'mesh',
        min: 40,
        max: 180,
      ),
      VariableModel(
        name: 'Pressão do Rolo',
        unit: 'Bar',
        min: 20,
        max: 80,
      ),
    ],
  ),

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. REFILADORA (REFILA)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'REFILA',
    title: 'REFILADORA',
    machines: ['1', '2'],
    hasFulao: false,
    hasRefilador: true,
    needsResponsibleSuperior: false, // ← Não precisa supervisor
    variables: [
      VariableModel(
        name: 'Largura de Corte',
        unit: 'cm',
        min: 10,
        max: 200,
        hint: 'Conforme especificação',
      ),
      VariableModel(
        name: 'Velocidade de Corte',
        unit: 'mt/min',
        min: 5,
        max: 20,
        hint: '12 +/- 7',
      ),
      VariableModel(
        name: 'Tensão da Lâmina',
        unit: 'N',
        min: 100,
        max: 300,
      ),
    ],
  ),
];