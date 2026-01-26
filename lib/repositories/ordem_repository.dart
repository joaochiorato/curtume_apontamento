import '../models/ordem_producao.dart';

/// 💾 Repositório de Ordens de Produção (Dados em Memória)
/// Conforme Teste de Mesa - Apontamento Curtume
class OrdemProducaoRepository {
  static final OrdemProducaoRepository _instance =
      OrdemProducaoRepository._internal();
  factory OrdemProducaoRepository() => _instance;
  OrdemProducaoRepository._internal();

  // Lista de ordens em memória
  final List<OrdemProducao> _ordens = [];

  /// Inicializa com dados do Teste de Mesa
  void inicializarDados() {
    _ordens.clear();
    _ordens.add(_criarOrdemTesteMesa());
  }

  /// Lista todas as ordens
  List<OrdemProducao> listarOrdens() => List.unmodifiable(_ordens);

  /// Busca ordem por ID
  OrdemProducao? buscarPorId(String id) {
    try {
      return _ordens.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Atualiza uma ordem
  void atualizarOrdem(OrdemProducao ordem) {
    final index = _ordens.indexWhere((o) => o.id == ordem.id);
    if (index != -1) {
      _ordens[index] = ordem;
    }
  }

  /// Atualiza estágio específico
  void atualizarEstagio(String ordemId, Estagio estagio) {
    final ordem = buscarPorId(ordemId);
    if (ordem != null) {
      final estagios = List<Estagio>.from(ordem.estagios);
      final index = estagios.indexWhere((e) => e.id == estagio.id);
      if (index != -1) {
        estagios[index] = estagio;
        atualizarOrdem(ordem.copyWith(estagios: estagios));
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DADOS DO TESTE DE MESA
  // tbentradas: XYD459939 | 120-ORP-3 | Cod_cli_for: 6357 | Cod_linha: C90
  // tbentradasitem: CSA001 | QUARTZO BLACK | Cod_classif: 7
  // ═══════════════════════════════════════════════════════════════

  OrdemProducao _criarOrdemTesteMesa() {
    return OrdemProducao(
      id: 'XYD459939',
      numeroOf: '120-ORP-001-3',
      artigo: 'QUARTZO',
      pve: '',
      cor: 'BLACK',
      crustItem: '1163',
      espFinal: '1.0/1.4',
      classe: 'G119',
      po: '',
      loteWetBlue: '',
      numeroPecasNF: 100000,
      metragemNF: 0,
      avg: 0,
      numeroPecasEnx: 0,
      metragemEnx: 0,
      pesoLiquido: 100000,
      dataCriacao: DateTime.now(),
      status: StatusOrdem.Aguardando,
      estagios: _criarEstagiosTesteMesa(),
    );
  }

  /// 🏭 Cria os estágios conforme Teste de Mesa
  /// tbSeqOperacao: 1000 (REMOLHO), 1001 (ENXUGADEIRA), 1002 (DIVISORA)
  List<Estagio> _criarEstagiosTesteMesa() {
    return [
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 1. REMOLHO (Cod_operacao: 1000)
      // Desc_operacao: 1A REMOLHO
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      Estagio(
        id: 'remolho',
        nome: 'REMOLHO',
        ordem: 1,
        quantidadeTotal: 10,
        variaveisControle: [
          VariavelControle(
            nome: 'Volume de Água',
            unidade: 'L',
            padrao: '100% do Peso do Couro',
          ),
          VariavelControle(
            nome: 'Temperatura da Água',
            unidade: 'ºC',
            valorMinimo: 0,
            valorMaximo: 60,
            padrao: '60 +/- 10',
          ),
          VariavelControle(
            nome: 'Tensoativo',
            unidade: 'L',
            valorMinimo: 4.8,
            valorMaximo: 5.2,
            padrao: 'Faixa 4.8 - 5.2',
          ),
        ],
        dadosAdicionais: {
          'fulao': null,
          'numFulao': null,
          'codLoteCouro': 'N5K001',
        },
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 2. ENXUGADEIRA (Cod_operacao: 1001)
      // Desc_operacao: 2A ENXUGADEIRA
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      Estagio(
        id: 'enxugadeira',
        nome: 'ENXUGADEIRA',
        ordem: 2,
        quantidadeTotal: 10,
        variaveisControle: [
          VariavelControle(
            nome: 'Pressão do Rolo (1º manômetro)',
            unidade: 'Bar',
            valorMinimo: 40,
            valorMaximo: 110,
            padrao: '40 a 110',
          ),
          VariavelControle(
            nome: 'Pressão do Rolo (2º manômetro)',
            unidade: 'Bar',
            valorMinimo: 60,
            valorMaximo: 110,
            padrao: '60 a 110',
          ),
          VariavelControle(
            nome: 'Velocidade do Feltro',
            unidade: 'mt/min',
            valorMinimo: 3,
            valorMaximo: 15,
            padrao: '15 +/- 3',
          ),
          VariavelControle(
            nome: 'Velocidade do Tapete',
            unidade: 'mt/min',
            valorMinimo: 10,
            valorMaximo: 16,
            padrao: '13 +/- 3',
          ),
        ],
        dadosAdicionais: {
          'maquina': null,
          'codLoteCouro': 'N5K001',
        },
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 3. DIVISORA (Cod_operacao: 1002)
      // Desc_operacao: 3A DIVISORA
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      Estagio(
        id: 'divisora',
        nome: 'DIVISORA',
        ordem: 3,
        quantidadeTotal: 10,
        variaveisControle: [
          VariavelControle(
            nome: 'Velocidade da Máquina',
            unidade: 'mt/min',
            valorMinimo: 21,
            valorMaximo: 25,
            padrao: '23 +/- 2',
          ),
          VariavelControle(
            nome: 'Distância da Navalha',
            unidade: 'mm',
            valorMinimo: 8.0,
            valorMaximo: 8.5,
            padrao: '8,0 a 8,5',
          ),
          VariavelControle(
            nome: 'Fio da Navalha Inferior',
            unidade: 'mm',
            valorMinimo: 4.5,
            valorMaximo: 5.5,
            padrao: '5,0 +/- 0,5',
          ),
          VariavelControle(
            nome: 'Fio da Navalha Superior',
            unidade: 'mm',
            valorMinimo: 5.5,
            valorMaximo: 6.5,
            padrao: '6,0 +/- 0,5',
          ),
        ],
        dadosAdicionais: {
          'maquina': null,
          'codLoteCouro': 'N5K001',
        },
      ),
    ];
  }
}
