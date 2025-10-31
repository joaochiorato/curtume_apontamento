import 'status_ordem.dart';

class OrdemModel {
  final String of;
  final String cliente;
  final DateTime data;
  StatusOrdem status;
  final List<ArtigoModel> artigos;
  
  // Controle de apontamentos
  int apontamentosIniciados;
  int apontamentosFinalizados;
  DateTime? dataInicio;
  DateTime? dataFinalizacao;

  OrdemModel({
    required this.of,
    required this.cliente,
    required this.data,
    StatusOrdem? status,
    required this.artigos,
    this.apontamentosIniciados = 0,
    this.apontamentosFinalizados = 0,
    this.dataInicio,
    this.dataFinalizacao,
  }) : status = status ?? StatusOrdem.aguardando;

  // 🎯 MÉTODOS DE CONTROLE DE STATUS

  /// Inicia um apontamento - muda status para "Em Produção" se necessário
  void iniciarApontamento() {
    if (status == StatusOrdem.aguardando) {
      status = StatusOrdem.emProducao;
      dataInicio = DateTime.now();
    }
    apontamentosIniciados++;
  }

  /// Finaliza um apontamento - muda status para "Finalizado" se todos concluídos
  void finalizarApontamento() {
    apontamentosFinalizados++;
    
    // Se todos os artigos tiverem apontamentos finalizados
    if (apontamentosFinalizados >= artigos.length) {
      status = StatusOrdem.finalizado;
      dataFinalizacao = DateTime.now();
    }
  }

  /// Cancela a ordem
  void cancelar() {
    if (status.podeTransitarPara(StatusOrdem.cancelado)) {
      status = StatusOrdem.cancelado;
      dataFinalizacao = DateTime.now();
    }
  }

  /// Verifica se a ordem está em um estado final
  bool get isFinal => status == StatusOrdem.finalizado || 
                      status == StatusOrdem.cancelado;

  /// Verifica se pode iniciar novos apontamentos
  bool get podeIniciarApontamento => 
      status == StatusOrdem.aguardando || 
      status == StatusOrdem.emProducao;

  /// Percentual de conclusão (baseado em apontamentos finalizados)
  double get percentualConclusao {
    if (artigos.isEmpty) return 0.0;
    return (apontamentosFinalizados / artigos.length).clamp(0.0, 1.0);
  }

  /// Tempo decorrido desde o início (se aplicável)
  Duration? get tempoDecorrido {
    if (dataInicio == null) return null;
    final fim = dataFinalizacao ?? DateTime.now();
    return fim.difference(dataInicio!);
  }

  // 📊 INFORMAÇÕES DE PROGRESSO

  String get statusTexto => status.textoStatus;

  String get infoProgresso {
    if (status == StatusOrdem.aguardando) {
      return 'Nenhum apontamento iniciado';
    } else if (status == StatusOrdem.emProducao) {
      return '$apontamentosFinalizados/${artigos.length} artigos concluídos';
    } else if (status == StatusOrdem.finalizado) {
      return 'Todos os artigos finalizados';
    } else {
      return 'Ordem cancelada';
    }
  }

  // 🔄 CONVERSÃO PARA/DE MAP (para persistência)

  Map<String, dynamic> toMap() {
    return {
      'of': of,
      'cliente': cliente,
      'data': data.toIso8601String(),
      'status': status.name,
      'artigos': artigos.map((a) => a.toMap()).toList(),
      'apontamentosIniciados': apontamentosIniciados,
      'apontamentosFinalizados': apontamentosFinalizados,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFinalizacao': dataFinalizacao?.toIso8601String(),
    };
  }

  factory OrdemModel.fromMap(Map<String, dynamic> map) {
    return OrdemModel(
      of: map['of'],
      cliente: map['cliente'],
      data: DateTime.parse(map['data']),
      status: StatusOrdem.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusOrdem.aguardando,
      ),
      artigos: (map['artigos'] as List)
          .map((a) => ArtigoModel.fromMap(a))
          .toList(),
      apontamentosIniciados: map['apontamentosIniciados'] ?? 0,
      apontamentosFinalizados: map['apontamentosFinalizados'] ?? 0,
      dataInicio: map['dataInicio'] != null 
          ? DateTime.parse(map['dataInicio']) 
          : null,
      dataFinalizacao: map['dataFinalizacao'] != null 
          ? DateTime.parse(map['dataFinalizacao']) 
          : null,
    );
  }

  // 📝 CÓPIA COM MODIFICAÇÕES
  OrdemModel copyWith({
    String? of,
    String? cliente,
    DateTime? data,
    StatusOrdem? status,
    List<ArtigoModel>? artigos,
    int? apontamentosIniciados,
    int? apontamentosFinalizados,
    DateTime? dataInicio,
    DateTime? dataFinalizacao,
  }) {
    return OrdemModel(
      of: of ?? this.of,
      cliente: cliente ?? this.cliente,
      data: data ?? this.data,
      status: status ?? this.status,
      artigos: artigos ?? this.artigos,
      apontamentosIniciados: apontamentosIniciados ?? this.apontamentosIniciados,
      apontamentosFinalizados: apontamentosFinalizados ?? this.apontamentosFinalizados,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
    );
  }
}

