import '../models/ordem_producao.dart';

/// 💾 Repositório de Ordens de Produção (Dados em Memória)
class OrdemProducaoRepository {
  static final OrdemProducaoRepository _instance = OrdemProducaoRepository._internal();
  factory OrdemProducaoRepository() => _instance;
  OrdemProducaoRepository._internal();

  // Lista de ordens em memória
  final List<OrdemProducao> _ordens = [];

  /// Inicializa com dados da OF 18283 - QUARTZO
  void inicializarDados() {
    _ordens.clear();
    _ordens.add(_criarOf18283());
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

  /// 📋 Cria a OF 18283 - QUARTZO baseada no documento real
  OrdemProducao _criarOf18283() {
    return OrdemProducao(
      id: '1',
      numeroOf: '18283',
      artigo: 'QUARTZO',
      pve: '7315',
      cor: 'E - BROWN',
      crustItem: '1165',
      espFinal: '1.1/1.5',
      classe: 'G119',
      po: '7315CK08',
      loteWetBlue: '32666',
      numeroPecasNF: 350,
      metragemNF: 21295.25,
      avg: 60.84,
      numeroPecasEnx: 0,
      metragemEnx: 0,
      pesoLiquido: 9855.00,
      dataCriacao: DateTime(2025, 10, 14),
      status: StatusOrdem.aguardando,
      estagios: _criarEstagiosQuartzo(),
    );
  }

  /// 🏭 Cria os estágios do processo QUARTZO
  List<Estagio> _criarEstagiosQuartzo() {
    return [
      // 1. REMOLHO
      Estagio(
        id: 'remolho',
        nome: 'REMOLHO',
        ordem: 1,
        quantidadeTotal: 350,
        variaveisControle: [
          VariavelControle(
            nome: 'Volume de Água',
            unidade: 'Litros',
            padrao: '100% peso líquido do lote',
          ),
          VariavelControle(
            nome: 'Temperatura da Água (dentro do fulão remolho)',
            unidade: '°C',
            padrao: '60',
            valorMinimo: 50,
            valorMaximo: 70,
          ),
          VariavelControle(
            nome: 'Tensoativo',
            unidade: 'Litros',
            padrao: '5',
            valorMinimo: 4.8,
            valorMaximo: 5.2,
          ),
        ],
        dadosAdicionais: {
          'fulao': null, // 1, 2, 3 ou 4
          'tempoRemolho': '120 minutos +/- 60 min',
        },
      ),

      // 2. ENXUGADEIRA
      Estagio(
        id: 'enxugadeira',
        nome: 'ENXUGADEIRA',
        ordem: 2,
        quantidadeTotal: 350,
        variaveisControle: [
          VariavelControle(
            nome: 'Pressão do Rolo (1º manômetro)',
            unidade: 'Bar',
            valorMinimo: 40,
            valorMaximo: 110,
          ),
          VariavelControle(
            nome: 'Pressão do Rolo (2º e 3º manômetro)',
            unidade: 'Bar',
            valorMinimo: 60,
            valorMaximo: 110,
          ),
          VariavelControle(
            nome: 'Velocidade do Feltro',
            unidade: 'mt/min',
            padrao: '15',
            valorMinimo: 12,
            valorMaximo: 18,
          ),
          VariavelControle(
            nome: 'Velocidade do Tapete',
            unidade: 'mt/min',
            padrao: '13',
            valorMinimo: 10,
            valorMaximo: 16,
          ),
        ],
        dadosAdicionais: {
          'maquina': null, // 1 ou 2
        },
      ),

      // 3. DIVISORA
      Estagio(
        id: 'divisora',
        nome: 'DIVISORA',
        ordem: 3,
        quantidadeTotal: 350,
        variaveisControle: [
          VariavelControle(
            nome: 'Velocidade da Máquina',
            unidade: 'metro/minuto',
            padrao: '23',
            valorMinimo: 21,
            valorMaximo: 25,
          ),
          VariavelControle(
            nome: 'Distância da Navalha',
            unidade: 'mm',
            valorMinimo: 8.0,
            valorMaximo: 8.5,
          ),
          VariavelControle(
            nome: 'Fio da Navalha Inferior',
            unidade: 'mm',
            padrao: '5.0',
            valorMinimo: 4.5,
            valorMaximo: 5.5,
          ),
          VariavelControle(
            nome: 'Fio da Navalha Superior',
            unidade: 'mm',
            padrao: '6.0',
            valorMinimo: 5.5,
            valorMaximo: 6.5,
          ),
        ],
        dadosAdicionais: {
          'maquina': null, // 1 ou 2
          'espessuraDivisao': '1.5/1.6',
          'pesoBruto': null,
          'pesoLiquido': null,
        },
      ),

      // 4. REBAIXADEIRA
      Estagio(
        id: 'rebaixadeira',
        nome: 'REBAIXADEIRA',
        ordem: 4,
        quantidadeTotal: 350,
        variaveisControle: [
          VariavelControle(
            nome: 'Velocidade do Rolo de Transporte',
            unidade: 'mt/min',
            padrao: '10/12',
          ),
        ],
        dadosAdicionais: {
          'maquina': null, // 1, 2, 3, 4, 5 ou 6
          'espessuraRebaixe': '1.2/1.3+1.2',
          'plt1': null,
          'plt2': null,
          'plt3': null,
          'plt4': null,
          'plt5': null,
          'plt6': null,
          'plt7': null,
          'plt8': null,
          'plt9': null,
          'plt10': null,
          'pesoCupim': null,
          'pesoRefile': null,
          'pesoLiquido': null,
        },
      ),

      // 5. REFILA
      Estagio(
        id: 'refila',
        nome: 'REFILA',
        ordem: 5,
        quantidadeTotal: 350,
        dadosAdicionais: {
          'nomeRefilador': null,
          'pesoLiquido': null,
          'pesoRefile': null,
          'pesoCupim': null,
        },
      ),
    ];
  }
}
