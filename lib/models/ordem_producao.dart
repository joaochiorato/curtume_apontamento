import 'package:flutter/foundation.dart';

/// 🎯 Status da Ordem de Produção
enum StatusOrdem {
  aguardando('Aguardando', 'grey'),
  emProducao('Em Produção', 'blue'),
  finalizado('Finalizado', 'green'),
  cancelado('Cancelado', 'red');

  final String label;
  final String cor;
  const StatusOrdem(this.label, this.cor);
}

/// 📦 Modelo da Ordem de Produção
class OrdemProducao {
  final String id;
  final String numeroOf;
  final String artigo;
  final String pve;
  final String cor;
  final String crustItem;
  final String espFinal;
  final String classe;
  final String po;
  final String loteWetBlue;
  final int numeroPecasNF;
  final double metragemNF;
  final double avg;
  final int numeroPecasEnx;
  final double metragemEnx;
  final double pesoLiquido;
  final double? diferencaPercentual;
  final DateTime dataCriacao;
  StatusOrdem status;
  
  /// Lista de estágios do processo
  final List<Estagio> estagios;
  
  OrdemProducao({
    required this.id,
    required this.numeroOf,
    required this.artigo,
    required this.pve,
    required this.cor,
    required this.crustItem,
    required this.espFinal,
    required this.classe,
    required this.po,
    required this.loteWetBlue,
    required this.numeroPecasNF,
    required this.metragemNF,
    required this.avg,
    required this.numeroPecasEnx,
    required this.metragemEnx,
    required this.pesoLiquido,
    this.diferencaPercentual,
    required this.dataCriacao,
    this.status = StatusOrdem.aguardando,
    required this.estagios,
  });

  /// Calcula o progresso total da ordem (0.0 a 1.0)
  double get progresso {
    if (estagios.isEmpty) return 0.0;
    final concluidos = estagios.where((e) => e.isConcluido).length;
    return concluidos / estagios.length;
  }

  /// Retorna o total de peças processadas
  int get totalProcessado {
    return estagios
        .map((e) => e.quantidadeProcessada)
        .fold(0, (a, b) => a + b);
  }

  /// Verifica se a ordem está completa
  bool get isCompleta => estagios.every((e) => e.isConcluido);

  OrdemProducao copyWith({
    StatusOrdem? status,
    List<Estagio>? estagios,
  }) {
    return OrdemProducao(
      id: id,
      numeroOf: numeroOf,
      artigo: artigo,
      pve: pve,
      cor: cor,
      crustItem: crustItem,
      espFinal: espFinal,
      classe: classe,
      po: po,
      loteWetBlue: loteWetBlue,
      numeroPecasNF: numeroPecasNF,
      metragemNF: metragemNF,
      avg: avg,
      numeroPecasEnx: numeroPecasEnx,
      metragemEnx: metragemEnx,
      pesoLiquido: pesoLiquido,
      diferencaPercentual: diferencaPercentual,
      dataCriacao: dataCriacao,
      status: status ?? this.status,
      estagios: estagios ?? this.estagios,
    );
  }
}

/// 🏭 Modelo de Estágio do Processo
class Estagio {
  final String id;
  final String nome;
  final int ordem;
  final int quantidadeTotal;
  int quantidadeProcessada;
  DateTime? dataInicio;
  DateTime? dataTermino;
  String? responsavel;
  String? responsavelSuperior;
  final List<VariavelControle> variaveisControle;
  final Map<String, dynamic> dadosAdicionais;

  Estagio({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.quantidadeTotal,
    this.quantidadeProcessada = 0,
    this.dataInicio,
    this.dataTermino,
    this.responsavel,
    this.responsavelSuperior,
    this.variaveisControle = const [],
    this.dadosAdicionais = const {},
  });

  bool get isConcluido => quantidadeProcessada >= quantidadeTotal;
  bool get isIniciado => dataInicio != null;
  double get progresso => quantidadeProcessada / quantidadeTotal;

  Estagio copyWith({
    int? quantidadeProcessada,
    DateTime? dataInicio,
    DateTime? dataTermino,
    String? responsavel,
    String? responsavelSuperior,
    List<VariavelControle>? variaveisControle,
    Map<String, dynamic>? dadosAdicionais,
  }) {
    return Estagio(
      id: id,
      nome: nome,
      ordem: ordem,
      quantidadeTotal: quantidadeTotal,
      quantidadeProcessada: quantidadeProcessada ?? this.quantidadeProcessada,
      dataInicio: dataInicio ?? this.dataInicio,
      dataTermino: dataTermino ?? this.dataTermino,
      responsavel: responsavel ?? this.responsavel,
      responsavelSuperior: responsavelSuperior ?? this.responsavelSuperior,
      variaveisControle: variaveisControle ?? this.variaveisControle,
      dadosAdicionais: dadosAdicionais ?? this.dadosAdicionais,
    );
  }
}

/// 📊 Variável de Controle do Processo
class VariavelControle {
  final String nome;
  final String unidade;
  final String? padrao;
  final dynamic valorMinimo;
  final dynamic valorMaximo;
  dynamic resultado;

  VariavelControle({
    required this.nome,
    required this.unidade,
    this.padrao,
    this.valorMinimo,
    this.valorMaximo,
    this.resultado,
  });

  bool get isDentroLimite {
    if (resultado == null) return false;
    if (valorMinimo != null && resultado < valorMinimo) return false;
    if (valorMaximo != null && resultado > valorMaximo) return false;
    return true;
  }

  VariavelControle copyWith({
    dynamic resultado,
  }) {
    return VariavelControle(
      nome: nome,
      unidade: unidade,
      padrao: padrao,
      valorMinimo: valorMinimo,
      valorMaximo: valorMaximo,
      resultado: resultado ?? this.resultado,
    );
  }
}
