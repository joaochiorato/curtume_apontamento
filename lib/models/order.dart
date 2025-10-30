class OrdemModel {
  final String of;
  final String cliente;
  final DateTime data;
  final String status;
  final List<ArtigoModel> artigos;

  OrdemModel({
    required this.of,
    required this.cliente,
    required this.data,
    required this.status,
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
