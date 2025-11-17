/// Tipos de eventos que podem ocorrer em um apontamento
enum TipoEvento {
  iniciado,
  pausado,
  encerrado,
  reaberto,
  alterado,
}

/// Representa um evento ocorrido durante um apontamento
class ApontamentoEvento {
  final String id;
  final TipoEvento tipo;
  final DateTime dataHora;
  final String? responsavel;
  final String? observacao;
  final Map<String, dynamic>? dadosAdicionais;

  ApontamentoEvento({
    required this.id,
    required this.tipo,
    required this.dataHora,
    this.responsavel,
    this.observacao,
    this.dadosAdicionais,
  });

  /// Retorna o nome do evento em português
  String get nomeEvento {
    switch (tipo) {
      case TipoEvento.iniciado:
        return 'Iniciado';
      case TipoEvento.pausado:
        return 'Pausado';
      case TipoEvento.encerrado:
        return 'Encerrado';
      case TipoEvento.reaberto:
        return 'Reaberto';
      case TipoEvento.alterado:
        return 'Alterado';
    }
  }

  /// Retorna o ícone do evento
  String get iconeEvento {
    switch (tipo) {
      case TipoEvento.iniciado:
        return '▶️';
      case TipoEvento.pausado:
        return '⏸️';
      case TipoEvento.encerrado:
        return '✅';
      case TipoEvento.reaberto:
        return '🔄';
      case TipoEvento.alterado:
        return '✏️';
    }
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.name,
      'dataHora': dataHora.toIso8601String(),
      'responsavel': responsavel,
      'observacao': observacao,
      'dadosAdicionais': dadosAdicionais,
    };
  }

  /// Cria a partir de JSON
  factory ApontamentoEvento.fromJson(Map<String, dynamic> json) {
    return ApontamentoEvento(
      id: json['id'],
      tipo: TipoEvento.values.firstWhere((e) => e.name == json['tipo']),
      dataHora: DateTime.parse(json['dataHora']),
      responsavel: json['responsavel'],
      observacao: json['observacao'],
      dadosAdicionais: json['dadosAdicionais'],
    );
  }
}

/// Representa um apontamento completo com todos os seus eventos
class ApontamentoCompleto {
  final String id;
  final String estagioNome;
  final DateTime dataCriacao;
  final List<ApontamentoEvento> eventos;
  final Map<String, dynamic> dadosFinais;
  final int quantidadeProcessada;
  final String? responsavel;
  final String? responsavelSuperior;
  final String? fulao;
  final String? observacao;

  ApontamentoCompleto({
    required this.id,
    required this.estagioNome,
    required this.dataCriacao,
    required this.eventos,
    required this.dadosFinais,
    required this.quantidadeProcessada,
    this.responsavel,
    this.responsavelSuperior,
    this.fulao,
    this.observacao,
  });

  /// Retorna o status atual do apontamento
  String get statusAtual {
    if (eventos.isEmpty) return 'Não iniciado';
    final ultimoEvento = eventos.last;
    return ultimoEvento.nomeEvento;
  }

  /// Retorna a duração total do apontamento
  Duration? get duracaoTotal {
    if (eventos.isEmpty) return null;
    
    final inicio = eventos.firstWhere(
      (e) => e.tipo == TipoEvento.iniciado,
      orElse: () => eventos.first,
    );
    
    final fim = eventos.lastWhere(
      (e) => e.tipo == TipoEvento.encerrado,
      orElse: () => eventos.last,
    );
    
    return fim.dataHora.difference(inicio.dataHora);
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estagioNome': estagioNome,
      'dataCriacao': dataCriacao.toIso8601String(),
      'eventos': eventos.map((e) => e.toJson()).toList(),
      'dadosFinais': dadosFinais,
      'quantidadeProcessada': quantidadeProcessada,
      'responsavel': responsavel,
      'responsavelSuperior': responsavelSuperior,
      'fulao': fulao,
      'observacao': observacao,
    };
  }

  /// Cria a partir de JSON
  factory ApontamentoCompleto.fromJson(Map<String, dynamic> json) {
    return ApontamentoCompleto(
      id: json['id'],
      estagioNome: json['estagioNome'],
      dataCriacao: DateTime.parse(json['dataCriacao']),
      eventos: (json['eventos'] as List)
          .map((e) => ApontamentoEvento.fromJson(e))
          .toList(),
      dadosFinais: json['dadosFinais'],
      quantidadeProcessada: json['quantidadeProcessada'],
      responsavel: json['responsavel'],
      responsavelSuperior: json['responsavelSuperior'],
      fulao: json['fulao'],
      observacao: json['observacao'],
    );
  }
}