// 📦 MODELO DE ARTIGO - BASEADO NA OF 18283 QUARTZO

class ArtigoModel {
  final String codigo;
  final String descricao;
  final int quantidade;
  
  // Dados específicos do artigo (do PDF)
  final String? pve;
  final String? cor;
  final String? classe;
  final String? po;
  final String? crustItem;
  final String? espFinal;
  final String? loteWetBlue;
  final double? metragemNF;
  final double? avg;
  final double? pesoLiquido;
  
  bool apontamentoIniciado;
  bool apontamentoFinalizado;
  DateTime? dataInicioApontamento;
  DateTime? dataFimApontamento;

  ArtigoModel({
    required this.codigo,
    required this.descricao,
    required this.quantidade,
    this.pve,
    this.cor,
    this.classe,
    this.po,
    this.crustItem,
    this.espFinal,
    this.loteWetBlue,
    this.metragemNF,
    this.avg,
    this.pesoLiquido,
    this.apontamentoIniciado = false,
    this.apontamentoFinalizado = false,
    this.dataInicioApontamento,
    this.dataFimApontamento,
  });

  // Marca que o apontamento deste artigo foi iniciado
  void iniciarApontamento() {
    apontamentoIniciado = true;
    dataInicioApontamento = DateTime.now();
  }

  // Marca que o apontamento deste artigo foi finalizado
  void finalizarApontamento() {
    apontamentoFinalizado = true;
    dataFimApontamento = DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'quantidade': quantidade,
      'pve': pve,
      'cor': cor,
      'classe': classe,
      'po': po,
      'crustItem': crustItem,
      'espFinal': espFinal,
      'loteWetBlue': loteWetBlue,
      'metragemNF': metragemNF,
      'avg': avg,
      'pesoLiquido': pesoLiquido,
      'apontamentoIniciado': apontamentoIniciado,
      'apontamentoFinalizado': apontamentoFinalizado,
      'dataInicioApontamento': dataInicioApontamento?.toIso8601String(),
      'dataFimApontamento': dataFimApontamento?.toIso8601String(),
    };
  }

  factory ArtigoModel.fromMap(Map<String, dynamic> map) {
    return ArtigoModel(
      codigo: map['codigo'],
      descricao: map['descricao'],
      quantidade: map['quantidade'],
      pve: map['pve'],
      cor: map['cor'],
      classe: map['classe'],
      po: map['po'],
      crustItem: map['crustItem'],
      espFinal: map['espFinal'],
      loteWetBlue: map['loteWetBlue'],
      metragemNF: map['metragemNF'],
      avg: map['avg'],
      pesoLiquido: map['pesoLiquido'],
      apontamentoIniciado: map['apontamentoIniciado'] ?? false,
      apontamentoFinalizado: map['apontamentoFinalizado'] ?? false,
      dataInicioApontamento: map['dataInicioApontamento'] != null
          ? DateTime.parse(map['dataInicioApontamento'])
          : null,
      dataFimApontamento: map['dataFimApontamento'] != null
          ? DateTime.parse(map['dataFimApontamento'])
          : null,
    );
  }

  // 📝 Factory para criar artigo da OF 18283 QUARTZO (do PDF)
  factory ArtigoModel.of18283Quartzo() {
    return ArtigoModel(
      codigo: 'QUARTZO',
      descricao: 'QUARTZO',
      quantidade: 350, // Nº PÇS NF
      pve: '7315',
      cor: 'E - BROWN',
      classe: 'G119',
      po: '7315CK08',
      crustItem: '1165',
      espFinal: '1.1/1.5',
      loteWetBlue: '32666',
      metragemNF: 21295.25,
      avg: 60.84,
      pesoLiquido: 9855.00,
    );
  }
}
