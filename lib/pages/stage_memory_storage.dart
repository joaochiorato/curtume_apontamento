import '../models/stage.dart';

/// Sistema de armazenamento com controle de quantidade processada
class StageMemoryStorage {
  static final StageMemoryStorage _instance = StageMemoryStorage._internal();
  factory StageMemoryStorage() => _instance;
  StageMemoryStorage._internal();

  // Armazena todos os apontamentos de cada estágio
  final Map<String, List<Map<String, dynamic>>> _apontamentos = {};
  final Map<String, bool> _finalized = {};
  
  // Quantidade total da OF (passa no construtor da página)
  int _quantidadeTotal = 0;

  /// Define a quantidade total da OF/Artigo
  void setQuantidadeTotal(int quantidade) {
    _quantidadeTotal = quantidade;
  }

  /// Retorna a quantidade total configurada
  int getQuantidadeTotal() => _quantidadeTotal;

  /// Salva um novo apontamento no estágio
  void saveData(String stageCode, Map<String, dynamic> data, {bool finalizar = false}) {
    if (!_apontamentos.containsKey(stageCode)) {
      _apontamentos[stageCode] = [];
    }
    
    // Adiciona timestamp ao apontamento
    data['timestamp'] = DateTime.now().toIso8601String();
    _apontamentos[stageCode]!.add(data);
    
    if (finalizar) {
      _finalized[stageCode] = true;
    }
  }

  /// Retorna todos os apontamentos de um estágio
  List<Map<String, dynamic>> getApontamentos(String stageCode) {
    return _apontamentos[stageCode] ?? [];
  }

  /// Retorna o último apontamento (para edição/visualização)
  Map<String, dynamic>? getLastData(String stageCode) {
    final apontamentos = _apontamentos[stageCode];
    if (apontamentos == null || apontamentos.isEmpty) return null;
    return apontamentos.last;
  }

  /// Calcula quantidade total processada no estágio
  int getQuantidadeProcessada(String stageCode) {
    final apontamentos = _apontamentos[stageCode];
    if (apontamentos == null || apontamentos.isEmpty) return 0;

    int total = 0;
    for (final apt in apontamentos) {
      final qtd = apt['qtdProcessada'];
      if (qtd is int) {
        total += qtd;
      } else if (qtd is String) {
        total += int.tryParse(qtd) ?? 0;
      }
    }
    return total;
  }

  /// Calcula quanto ainda falta processar no estágio
  int getQuantidadeRestante(String stageCode) {
    final processada = getQuantidadeProcessada(stageCode);
    return _quantidadeTotal - processada;
  }

  /// Retorna percentual processado (0 a 100)
  double getPercentualProcessado(String stageCode) {
    if (_quantidadeTotal == 0) return 0;
    final processada = getQuantidadeProcessada(stageCode);
    return (processada / _quantidadeTotal) * 100;
  }

  /// Verifica se o estágio está completo
  bool isStageComplete(String stageCode) {
    return getQuantidadeProcessada(stageCode) >= _quantidadeTotal;
  }

  /// Verifica se pode adicionar mais apontamentos
  bool canAddMore(String stageCode) {
    return getQuantidadeRestante(stageCode) > 0;
  }

  /// Retorna informações consolidadas do estágio
  Map<String, dynamic> getStageInfo(String stageCode) {
    return {
      'total': _quantidadeTotal,
      'processada': getQuantidadeProcessada(stageCode),
      'restante': getQuantidadeRestante(stageCode),
      'percentual': getPercentualProcessado(stageCode),
      'completo': isStageComplete(stageCode),
      'apontamentos': getApontamentos(stageCode).length,
    };
  }

  bool isFinalized(String stageCode) => _finalized[stageCode] ?? false;
  
  int getFinishedCount() => _finalized.values.where((f) => f).length;
  
  void clear(String stageCode) {
    _apontamentos.remove(stageCode);
    _finalized.remove(stageCode);
  }
  
  void clearAll() {
    _apontamentos.clear();
    _finalized.clear();
  }

  /// Debug: Imprime resumo de todos os estágios
  void printSummary() {
    print('═══════════════════════════════════════');
    print('RESUMO DA OF - Total: $_quantidadeTotal peles');
    print('═══════════════════════════════════════');
    
    for (final stageCode in availableStages.map((s) => s.code)) {
      final info = getStageInfo(stageCode);
      print('$stageCode:');
      print('  Processada: ${info['processada']} / ${info['total']}');
      print('  Restante: ${info['restante']}');
      print('  Percentual: ${info['percentual'].toStringAsFixed(1)}%');
      print('  Apontamentos: ${info['apontamentos']}');
      print('  Status: ${info['completo'] ? '✓ COMPLETO' : '⧗ EM ANDAMENTO'}');
      print('───────────────────────────────────────');
    }
  }
}
