import 'package:flutter/material.dart';

class VariableModel {
  final String name;
  final String unit;
  final String type;
  final double? min;
  final double? max;
  final String? hint;
  const VariableModel({required this.name, required this.unit, required this.type, this.min, this.max, this.hint});
}

class StageModel {
  final String code;
  final String title;
  final String? notes;
  final List<VariableModel> variables;
  final IconData icon;
  final Color color;
  const StageModel({
    required this.code, 
    required this.title, 
    required this.variables, 
    required this.icon,
    required this.color,
    this.notes
  });
}

// Lista de todos os estágios
List<StageModel> getAllStages() => [
  remolhoStage(),
  enxugadeiraStage(),
  divisoraStage(),
  rebaixadeiraStage(),
  refilaStage(),
];

// REMOLHO
StageModel remolhoStage() => const StageModel(
  code: 'REMOLHO',
  title: 'REMOLHO',
  icon: Icons.water_drop_outlined,
  color: Color(0xFF546E7A), // Azul acinzentado
  notes: 'Tempo de Remolho 120 minutos +/- 60 min',
  variables: [
    VariableModel(
      name: 'Volume de Água', 
      unit: 'L', 
      type: 'number', 
      hint: '100% do peso líquido do lote'
    ),
    VariableModel(
      name: 'Temperatura da Água (dentro do fulão remolho)', 
      unit: 'ºC', 
      type: 'number', 
      min: 50, 
      max: 70
    ),
    VariableModel(
      name: 'Tensoativo', 
      unit: 'L', 
      type: 'number', 
      min: 4.8, 
      max: 5.2
    ),
  ],
);

// ENXUGADEIRA
StageModel enxugadeiraStage() => const StageModel(
  code: 'ENXUGADEIRA',
  title: 'ENXUGADEIRA',
  icon: Icons.compress,
  color: Color(0xFF546E7A), // Azul acinzentado
  variables: [
    VariableModel(
      name: 'Pressão do Rolo (1º manômetro)', 
      unit: 'Bar', 
      type: 'number', 
      min: 40, 
      max: 110
    ),
    VariableModel(
      name: 'Pressão do Rolo (2º e 3º manômetro)', 
      unit: 'Bar', 
      type: 'number', 
      min: 60, 
      max: 110
    ),
    VariableModel(
      name: 'Velocidade do Feltro', 
      unit: 'mt/min', 
      type: 'number', 
      min: 12, 
      max: 18
    ),
    VariableModel(
      name: 'Velocidade do Tapete', 
      unit: 'mt/min', 
      type: 'number', 
      min: 10, 
      max: 16
    ),
  ],
);

// DIVISORA
StageModel divisoraStage() => const StageModel(
  code: 'DIVISORA',
  title: 'DIVISORA',
  icon: Icons.content_cut,
  color: Color(0xFF546E7A), // Azul acinzentado
  notes: 'Espessura de Divisão: 1.5/1.6',
  variables: [
    VariableModel(
      name: 'Velocidade da Máquina', 
      unit: 'metro/minuto', 
      type: 'number', 
      min: 21, 
      max: 25
    ),
    VariableModel(
      name: 'Distância da Navalha', 
      unit: 'mm', 
      type: 'number', 
      min: 8.0, 
      max: 8.5
    ),
    VariableModel(
      name: 'Fio da Navalha Inferior', 
      unit: 'mm', 
      type: 'number', 
      min: 4.5, 
      max: 5.5
    ),
    VariableModel(
      name: 'Fio da Navalha Superior', 
      unit: 'mm', 
      type: 'number', 
      min: 5.5, 
      max: 6.5
    ),
  ],
);

// REBAIXADEIRA
StageModel rebaixadeiraStage() => const StageModel(
  code: 'REBAIXADEIRA',
  title: 'REBAIXADEIRA',
  icon: Icons.straighten,
  color: Color(0xFF546E7A), // Azul acinzentado
  notes: 'Espessura de Rebaixe: 1.2/1.3+1.2',
  variables: [
    VariableModel(
      name: 'Velocidade do Rolo de Transporte', 
      unit: 'mt/min', 
      type: 'number', 
      min: 10, 
      max: 12,
      hint: 'Previsto: 10/12'
    ),
  ],
);

// REFILA
StageModel refilaStage() => const StageModel(
  code: 'REFILA',
  title: 'REFILA',
  icon: Icons.scale,
  color: Color(0xFF546E7A), // Azul acinzentado
  variables: [
    VariableModel(
      name: 'Peso Líquido', 
      unit: 'KG', 
      type: 'number'
    ),
    VariableModel(
      name: 'Peso do Refile', 
      unit: 'KG', 
      type: 'number'
    ),
    VariableModel(
      name: 'Peso do Cupim', 
      unit: 'KG', 
      type: 'number'
    ),
  ],
);
