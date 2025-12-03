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
// 3 ESTÁGIOS - Conforme Teste de Mesa Apontamento Curtume
// Cod_operacao: 1000 (REMOLHO), 1001 (ENXUGADEIRA), 1002 (DIVISORA)
// ═══════════════════════════════════════════════════════════════

final List<StageModel> availableStages = [
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. REMOLHO (Cod_operacao: 1000)
  // Único estágio com Fulão e Químicos
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'REMOLHO',
    title: 'REMOLHO',
    machines: ['1', '2', '3', '4'],
    hasFulao: true,
    needsResponsibleSuperior: true,
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
        hint: '100% do Peso do Couro',
      ),
      VariableModel(
        name: 'Temperatura da Água',
        unit: 'ºC',
        min: 50,
        max: 70,
        hint: 'Faixa 50 a 70',
      ),
      VariableModel(
        name: 'Tensoativo',
        unit: 'L',
        min: 4.8,
        max: 5.2,
        hint: 'Faixa 4.8 - 5.2',
      ),
    ],
  ),

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. ENXUGADEIRA (Cod_operacao: 1001)
  // 4 variáveis conforme teste de mesa
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
        hint: '40 a 110',
      ),
      VariableModel(
        name: 'Pressão do Rolo (2º manômetro)',
        unit: 'Bar',
        min: 60,
        max: 110,
        hint: '60 a 110',
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
  // 3. DIVISORA (Cod_operacao: 1002)
  // 4 variáveis conforme teste de mesa
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'DIVISORA',
    title: 'DIVISORA',
    machines: ['1', '2'],
    hasFulao: false,
    needsResponsibleSuperior: true,
    variables: [
      VariableModel(
        name: 'Velocidade da Máquina',
        unit: 'mt/min',
        min: 21,
        max: 25,
        hint: '23 +/- 2',
      ),
      VariableModel(
        name: 'Distância da Navalha',
        unit: 'mm',
        min: 8.0,
        max: 8.5,
        hint: '8,0 a 8,5',
      ),
      VariableModel(
        name: 'Fio da Navalha Inferior',
        unit: 'mm',
        min: 4.5,
        max: 5.5,
        hint: '5,0 +/- 0,5',
      ),
      VariableModel(
        name: 'Fio da Navalha Superior',
        unit: 'mm',
        min: 5.5,
        max: 6.5,
        hint: '6,0 +/- 0,5',
      ),
    ],
  ),
];