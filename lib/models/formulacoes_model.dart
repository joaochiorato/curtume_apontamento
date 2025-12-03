// Modelo para os químicos
// Conforme Teste de Mesa - tbSeqOperacaoProd
// Apenas Cod_produto_comp != 0

class Quimico {
  final String codigo;
  final String nome;
  final String unidade;

  const Quimico({
    required this.codigo,
    required this.nome,
    this.unidade = 'kg',
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

// ═══════════════════════════════════════════════════════════════
// QUÍMICOS DO REMOLHO (Cod_operacao: 1000)
// Conforme Teste de Mesa - tbSeqOperacaoProd
// Apenas registros com Cod_produto_comp != 0
// ═══════════════════════════════════════════════════════════════

const List<Quimico> quimicosRemolho = [
  // Cod_produto_comp: 89396
  Quimico(
    codigo: '89396',
    nome: 'CAL VIRGEM 20 KG',
    unidade: 'kg',
  ),
  // Cod_produto_comp: 95001
  Quimico(
    codigo: '95001',
    nome: 'SULFETO DE SODIO 60%',
    unidade: 'kg',
  ),
  // Cod_produto_comp: 95209
  Quimico(
    codigo: '95209',
    nome: 'TENSOATIVO',
    unidade: 'L',
  ),
];

// Modelo para armazenar os dados completos dos químicos
// Conforme Teste de Mesa - tbSaidasApontamento
class QuimicosFormulacaoData {
  final String localEstoque;
  final Map<String, String> quantidades; // código do químico → quantidade

  QuimicosFormulacaoData({
    required this.localEstoque,
    required this.quantidades,
  });

  Map<String, dynamic> toJson() {
    return {
      'localEstoque': localEstoque,
      'quantidades': quantidades,
      'formatoGravacao': toFormatoGravacao(),
    };
  }

  factory QuimicosFormulacaoData.fromJson(Map<String, dynamic> json) {
    return QuimicosFormulacaoData(
      localEstoque: json['localEstoque'] ?? '— selecione —',
      quantidades: Map<String, String>.from(json['quantidades'] ?? {}),
    );
  }

  // Retorna quantos químicos foram informados
  int getQuantidadeInformados() {
    return quantidades.values.where((q) => q.isNotEmpty).length;
  }

  // Retorna o total de químicos disponíveis
  int getTotalQuimicos() {
    return quimicosRemolho.length;
  }

  // Retorna a lista de químicos
  List<Quimico> getQuimicos() {
    return quimicosRemolho;
  }

  // Gera string formatada para gravação (conforme teste de mesa)
  // Formato: "CAL:30|SUL:20|TEN:5" (tbSaidasApontamento.Texto)
  String toFormatoGravacao() {
    final partes = <String>[];
    
    for (final quimico in quimicosRemolho) {
      final qtd = quantidades[quimico.codigo] ?? '';
      if (qtd.isNotEmpty) {
        // Usa abreviação conforme teste de mesa
        String abrev;
        if (quimico.codigo == '89396') {
          abrev = 'CAL';  // CAL VIRGEM 20 KG
        } else if (quimico.codigo == '95001') {
          abrev = 'SUL';  // SULFETO DE SODIO 60%
        } else if (quimico.codigo == '95209') {
          abrev = 'TEN';  // TENSOATIVO
        } else {
          abrev = quimico.nome.substring(0, 3).toUpperCase();
        }
        partes.add('$abrev:$qtd');
      }
    }
    
    return partes.join('|');
  }
}