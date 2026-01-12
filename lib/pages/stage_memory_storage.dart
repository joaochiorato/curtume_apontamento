import '../models/stage.dart';
import '../models/formulacoes_model.dart';

/// Status possíveis de um estágio na tela de listagem
enum StageProgressStatus {
  Aguardando, // Não iniciou
  emProducao, // Iniciado e rodando
  parado, // Em pausa durante apontamento
  encerrado, // Após salvar apontamento (aguardando novo)
  finalizado, // Todas as peles processadas
}

/// ✅ Dados parciais do formulário em andamento (sem campo responsavel)
class StageFormData {
  String? responsavelSuperior;
  int? quantidade;
  String? observacao;
  Map<String, String>? variaveis;
  QuimicosFormulacaoData? quimicos;

  StageFormData({
    this.responsavelSuperior,
    this.quantidade,
    this.observacao,
    this.variaveis,
    this.quimicos,
  });

  Map<String, dynamic> toMap() {
    return {
      'responsavelSuperior': responsavelSuperior,
      'quantidade': quantidade,
      'observacao': observacao,
      'variaveis': variaveis,
      'quimicos': quimicos?.toJson(),
    };
  }

  factory StageFormData.fromMap(Map<String, dynamic> map) {
    return StageFormData(
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
  final Map<String, DateTime?> _stageLastResumeTime =
      {}; // ✅ Momento que retomou
  final Map<String, StageFormData> _stageFormData = {};
  int _quantidadeTotal = 0;

  void setQuantidadeTotal(int qtd) {
    _quantidadeTotal = qtd;
  }

  int getQuantidadeTotal() => _quantidadeTotal;

  StageProgressStatus getStageStatus(String stageCode) {
    return _stageStatus[stageCode] ?? StageProgressStatus.Aguardando;
  }

  void setStageStatus(String stageCode, StageProgressStatus status) {
    _stageStatus[stageCode] = status;
  }

  DateTime? getStageStartTime(String stageCode) {
    return _stageStartTime[stageCode];
  }

  void setStageStartTime(String stageCode, DateTime? time) {
    _stageStartTime[stageCode] = time;
  }

  Duration getStageElapsedTime(String stageCode) {
    return _stageElapsedTime[stageCode] ?? Duration.zero;
  }

  void setStageElapsedTime(String stageCode, Duration elapsed) {
    _stageElapsedTime[stageCode] = elapsed;
  }

  // ✅ Momento que o timer foi retomado/iniciado
  DateTime? getStageLastResumeTime(String stageCode) {
    return _stageLastResumeTime[stageCode];
  }

  void setStageLastResumeTime(String stageCode, DateTime? time) {
    _stageLastResumeTime[stageCode] = time;
  }

  StageFormData? getStageFormData(String stageCode) {
    return _stageFormData[stageCode];
  }

  void setStageFormData(String stageCode, StageFormData data) {
    _stageFormData[stageCode] = data;
  }

  void updateStageFormData(
    String stageCode, {
    String? responsavelSuperior,
    int? quantidade,
    String? observacao,
    Map<String, String>? variaveis,
    QuimicosFormulacaoData? quimicos,
  }) {
    final current = _stageFormData[stageCode] ?? StageFormData();
    _stageFormData[stageCode] = StageFormData(
      responsavelSuperior: responsavelSuperior ?? current.responsavelSuperior,
      quantidade: quantidade ?? current.quantidade,
      observacao: observacao ?? current.observacao,
      variaveis: variaveis ?? current.variaveis,
      quimicos: quimicos ?? current.quimicos,
    );
  }

  /// Salva um novo apontamento
  void saveData(String stageCode, Map<String, dynamic> data,
      {bool finalizar = false}) {
    _apontamentos.putIfAbsent(stageCode, () => []);
    _apontamentos[stageCode]!.add(Map<String, dynamic>.from(data));

    // ✅ Só marca como finalizado se completou TODAS as peles
    final processada = getQuantidadeProcessada(stageCode);
    if (processada >= _quantidadeTotal) {
      _finalized[stageCode] = true;
      _stageStatus[stageCode] = StageProgressStatus.finalizado;
    } else {
      // Se ainda não finalizou mas já tem apontamento, muda status para "encerrado"
      // (aguardando mais apontamentos)
      _stageStatus[stageCode] = StageProgressStatus.encerrado;
    }

    // Limpar apenas os dados temporários do formulário, mantendo o status
    _clearStageProgressData(stageCode);
  }

  /// Limpa os dados temporários do formulário, mantendo o status do estágio
  void _clearStageProgressData(String stageCode) {
    _stageStartTime.remove(stageCode);
    _stageElapsedTime.remove(stageCode);
    _stageLastResumeTime.remove(stageCode);
    _stageFormData.remove(stageCode);
  }

  /// Limpa completamente o estágio, incluindo o status
  void _clearStageProgress(String stageCode) {
    _stageStatus[stageCode] = StageProgressStatus.Aguardando;
    _stageStartTime.remove(stageCode);
    _stageElapsedTime.remove(stageCode);
    _stageLastResumeTime.remove(stageCode); // ✅ Limpar
    _stageFormData.remove(stageCode);
  }

  /// ✅ Atualiza um apontamento existente
  void updateApontamento(
      String stageCode, int index, Map<String, dynamic> newData) {
    if (_apontamentos.containsKey(stageCode) &&
        index >= 0 &&
        index < _apontamentos[stageCode]!.length) {
      _apontamentos[stageCode]![index] = Map<String, dynamic>.from(newData);

      // Recalcular se o estágio está completo
      final processada = getQuantidadeProcessada(stageCode);
      if (processada >= _quantidadeTotal) {
        _finalized[stageCode] = true;
        _stageStatus[stageCode] = StageProgressStatus.finalizado;
      } else {
        _finalized[stageCode] = false;
        // Se ainda tem apontamentos mas não finalizou, mantém como "encerrado"
        if (_apontamentos[stageCode]!.isNotEmpty) {
          _stageStatus[stageCode] = StageProgressStatus.encerrado;
        }
      }
    }
  }

  /// ✅ Remove um apontamento
  void removeApontamento(String stageCode, int index) {
    if (_apontamentos.containsKey(stageCode) &&
        index >= 0 &&
        index < _apontamentos[stageCode]!.length) {
      _apontamentos[stageCode]!.removeAt(index);

      final processada = getQuantidadeProcessada(stageCode);
      if (processada >= _quantidadeTotal) {
        _finalized[stageCode] = true;
        _stageStatus[stageCode] = StageProgressStatus.finalizado;
      } else {
        _finalized[stageCode] = false;
        // Se ainda tem apontamentos, mantém como "encerrado", senão volta para "Aguardando"
        if (_apontamentos[stageCode]!.isNotEmpty) {
          _stageStatus[stageCode] = StageProgressStatus.encerrado;
        } else {
          _stageStatus[stageCode] = StageProgressStatus.Aguardando;
        }
      }
    }
  }

  Map<String, dynamic>? getLastData(String stageCode) {
    final list = _apontamentos[stageCode];
    if (list != null && list.isNotEmpty) {
      return list.last;
    }
    return null;
  }

  List<Map<String, dynamic>> getApontamentos(String stageCode) {
    return List.unmodifiable(_apontamentos[stageCode] ?? []);
  }

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

  int getQuantidadeRestante(String stageCode) {
    final processada = getQuantidadeProcessada(stageCode);
    return _quantidadeTotal - processada;
  }

  double getPercentualProcessado(String stageCode) {
    if (_quantidadeTotal == 0) return 0;
    final processada = getQuantidadeProcessada(stageCode);
    return (processada / _quantidadeTotal) * 100;
  }

  bool isStageComplete(String stageCode) {
    return getQuantidadeProcessada(stageCode) >= _quantidadeTotal;
  }

  bool canAddMore(String stageCode) {
    return getQuantidadeRestante(stageCode) > 0;
  }

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
      'lastResumeTime': getStageLastResumeTime(stageCode), // ✅ Adicionado
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
    _stageLastResumeTime.remove(stageCode); // ✅ Limpar
    _stageFormData.remove(stageCode);
  }

  void clearAll() {
    _apontamentos.clear();
    _finalized.clear();
    _stageStatus.clear();
    _stageStartTime.clear();
    _stageElapsedTime.clear();
    _stageLastResumeTime.clear(); // ✅ Limpar
    _stageFormData.clear();
  }

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
