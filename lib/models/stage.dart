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
  final String? previstoTolerancia; // Valor da coluna "Previsto/Tolerância" do Quartzo

  VariableModel({
    required this.name,
    required this.unit,
    this.min,
    this.max,
    this.hint,
    this.previstoTolerancia,
  });
}

// ═══════════════════════════════════════════════════════════════
// 5 ESTÁGIOS - Conforme Roteiro Produtivo Quartzo
// Cod_operacao: 1000 (REMOLHO), 1001 (ENXUGADEIRA), 1002 (DIVISORA),
//               1003 (REBAIXADEIRA), 1004 (REFILA)
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
        min: 0,
        max: 100,
        hint: '100% do Peso do Couro',
        previstoTolerancia: '100',
      ),
      VariableModel(
        name: 'Temperatura da Água',
        unit: 'ºC',
        min: 10,
        max: 60,
        hint: '60 +/- 10',
        previstoTolerancia: '60',
      ),
      VariableModel(
        name: 'Tensoativo',
        unit: 'L',
        min: 0.200,
        max: 5.3,
        hint: 'Faixa 4.8 - 5.2',
        previstoTolerancia: '5',
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
        previstoTolerancia: '75',
      ),
      VariableModel(
        name: 'Pressão do Rolo (2º manômetro)',
        unit: 'Bar',
        min: 60,
        max: 110,
        hint: '60 a 110',
        previstoTolerancia: '85',
      ),
      VariableModel(
        name: 'Velocidade do Feltro',
        unit: 'mt/min',
        min: 3,
        max: 15,
        hint: '15 +/- 3',
        previstoTolerancia: '15',
      ),
      VariableModel(
        name: 'Velocidade do Tapete',
        unit: 'mt/min',
        min: 3,
        max: 13,
        hint: '13 +/- 3',
        previstoTolerancia: '13',
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
        min: 2,
        max: 23,
        hint: '23 +/- 2',
        previstoTolerancia: '23',
      ),
      VariableModel(
        name: 'Distância da Navalha',
        unit: 'mm',
        min: 8.0,
        max: 8.5,
        hint: '8,0 a 8,5',
        previstoTolerancia: '8.25',
      ),
      VariableModel(
        name: 'Fio da Navalha Inferior',
        unit: 'mm',
        min: 0.5,
        max: 5.0,
        hint: '5,0 +/- 0,5',
        previstoTolerancia: '5.0',
      ),
      VariableModel(
        name: 'Fio da Navalha Superior',
        unit: 'mm',
        min: 0.5,
        max: 6.0,
        hint: '6,0 +/- 0,5',
        previstoTolerancia: '6.0',
      ),
    ],
  ),

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. REBAIXADEIRA (Cod_operacao: 1003)
  // 2 variáveis conforme cadastro Quartzo
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'REBAIXADEIRA',
    title: 'REBAIXADEIRA',
    machines: ['1', '2'],
    hasFulao: false,
    needsResponsibleSuperior: true,
    variables: [
      VariableModel(
        name: 'Velocidade do Rolo de Transporte',
        unit: '',
        min: 10,
        max: 12,
        hint: '10/12',
        previstoTolerancia: '11',
      ),
      VariableModel(
        name: 'Espessura e rebaixe',
        unit: '',
        min: 1.2,
        max: 1.3,
        hint: '1.2/1.3',
        previstoTolerancia: '1.3',
      ),
    ],
  ),

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. REFILA (Cod_operacao: 1004)
  // 3 variáveis conforme cadastro Quartzo
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  StageModel(
    code: 'REFILA',
    title: 'REFILA',
    machines: ['1'],
    hasFulao: false,
    needsResponsibleSuperior: true,
    variables: [
      VariableModel(
        name: 'PESO LÍQUIDO',
        unit: 'KGS',
        hint: '',
      ),
      VariableModel(
        name: 'PESO DO REFILE',
        unit: 'KGS',
        hint: '',
      ),
      VariableModel(
        name: 'PESO DO CUPIM',
        unit: 'KGS',
        hint: '',
      ),
    ],
  ),
];