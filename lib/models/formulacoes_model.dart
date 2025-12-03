/// Modelo de um químico do REMOLHO
class QuimicoModel {
  final String codigo;
  final String nome;
  final String unidade;

  const QuimicoModel({
    required this.codigo,
    required this.nome,
    required this.unidade,
  });
}

/// Lista de químicos disponíveis no REMOLHO
const List<QuimicoModel> quimicosRemolho = [
  QuimicoModel(codigo: '89396', nome: 'CAL VIRGEM 20 KG', unidade: 'kg'),
  QuimicoModel(codigo: '95001', nome: 'SULFETO DE SODIO 60%', unidade: 'kg'),
  QuimicoModel(codigo: '95002', nome: 'TENSOATIVO', unidade: 'L'),
];

/// Locais de estoque disponíveis
const List<String> locaisEstoque = [
  '— selecione —',
  'Almoxarifado A',
  'Almoxarifado B',
  'Depósito Central',
];

/// ✅ Um único apontamento de químico (um registro na lista)
class ApontamentoQuimico {
  final int fulao;
  final String localEstoque;
  final Map<String, String> quantidades; // codigo -> quantidade
  final DateTime dataHora;

  ApontamentoQuimico({
    required this.fulao,
    required this.localEstoque,
    required this.quantidades,
    DateTime? dataHora,
  }) : dataHora = dataHora ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'fulao': fulao,
      'localEstoque': localEstoque,
      'quantidades': quantidades,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory ApontamentoQuimico.fromJson(Map<String, dynamic> json) {
    return ApontamentoQuimico(
      fulao: json['fulao'] as int,
      localEstoque: json['localEstoque'] as String,
      quantidades: Map<String, String>.from(json['quantidades'] as Map),
      dataHora: json['dataHora'] != null 
          ? DateTime.parse(json['dataHora']) 
          : DateTime.now(),
    );
  }

  /// Retorna a quantidade total de químicos informados neste apontamento
  int getQuantidadeInformados() {
    return quantidades.values.where((v) => v.isNotEmpty).length;
  }

  /// Retorna um resumo do apontamento
  String getResumo() {
    final qtdInformados = getQuantidadeInformados();
    return 'Fulão $fulao - $qtdInformados químico${qtdInformados != 1 ? 's' : ''}';
  }
}

/// ✅ Lista de apontamentos de químicos para um estágio
class QuimicosFormulacaoData {
  final List<ApontamentoQuimico> apontamentos;

  QuimicosFormulacaoData({
    List<ApontamentoQuimico>? apontamentos,
  }) : apontamentos = apontamentos ?? [];

  Map<String, dynamic> toJson() {
    return {
      'apontamentos': apontamentos.map((a) => a.toJson()).toList(),
    };
  }

  factory QuimicosFormulacaoData.fromJson(Map<String, dynamic> json) {
    final list = json['apontamentos'] as List<dynamic>?;
    return QuimicosFormulacaoData(
      apontamentos: list?.map((e) => ApontamentoQuimico.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  /// Retorna o total de apontamentos
  int getQuantidadeApontamentos() {
    return apontamentos.length;
  }

  /// Adiciona um novo apontamento
  QuimicosFormulacaoData addApontamento(ApontamentoQuimico apontamento) {
    return QuimicosFormulacaoData(
      apontamentos: [...apontamentos, apontamento],
    );
  }

  /// Remove um apontamento pelo índice
  QuimicosFormulacaoData removeApontamento(int index) {
    if (index < 0 || index >= apontamentos.length) return this;
    final newList = List<ApontamentoQuimico>.from(apontamentos);
    newList.removeAt(index);
    return QuimicosFormulacaoData(apontamentos: newList);
  }

  /// Atualiza um apontamento existente
  QuimicosFormulacaoData updateApontamento(int index, ApontamentoQuimico apontamento) {
    if (index < 0 || index >= apontamentos.length) return this;
    final newList = List<ApontamentoQuimico>.from(apontamentos);
    newList[index] = apontamento;
    return QuimicosFormulacaoData(apontamentos: newList);
  }

  /// Para compatibilidade - retorna quantidade de apontamentos
  int getQuantidadeInformados() {
    return apontamentos.length;
  }
}