import 'package:flutter/material.dart';

class StageData {
  final String stageCode;
  final Map<String, dynamic> data;
  final bool finalizado;
  final DateTime? dataFinalizacao;

  StageData({
    required this.stageCode,
    required this.data,
    this.finalizado = false,
    this.dataFinalizacao,
  });

  StageData copyWith({
    Map<String, dynamic>? data,
    bool? finalizado,
    DateTime? dataFinalizacao,
  }) {
    return StageData(
      stageCode: stageCode,
      data: data ?? this.data,
      finalizado: finalizado ?? this.finalizado,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
    );
  }
}

class StageDataManager extends ChangeNotifier {
  final Map<String, StageData> _stages = {};

  // Pega os dados de um estágio específico
  StageData? getStageData(String stageCode) {
    return _stages[stageCode];
  }

  // Verifica se um estágio está finalizado
  bool isStageFinished(String stageCode) {
    return _stages[stageCode]?.finalizado ?? false;
  }

  // Salva os dados de um estágio
  void saveStageData(String stageCode, Map<String, dynamic> data, {bool finalizar = true}) {
    _stages[stageCode] = StageData(
      stageCode: stageCode,
      data: data,
      finalizado: finalizar,
      dataFinalizacao: finalizar ? DateTime.now() : null,
    );
    notifyListeners();
  }

  // Limpa os dados de um estágio específico
  void clearStage(String stageCode) {
    _stages.remove(stageCode);
    notifyListeners();
  }

  // Limpa todos os dados
  void clearAll() {
    _stages.clear();
    notifyListeners();
  }

  // Pega todos os dados de todos os estágios (para enviar ao servidor, por exemplo)
  Map<String, Map<String, dynamic>> getAllData() {
    return _stages.map((key, value) => MapEntry(key, value.data));
  }

  // Verifica quantos estágios foram finalizados
  int getFinishedCount() {
    return _stages.values.where((stage) => stage.finalizado).length;
  }
}
