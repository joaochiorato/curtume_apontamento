// Modelo para os químicos
class Quimico {
  final String nome;
  final String unidade;

  const Quimico({required this.nome, this.unidade = 'kg'});
}

// Modelo para uma formulação
class Formulacao {
  final String codigo;
  final String nome;
  final List<Quimico> quimicos;

  const Formulacao({
    required this.codigo,
    required this.nome,
    required this.quimicos,
  });
}

// Lista de locais de estoque disponíveis
const List<String> locaisEstoque = [
  '— selecione —',
  'Almoxarifado A',
  'Almoxarifado B',
  'Depósito Principal',
  'Estoque Temporário',
  'Área de Recebimento',
];

// Definição das formulações disponíveis
const List<Formulacao> formulacoes = [
  // FORMULAÇÃO 1 - 3 produtos
  Formulacao(
    codigo: 'FORM_01',
    nome: 'Formulação 1 - Remolho Básico',
    quimicos: [
      Quimico(nome: 'Cal virgem (hidróxido de cálcio)', unidade: 'kg'),
      Quimico(nome: 'Sulfeto de sódio (Na₂S)', unidade: 'kg'),
      Quimico(nome: 'Tensoativo / umectante', unidade: 'L'),
    ],
  ),
  
  // FORMULAÇÃO 2 - 5 produtos
  Formulacao(
    codigo: 'FORM_02',
    nome: 'Formulação 2 - Remolho Completo',
    quimicos: [
      Quimico(nome: 'Cal virgem (hidróxido de cálcio)', unidade: 'kg'),
      Quimico(nome: 'Sulfeto de sódio (Na₂S)', unidade: 'kg'),
      Quimico(nome: 'Hidrossulfeto de sódio (NaHS)', unidade: 'kg'),
      Quimico(nome: 'Tensoativo / umectante', unidade: 'L'),
      Quimico(nome: 'Agente sequestrante', unidade: 'L'),
    ],
  ),
  
  // FORMULAÇÃO 3 - 4 produtos
  Formulacao(
    codigo: 'FORM_03',
    nome: 'Formulação 3 - Remolho Ecológico',
    quimicos: [
      Quimico(nome: 'Desulfex, EcoLime, Biosafe', unidade: 'kg'),
      Quimico(nome: 'Hidrossulfeto de sódio (NaHS)', unidade: 'kg'),
      Quimico(nome: 'Tensoativo / umectante', unidade: 'L'),
      Quimico(nome: 'Agente sequestrante', unidade: 'L'),
    ],
  ),
  
  // FORMULAÇÃO 4 - Todos os produtos (6 produtos)
  Formulacao(
    codigo: 'FORM_04',
    nome: 'Formulação 4 - Personalizada',
    quimicos: [
      Quimico(nome: 'Cal virgem (hidróxido de cálcio)', unidade: 'kg'),
      Quimico(nome: 'Sulfeto de sódio (Na₂S)', unidade: 'kg'),
      Quimico(nome: 'Hidrossulfeto de sódio (NaHS)', unidade: 'kg'),
      Quimico(nome: 'Desulfex, EcoLime, Biosafe', unidade: 'kg'),
      Quimico(nome: 'Tensoativo / umectante', unidade: 'L'),
      Quimico(nome: 'Agente sequestrante', unidade: 'L'),
    ],
  ),
];

// Modelo para armazenar os dados completos dos químicos
class QuimicosFormulacaoData {
  final String formulacaoCodigo;
  final String localEstoque;
  final Map<String, String> quantidades; // nome do químico → quantidade

  QuimicosFormulacaoData({
    required this.formulacaoCodigo,
    required this.localEstoque,
    required this.quantidades,
  });

  Map<String, dynamic> toJson() {
    return {
      'formulacaoCodigo': formulacaoCodigo,
      'localEstoque': localEstoque,
      'quantidades': quantidades,
    };
  }

  factory QuimicosFormulacaoData.fromJson(Map<String, dynamic> json) {
    return QuimicosFormulacaoData(
      formulacaoCodigo: json['formulacaoCodigo'] ?? '',
      localEstoque: json['localEstoque'] ?? '— selecione —',
      quantidades: Map<String, String>.from(json['quantidades'] ?? {}),
    );
  }

  // Retorna quantos químicos foram informados
  int getQuantidadeInformados() {
    return quantidades.values.where((q) => q.isNotEmpty).length;
  }

  // Retorna o nome da formulação
  String getFormulacaoNome() {
    try {
      return formulacoes.firstWhere((f) => f.codigo == formulacaoCodigo).nome;
    } catch (_) {
      return 'Formulação desconhecida';
    }
  }

  // Retorna a lista de químicos da formulação
  List<Quimico> getQuimicos() {
    try {
      return formulacoes.firstWhere((f) => f.codigo == formulacaoCodigo).quimicos;
    } catch (_) {
      return [];
    }
  }
}
