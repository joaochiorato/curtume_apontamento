// Enum para status da ordem
enum StatusOrdem {
  emProducao,
  Aguardando,
  finalizada,
  cancelada,
}

// Extension para converter enum para String legível
extension StatusOrdemExtension on StatusOrdem {
  String get displayName {
    switch (this) {
      case StatusOrdem.emProducao:
        return 'Em Produção';
      case StatusOrdem.Aguardando:
        return 'Não Iniciado';
      case StatusOrdem.finalizada:
        return 'Finalizada';
      case StatusOrdem.cancelada:
        return 'Cancelada';
    }
  }
}

class OrdemModel {
  final String Doc;
  final String cliente;
  final DateTime data;
  final StatusOrdem? status;
  final List<ArtigoModel> artigos;

  OrdemModel({
    required this.Doc,
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
  final String cor;
  final String crustItem;
  final String espFinal;
  final String classe;
  final String descricaoCompleta;
  final String loteWetBlue;
  final int numeroPecasNF;
  final double metragemNF;
  final String avg;

  ArtigoModel({
    required this.codigo,
    required this.descricao,
    required this.quantidade,
    this.cor = '',
    this.crustItem = '',
    this.espFinal = '',
    this.classe = '',
    this.descricaoCompleta = '',
    this.loteWetBlue = '',
    this.numeroPecasNF = 0,
    this.metragemNF = 0.0,
    this.avg = '',
  });
}
