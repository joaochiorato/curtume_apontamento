import '../models/stage.dart';
import '../models/formulacoes_model.dart';

/// Status possíveis de um estágio na tela de listagem
enum StageProgressStatus {
  aguardando,  // Não iniciou
  emProducao,  // Iniciado e rodando
  parado,      // Em pausa
  finalizado,  // Encerrado
}

/// ✅ Dados parciais do formulário em andamento
class StageFormData {
  String? responsavel;
  String? responsavelSuperior;
  int? quantidade;
  String? observacao;
  Map<String, String>? variaveis;
  QuimicosFormulacaoData? quimicos;

  StageFormData({
    this.responsavel,
    this.responsavelSuperior,
    this.quantidade,
    this.observacao,
    this.variaveis,
    this.quimicos,
  });

  Map<String, dynamic> toMap() {
    return {
      'responsavel': responsavel,
      'responsavelSuperior': responsavelSuperior,
      'quantidade': quantidade,
      'observacao': observacao,
      'variaveis': variaveis,
      'quimicos': quimicos?.toJson(),
    };
  }

  factory StageFormData.fromMap(Map<String, dynamic> map) {
    return StageFormData(
      responsavel: map['responsavel'],
      responsavelSuperior: map['responsavelSuperior'],
      quantidade: map['quantidade'],
      observacao: map['observacao'],
      variaveis: map['variaveis'] != null 
          ? Map<String, String>.from(map['variaveis']) 
          : null,
      quimicos: map['quimicos'] != null 
          ? QuimicosFormulacaoData.fromJson(map['quimicos']) 
          : null,
    );
  }
}

/// Armazenamento em memória para apontamentos dos estágios
class StageMemoryStorage {
  final Map<String, List<Map<String, dynamic>>> _apontamentos = {};
  final Map<String, bool> _finalized = {};
  final Map<String, StageProgressStatus> _stageStatus = {};
  final Map<String, DateTime?> _stageStartTime = {};
  final Map<String, Duration> _stageElapsedTime = {};
  final Map<String, StageFormData> _stageFormData = {}; // ✅ Dados parciais do formulário
  int _quantidadeTotal = 0;

  void setQuantidadeTotal(int qtd) {
    _quantidadeTotal = qtd;
  }

  int getQuantidadeTotal() => _quantidadeTotal;

  // ✅ Status do estágio
  StageProgressStatus getStageStatus(String stageCode) {
    return _stageStatus[stageCode] ?? StageProgressStatus.aguardando;
  }

  void setStageStatus(String stageCode, StageProgressStatus status) {
    _stageStatus[stageCode] = status;
  }

  // ✅ Tempo de início do estágio
  DateTime? getStageStartTime(String stageCode) {
    return _stageStartTime[stageCode];
  }

  void setStageStartTime(String stageCode, DateTime? time) {
    _stageStartTime[stageCode] = time;
  }

  // ✅ Tempo decorrido do estágio
  Duration getStageElapsedTime(String stageCode) {
    return _stageElapsedTime[stageCode] ?? Duration.zero;
  }

  void setStageElapsedTime(String stageCode, Duration elapsed) {
    _stageElapsedTime[stageCode] = elapsed;
  }

  // ✅ Dados parciais do formulário
  StageFormData? getStageFormData(String stageCode) {
    return _stageFormData[stageCode];
  }

  void setStageFormData(String stageCode, StageFormData data) {
    _stageFormData[stageCode] = data;
  }

  void updateStageFormData(String stageCode, {
    String? responsavel,
    String? responsavelSuperior,
    int? quantidade,
    String? observacao,
    Map<String, String>? variaveis,
    QuimicosFormulacaoData? quimicos,
  }) {
    final current = _stageFormData[stageCode] ?? StageFormData();
    _stageFormData[stageCode] = StageFormData(
      responsavel: responsavel ?? current.responsavel,
      responsavelSuperior: responsavelSuperior ?? current.responsavelSuperior,
      quantidade: quantidade ?? current.quantidade,
      observacao: observacao ?? current.observacao,
      variaveis: variaveis ?? current.variaveis,
      quimicos: quimicos ?? current.quimicos,
    );
  }

