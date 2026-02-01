import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/stage.dart';
import '../models/apontamento_item.dart';
import '../models/filial_model.dart';
import 'direct_stage_page.dart';
import 'stage_memory_storage.dart';

class OrdersPage extends StatefulWidget {
  final FilialModel filial;
  final PostoTrabalhoModel postoTrabalho;

  const OrdersPage({
    super.key,
    required this.filial,
    required this.postoTrabalho,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _loading = true;
  List<OrdemModel> _ordens = [];
  List<ApontamentoItem> _itensApontamento = [];
  List<ApontamentoItem> _itensFiltrados = [];

  final _filtroOF = TextEditingController();
  final _filtroArtigo = TextEditingController();
  final _filtroCrustItem = TextEditingController();
  DateTime? _dataFiltro;
  final dfDate = DateFormat('dd/MM/yyyy');
  final storage = StageMemoryStorage();

  @override
  void initState() {
    super.initState();
    _load();
    _filtroOF.addListener(_aplicarFiltros);
    _filtroArtigo.addListener(_aplicarFiltros);
    _filtroCrustItem.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _filtroOF.dispose();
    _filtroArtigo.dispose();
    _filtroCrustItem.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // ═══════════════════════════════════════════════════════════════
    // DADOS CONFORME TESTE DE MESA - Apontamento Curtume
    // ═══════════════════════════════════════════════════════════════
    // tbentradas:
    //   Chave_fato: XYD459939
    //   Num_docto: 120-ORP-3
    //   Cod_cli_for: 6357
    //   Cod_linha: C90
    //
    // tbentradasitem:
    //   Cod_produto: CSA001
    //   Desc_produto: QUARTZO BLACK
    //   Cod_classif: 7
    //   Qtde_pri: 100000
    //   Cod_lote_couro: N5K001
    // ═══════════════════════════════════════════════════════════════

    _ordens = [
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // ORP 120-ORP-001-3 - QUARTZO (Original - não modificada)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      OrdemModel(
        Doc: '120-ORP-001-3',
        cliente: '6357 - VANCOUROS INDUSTRIA E COMERCIO DE COUROS LTDA ',
        data: DateTime.now(),
        status: StatusOrdem.Aguardando,
        artigos: [
          // Apenas QUARTZO BLACK conforme teste de mesa
          ArtigoModel(
            codigo: 'CSA001',
            descricao: '10- QUARTZO',
            quantidade: 350,
            cor: 'BLACK',
            crustItem: '1163',
            espFinal: '1.0/1.4',
            classe: 'G119',
            descricaoCompleta: 'COURO MERCADO EXTERNO',
            loteWetBlue: '32666',
            numeroPecasNF: 350,
            metragemNF: 21295.25,
            avg: '60.84',
          ),
        ],
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // ORP 120-ORP-001-4 - AMETISTA e TOPÁZIO (2 artigos)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      OrdemModel(
        Doc: '120-ORP-001-4',
        cliente: '6357 - VANCOUROS INDUSTRIA E COMERCIO DE COUROS LTDA ',
        data: DateTime.now(),
        status: StatusOrdem.Aguardando,
        artigos: [
          ArtigoModel(
            codigo: 'CSA002',
            descricao: '20- AMETISTA',
            quantidade: 280,
            cor: 'PURPLE',
            crustItem: '1164',
            espFinal: '1.1/1.5',
            classe: 'G120',
            descricaoCompleta: 'COURO EXPORTACAO PREMIUM',
            loteWetBlue: '32667',
            numeroPecasNF: 280,
            metragemNF: 17024.80,
            avg: '60.80',
          ),
          ArtigoModel(
            codigo: 'CSA006',
            descricao: '25- TOPÁZIO',
            quantidade: 330,
            cor: 'BROWN',
            crustItem: '1168',
            espFinal: '1.0/1.5',
            classe: 'G124',
            descricaoCompleta: 'COURO SELETO PRIMEIRA LINHA',
            loteWetBlue: '32668',
            numeroPecasNF: 330,
            metragemNF: 19874.70,
            avg: '60.23',
          ),
        ],
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // ORP 120-ORP-001-5 - SAFIRA, ESMERALDA, RUBI (3 artigos)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      OrdemModel(
        Doc: '120-ORP-001-5',
        cliente: '6357 - VANCOUROS INDUSTRIA E COMERCIO DE COUROS LTDA ',
        data: DateTime.now(),
        status: StatusOrdem.Aguardando,
        artigos: [
          ArtigoModel(
            codigo: 'CSA003',
            descricao: '30- SAFIRA',
            quantidade: 420,
            cor: 'NAVY',
            crustItem: '1165',
            espFinal: '1.2/1.6',
            classe: 'G121',
            descricaoCompleta: 'COURO NOBRE ESPECIAL',
            loteWetBlue: '32669',
            numeroPecasNF: 420,
            metragemNF: 25389.00,
            avg: '60.45',
          ),
          ArtigoModel(
            codigo: 'CSA004',
            descricao: '40- ESMERALDA',
            quantidade: 310,
            cor: 'GREEN',
            crustItem: '1166',
            espFinal: '1.0/1.3',
            classe: 'G122',
            descricaoCompleta: 'COURO PREMIUM INTERNACIONAL',
            loteWetBlue: '32670',
            numeroPecasNF: 310,
            metragemNF: 18731.50,
            avg: '60.42',
          ),
          ArtigoModel(
            codigo: 'CSA005',
            descricao: '50- RUBI',
            quantidade: 390,
            cor: 'RED',
            crustItem: '1167',
            espFinal: '1.1/1.4',
            classe: 'G123',
            descricaoCompleta: 'COURO ALTO PADRAO LUXO',
            loteWetBlue: '32671',
            numeroPecasNF: 390,
            metragemNF: 23562.90,
            avg: '60.42',
          ),
        ],
      ),
    ];

    // Gerar lista unificada: Ordem × Artigo × Estágio
    // Filtrar apenas estágios do posto de trabalho selecionado
    final estagiosFiltrados = availableStages
        .where((e) => e.postoTrabalho == widget.postoTrabalho.codigo)
        .toList();

    _itensApontamento = [];
    for (var ordem in _ordens) {
      for (var artigo in ordem.artigos) {
        for (var estagio in estagiosFiltrados) {
          _itensApontamento.add(ApontamentoItem(
            ordem: ordem,
            artigo: artigo,
            estagio: estagio,
          ));
        }
      }
    }

    _itensFiltrados = _itensApontamento;
    setState(() => _loading = false);
  }

  void _aplicarFiltros() {
    setState(() {
      _itensFiltrados = _itensApontamento.where((item) {
        final matchOF = _filtroOF.text.isEmpty ||
            item.ordem.Doc.toLowerCase().contains(_filtroOF.text.toLowerCase());

        final matchArtigo = _filtroArtigo.text.isEmpty ||
            item.artigo.descricao
                .toLowerCase()
                .contains(_filtroArtigo.text.toLowerCase()) ||
            item.artigo.codigo
                .toLowerCase()
                .contains(_filtroArtigo.text.toLowerCase());

        final matchCrustItem = _filtroCrustItem.text.isEmpty ||
            item.artigo.crustItem
                .toLowerCase()
                .contains(_filtroCrustItem.text.toLowerCase());

        final matchData = _dataFiltro == null ||
            (item.ordem.data.year == _dataFiltro!.year &&
                item.ordem.data.month == _dataFiltro!.month &&
                item.ordem.data.day == _dataFiltro!.day);

        // Filtrar itens que foram finalizados ou encerrados (não mostrar se tem apontamentos salvos e está finalizado/encerrado)
        final uniqueKey = _getUniqueKey(item);
        final info = storage.getStageInfo(uniqueKey);
        final status = info['status'] as StageProgressStatus;
        final apontamentos = storage.getApontamentos(uniqueKey);
        final temApontamentos = apontamentos.isNotEmpty;

        // Se tem apontamentos e está finalizado ou encerrado, não mostrar
        if (temApontamentos &&
            (status == StageProgressStatus.finalizado ||
                status == StageProgressStatus.encerrado)) {
          return false;
        }

        return matchOF && matchArtigo && matchCrustItem && matchData;
      }).toList();
    });
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataFiltro ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _dataFiltro = picked;
        _aplicarFiltros();
      });
    }
  }

  /// Cria um identificador único para um apontamento específico
  /// Formato: "OF_CodigoArtigo_CodigoEstagio"
  String _getUniqueKey(ApontamentoItem item) {
    return '${item.ordem.Doc}_${item.artigo.codigo}_${item.estagio.code}';
  }

  void _abrirApontamento(ApontamentoItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DirectStagePage(
          articleHeader: {
            'of': item.ordem.Doc,
            'artigo': item.artigo.descricao,
            'codigo': item.artigo.codigo,
            'quantidade': item.artigo.quantidade.toString(),
            'cor': item.artigo.cor,
            'crustItem': item.artigo.crustItem,
            'espFinal': item.artigo.espFinal,
            'classe': item.artigo.classe,
            'descricaoCompleta': item.artigo.descricaoCompleta,
            'loteWetBlue': item.artigo.loteWetBlue,
            'numeroPecasNF': item.artigo.numeroPecasNF.toString(),
            'metragemNF': item.artigo.metragemNF.toString(),
            'avg': item.artigo.avg,
          },
          stage: item.estagio,
        ),
      ),
    ).then((_) {
      // Atualizar a tela quando voltar
      setState(() {});
    });
  }

  void _mostrarListaApontamentos(
    BuildContext context,
    StageModel estagio,
    List<Map<String, dynamic>> apontamentos,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF546E7A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Apontamentos Salvos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            estagio.title,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Lista de apontamentos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: apontamentos.length,
                  itemBuilder: (context, index) {
                    final apontamento = apontamentos[index];
                    final qtdProcessada = apontamento['qtdProcessada'] ?? 0;
                    final dataHora = apontamento['dataHora'] as DateTime?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                          _mostrarDetalhesApontamento(apontamento, estagio);
                        },
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.green,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Quantidade: $qtdProcessada peles',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: dataHora != null
                            ? Text(
                                'Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(dataHora)}',
                                style: const TextStyle(fontSize: 13),
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right, size: 20),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesApontamento(
      Map<String, dynamic> apontamento, StageModel estagio) {
    final dtFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final start = apontamento['start'] != null
        ? DateTime.parse(apontamento['start'])
        : null;
    final end =
        apontamento['end'] != null ? DateTime.parse(apontamento['end']) : null;
    final qtdProcessada = apontamento['qtdProcessada'] ?? 0;
    final responsavel = apontamento['responsavelSuperior'] ?? 'Não informado';
    final observacao = apontamento['observacao'] ?? '';
    final variables = apontamento['variables'] as Map<String, dynamic>?;
    final pauseHistory = apontamento['pauseHistory'] as List<dynamic>?;
    final totalElapsedSeconds = apontamento['totalElapsedSeconds'] as int?;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF546E7A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalhes do Apontamento',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            estagio.title,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações gerais
                      _buildInfoCard(
                        'Informações Gerais',
                        [
                          _buildInfoRow(
                              'Quantidade Processada', '$qtdProcessada peles'),
                          _buildInfoRow('Responsável/Superior', responsavel),
                          if (observacao.isNotEmpty)
                            _buildInfoRow('Observação', observacao),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tempos
                      _buildInfoCard(
                        'Linha do Tempo',
                        [
                          if (start != null)
                            _buildInfoRow('Início', dtFormat.format(start),
                                icon: Icons.play_arrow),
                          if (end != null)
                            _buildInfoRow('Encerramento', dtFormat.format(end),
                                icon: Icons.stop),
                          if (start != null && end != null)
                            _buildInfoRow(
                              'Duração Total',
                              _formatDuration(end.difference(start)),
                              icon: Icons.timer,
                            ),
                          if (totalElapsedSeconds != null)
                            _buildInfoRow(
                              'Tempo Efetivo (sem pausas)',
                              _formatDuration(
                                  Duration(seconds: totalElapsedSeconds)),
                              icon: Icons.timer_outlined,
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Histórico de Pausas
                      if (pauseHistory != null && pauseHistory.isNotEmpty) ...[
                        _buildPauseHistoryCard(pauseHistory, dtFormat),
                        const SizedBox(height: 16),
                      ],

                      // Variáveis
                      if (variables != null && variables.isNotEmpty) ...[
                        _buildInfoCard(
                          'Variáveis Registradas',
                          variables.entries.map((e) {
                            return _buildInfoRow(e.key, e.value.toString());
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Botão Reabrir
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _reabrirApontamento(apontamento, estagio);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Reabrir Apontamento'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF546E7A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF546E7A),
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPauseHistoryCard(
      List<dynamic> pauseHistory, DateFormat dtFormat) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pause_circle,
                    color: Color(0xFF546E7A), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Histórico de Pausas (${pauseHistory.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...pauseHistory.asMap().entries.map((entry) {
              final idx = entry.key;
              final pause = entry.value as Map<String, dynamic>;
              final pauseTime = DateTime.parse(pause['pauseTime'] as String);
              final resumeTime = pause['resumeTime'] != null
                  ? DateTime.parse(pause['resumeTime'] as String)
                  : null;
              final justificativa = pause['justificativa'] as String?;
              final pauseDuration = pause['pauseDuration'] as int?;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Pausa ${idx + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (pauseDuration != null)
                          Text(
                            'Duração: ${_formatDuration(Duration(seconds: pauseDuration))}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF757575),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Pausado em', dtFormat.format(pauseTime)),
                    if (resumeTime != null)
                      _buildInfoRow('Retomado em', dtFormat.format(resumeTime)),
                    if (justificativa != null)
                      _buildInfoRow('Motivo', justificativa),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: const Color(0xFF757575)),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF616161),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${seconds}s';
  }

  void _reabrirApontamento(
      Map<String, dynamic> apontamento, StageModel estagio) {
    // Implementar lógica de reabrir apontamento
    // Por enquanto, vamos apenas navegar para a tela de apontamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de reabrir será implementada'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _abrirApontamentosSalvos() {
    // Coletar todos os apontamentos usando as chaves únicas
    final Map<String, List<Map<String, dynamic>>> todosApontamentos = {};
    final Map<String, ApontamentoItem> apontamentoItems = {};
    int totalApontamentos = 0;

    // Percorrer todos os itens de apontamento disponíveis
    for (var item in _itensApontamento) {
      final uniqueKey = _getUniqueKey(item);
      final apontamentos = storage.getApontamentos(uniqueKey);
      if (apontamentos.isNotEmpty) {
        // Usar o código do estágio como chave de agrupamento para o dialog
        if (!todosApontamentos.containsKey(item.estagio.code)) {
          todosApontamentos[item.estagio.code] = [];
        }
        todosApontamentos[item.estagio.code]!.addAll(apontamentos);
        apontamentoItems[uniqueKey] = item;
        totalApontamentos += apontamentos.length;
      }
    }

    if (totalApontamentos == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum apontamento salvo encontrado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar dialog com lista de apontamentos
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF546E7A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Apontamentos Salvos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade100,
                child: Text(
                  'Total: $totalApontamentos apontamento(s) em ${todosApontamentos.length} estágio(s)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Lista de apontamentos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableStages.length,
                  itemBuilder: (context, index) {
                    final estagio = availableStages[index];
                    final apontamentos = todosApontamentos[estagio.code] ?? [];

                    if (apontamentos.isEmpty) return const SizedBox.shrink();

                    // Somar todas as peles processadas deste estágio (de todos os artigos)
                    int processadaTotal = 0;
                    for (var apontamento in apontamentos) {
                      processadaTotal +=
                          (apontamento['qtdProcessada'] as int?) ?? 0;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () {
                          // Ao clicar, mostrar lista de apontamentos deste estágio
                          if (apontamentos.isNotEmpty) {
                            _mostrarListaApontamentos(
                                context, estagio, apontamentos);
                          }
                        },
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF546E7A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            estagio.postoTrabalho,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          estagio.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${apontamentos.length} apontamento(s) | $processadaTotal peles',
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF546E7A),
        foregroundColor: Colors.white,
        title: const Text(
          'APONTAMENTO DE PRODUÇÃO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Banner de seleção (Filial e Posto)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF546E7A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.filial.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.white38,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.settings, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.postoTrabalho.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Instrução
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: const Text(
              'Clique no item para realizar o apontamento',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 14,
              ),
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Filtro por Ordem
                    Expanded(
                      child: TextField(
                        controller: _filtroOF,
                        decoration: InputDecoration(
                          hintText: 'Ordem',
                          prefixIcon: const Icon(Icons.assignment, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Filtro por Artigo
                    Expanded(
                      child: TextField(
                        controller: _filtroArtigo,
                        decoration: InputDecoration(
                          hintText: 'Artigo',
                          prefixIcon: const Icon(Icons.inventory_2, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Filtro por Crust Item
                    Expanded(
                      child: TextField(
                        controller: _filtroCrustItem,
                        decoration: InputDecoration(
                          hintText: 'Crust Item',
                          prefixIcon: const Icon(Icons.label, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Filtro por data
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _selecionarData,
                        icon: Icon(
                          Icons.calendar_today,
                          color: _dataFiltro != null
                              ? const Color(0xFF1976D2)
                              : const Color(0xFF757575),
                        ),
                        tooltip: _dataFiltro != null
                            ? dfDate.format(_dataFiltro!)
                            : 'Filtrar por data',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contador de resultados + Botão de apontamentos salvos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFEEEEEE),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_itensFiltrados.length} apontamento(s) disponível(is)',
                  style: const TextStyle(
                    color: Color(0xFF616161),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _abrirApontamentosSalvos,
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text('Ver Apontamentos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF546E7A),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Lista de apontamentos
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _itensFiltrados.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum apontamento encontrado',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _itensFiltrados.length,
                        itemBuilder: (context, index) {
                          final item = _itensFiltrados[index];
                          return _buildApontamentoCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildApontamentoCard(ApontamentoItem item) {
    // Obter informações de apontamentos salvos usando chave única
    final uniqueKey = _getUniqueKey(item);
    final apontamentos = storage.getApontamentos(uniqueKey);
    final qtdApontamentos = apontamentos.length;
    final info = storage.getStageInfo(uniqueKey);
    final processada = info['processada'] as int;
    final status = info['status'] as StageProgressStatus;

    // Determinar cor do status
    Color? statusBadgeColor;
    String? statusText;

    if (status == StageProgressStatus.finalizado) {
      statusBadgeColor = Colors.blue;
      statusText = 'Finalizado';
    } else if (status == StageProgressStatus.encerrado) {
      statusBadgeColor = Colors.orange;
      statusText = 'Encerrado';
    } else if (status == StageProgressStatus.emProducao) {
      statusBadgeColor = Colors.green;
      statusText = 'Em Produção';
    } else if (status == StageProgressStatus.parado) {
      statusBadgeColor = Colors.amber;
      statusText = 'Pausado';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _abrirApontamento(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha 1: Ordem + Posto de Trabalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Ordem: ${item.ordem.Doc}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF546E7A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Posto: ${item.estagio.postoTrabalho}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Linha 2: Crust Item
              Row(
                children: [
                  const Icon(
                    Icons.label,
                    size: 16,
                    color: Color(0xFF757575),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Crust Item: ${item.artigo.crustItem}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF616161),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Linha 3: Artigo
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2,
                    size: 16,
                    color: Color(0xFF757575),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Artigo: ${item.artigo.descricao}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF424242),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Linha 4: Estágio
              Row(
                children: [
                  const Icon(
                    Icons.settings,
                    size: 16,
                    color: Color(0xFF757575),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Estágio: ${item.estagio.title}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Linha 5: Status e Apontamentos
              if (qtdApontamentos > 0 || statusText != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: statusBadgeColor ?? Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          qtdApontamentos > 0
                              ? '$qtdApontamentos apontamento(s) | $processada peles processadas'
                              : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (statusText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBadgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
