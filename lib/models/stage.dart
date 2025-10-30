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

  StageModel({
    required this.code,
    required this.title,
    required this.variables,
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

// Estágios disponíveis
final List<StageModel> availableStages = [
  StageModel(
    code: 'REMOLHO',
    title: 'REMOLHO',
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
        hint: '100% do peso líquido do lote',
      ),
      VariableModel(
        name: 'Temperatura da Água',
        unit: 'ºC',
        min: 18,
        max: 25,
      ),
      VariableModel(
        name: 'pH Inicial',
        unit: '',
        min: 7.5,
        max: 8.5,
      ),
      VariableModel(
        name: 'pH Final',
        unit: '',
        min: 8.0,
        max: 9.0,
      ),
    ],
  ),
  StageModel(
    code: 'CALEIRO',
    title: 'CALEIRO',
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
        hint: '80% do peso líquido',
      ),
      VariableModel(
        name: 'Temperatura',
        unit: 'ºC',
        min: 20,
        max: 28,
      ),
      VariableModel(
        name: 'pH Final',
        unit: '',
        min: 12.0,
        max: 13.0,
      ),
    ],
  ),
  StageModel(
    code: 'DESCALCINACAO',
    title: 'DESCALCINAÇÃO',
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
      ),
      VariableModel(
        name: 'Temperatura',
        unit: 'ºC',
        min: 28,
        max: 35,
      ),
      VariableModel(
        name: 'pH Final',
        unit: '',
        min: 8.0,
        max: 9.0,
      ),
    ],
  ),
  StageModel(
    code: 'PURGA',
    title: 'PURGA',
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
      ),
      VariableModel(
        name: 'Temperatura',
        unit: 'ºC',
        min: 35,
        max: 40,
      ),
      VariableModel(
        name: 'pH Final',
        unit: '',
        min: 7.5,
        max: 8.5,
      ),
    ],
  ),
  StageModel(
    code: 'PIQUEL',
    title: 'PÍQUEL',
    variables: [
      VariableModel(
        name: 'Volume de Água',
        unit: 'L',
      ),
      VariableModel(
        name: 'Concentração de Sal',
        unit: '°Bé',
        min: 6,
        max: 8,
      ),
      VariableModel(
        name: 'pH Final',
        unit: '',
        min: 2.8,
        max: 3.2,
      ),
    ],
  ),
];