  /// Salva um novo apontamento
  void saveData(String stageCode, Map<String, dynamic> data, {bool finalizar = false}) {
    _apontamentos.putIfAbsent(stageCode, () => []);
    _apontamentos[stageCode]!.add(Map<String, dynamic>.from(data));
    
    if (finalizar) {
      _finalized[stageCode] = true;
      _stageStatus[stageCode] = StageProgressStatus.finalizado;
    }
    
    // Limpar estado do estágio após salvar apontamento
    _clearStageProgress(stageCode);
  }

  // ✅ Limpa o progresso do estágio (após salvar)
  void _clearStageProgress(String stageCode) {
    _stageStatus[stageCode] = StageProgressStatus.aguardando;
    _stageStartTime.remove(stageCode);
    _stageElapsedTime.remove(stageCode);
    _stageFormData.remove(stageCode); // ✅ Limpa dados parciais
  }

  /// ✅ Atualiza um apontamento existente
  void updateApontamento(String stageCode, int index, Map<String, dynamic> newData) {
    if (_apontamentos.containsKey(stageCode) && 
        index >= 0 && 
        index < _apontamentos[stageCode]!.length) {
      _apontamentos[stageCode]![index] = Map<String, dynamic>.from(newData);
      
      // Recalcular se o estágio está completo
      final processada = getQuantidadeProcessada(stageCode);
      if (processada >= _quantidadeTotal) {
        _finalized[stageCode] = true;
        _stageStatus[stageCode] = StageProgressStatus.finalizado;
      }
    }
  }

  /// ✅ Remove um apontamento
  void removeApontamento(String stageCode, int index) {
    if (_apontamentos.containsKey(stageCode) && 
        index >= 0 && 
        index < _apontamentos[stageCode]!.length) {
      _apontamentos[stageCode]!.removeAt(index);
      
      // Recalcular se o estágio está completo
      final processada = getQuantidadeProcessada(stageCode);
      if (processada >= _quantidadeTotal) {
        _finalized[stageCode] = true;
        _stageStatus[stageCode] = StageProgressStatus.finalizado;
      } else {
        _finalized[stageCode] = false;
      }
    }
  }

  /// Retorna o último dado salvo para pré-preencher o formulário
  Map<String, dynamic>? getLastData(String stageCode) {
    final list = _apontamentos[stageCode];
    if (list != null && list.isNotEmpty) {
      return list.last;
    }
    return null;
  }

  /// Retorna todos os apontamentos de um estágio
  List<Map<String, dynamic>> getApontamentos(String stageCode) {
    return List.unmodifiable(_apontamentos[stageCode] ?? []);
  }

  /// Calcula o total de quantidade já processada no estágio
  int getQuantidadeProcessada(String stageCode) {
    final list = _apontamentos[stageCode];
    if (list == null || list.isEmpty) return 0;
    
    int total = 0;
    for (final apt in list) {
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
      'status': getStageStatus(stageCode),
      'startTime': getStageStartTime(stageCode),
      'elapsedTime': getStageElapsedTime(stageCode),
      'formData': getStageFormData(stageCode),
    };
  }

  bool isFinalized(String stageCode) => _finalized[stageCode] ?? false;
  
  int getFinishedCount() => _finalized.values.where((f) => f).length;
  
  void clear(String stageCode) {
    _apontamentos.remove(stageCode);
    _finalized.remove(stageCode);
    _stageStatus.remove(stageCode);
    _stageStartTime.remove(stageCode);
    _stageElapsedTime.remove(stageCode);
    _stageFormData.remove(stageCode);
  }
  
  void clearAll() {
    _apontamentos.clear();
    _finalized.clear();
    _stageStatus.clear();
    _stageStartTime.clear();
    _stageElapsedTime.clear();
    _stageFormData.clear();
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
      print('  Status: ${info['status']}');
      print('───────────────────────────────────────');
    }
  }
}