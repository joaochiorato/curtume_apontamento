// Enum para status da ordem
enum StatusOrdem {
  emProducao,
  aguardando,
  finalizada,
  cancelada,
}

// Extension para converter enum para String legível
extension StatusOrdemExtension on StatusOrdem {
  String get displayName {
    switch (this) {
      case StatusOrdem.emProducao:
        return 'Em Produção';
      case StatusOrdem.aguardando:
        return 'Não Iniciado';
      case StatusOrdem.finalizada:
        return 'Finalizada';
      case StatusOrdem.cancelada:
        return 'Cancelada';
    }
  }
}

class OrdemModel {
  final String of;
  final String cliente;
  final DateTime data;
  final StatusOrdem? status;
  final List<ArtigoModel> artigos;

  OrdemModel({
    required this.of,
    required this.cliente,
    required this.data,
    this.status,
    required this.artigos,
  });
}

class ArtigoModel {
  final String codigo;
  final String descricao;
  final int quantidade;

  ArtigoModel({
    required this.codigo,
    required this.descricao,
    required this.quantidade,
  });
}
