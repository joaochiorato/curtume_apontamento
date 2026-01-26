import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import 'articles_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _loading = true;
  List<OrdemModel> _ordens = [];
  List<OrdemModel> _ordensFiltradas = [];

  final _filtroOF = TextEditingController();
  DateTime? _dataFiltro;
  final dfDate = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _load();
    _filtroOF.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _filtroOF.dispose();
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
            espFinal: '1063 1.0/1.4',
            classe: 'G119',
            descricaoCompleta: 'COURO MERCADO EXTERNO',
          ),
        ],
      ),
    ];

    _ordensFiltradas = _ordens;
    setState(() => _loading = false);
  }

  void _aplicarFiltros() {
    setState(() {
      _ordensFiltradas = _ordens.where((ordem) {
        final matchOF = _filtroOF.text.isEmpty ||
            ordem.Doc.toLowerCase().contains(_filtroOF.text.toLowerCase());

        final matchData = _dataFiltro == null ||
            (ordem.data.year == _dataFiltro!.year &&
                ordem.data.month == _dataFiltro!.month &&
                ordem.data.day == _dataFiltro!.day);

        return matchOF && matchData;
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

  void _limparFiltroData() {
    setState(() {
      _dataFiltro = null;
      _aplicarFiltros();
    });
  }

  void _abrirArtigos(OrdemModel ordem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticlesPage(of: ordem),
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
          'SELECIONE A ORDEM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Instrução
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: const Text(
              'Click duas vezes no item para selecionar',
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
            child: Row(
              children: [
                // Filtro por OF
                Expanded(
                  child: TextField(
                    controller: _filtroOF,
                    decoration: InputDecoration(
                      hintText: 'Filtro por Ordem',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

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
          ),

          // Contador de resultados
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFEEEEEE),
            child: Text(
              '${_ordensFiltradas.length} ordem(ns) encontrada(s)',
              style: const TextStyle(
                color: Color(0xFF616161),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Lista de ordens
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _ordensFiltradas.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma ordem encontrada',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _ordensFiltradas.length,
                        itemBuilder: (context, index) {
                          final ordem = _ordensFiltradas[index];
                          return _buildOrdemCard(ordem);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdemCard(OrdemModel ordem) {
    // Determina cor do status
    Color statusColor;
    String statusText;

    switch (ordem.status) {
      case StatusOrdem.emProducao:
        statusColor = const Color(0xFF4CAF50);
        statusText = 'Em Produção';
        break;
      case StatusOrdem.Aguardando:
        statusColor = const Color(0xFFFF9800);
        statusText = 'Não Iniciado';
        break;
      case StatusOrdem.finalizada:
        statusColor = const Color(0xFF2196F3);
        statusText = 'Finalizada';
        break;
      case StatusOrdem.cancelada:
        statusColor = const Color(0xFFF44336);
        statusText = 'Cancelada';
        break;
      default:
        statusColor = const Color(0xFF9E9E9E);
        statusText = 'Indefinido';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onDoubleTap: () => _abrirArtigos(ordem),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: OF + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ordem: ${ordem.Doc}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info: Cliente
              _buildInfoRow('Cliente:', ordem.cliente),
              const SizedBox(height: 4),

              // Info: Data
              _buildInfoRow('Data:', dfDate.format(ordem.data)),
              const SizedBox(height: 4),

              // Info: Artigos
              _buildInfoRow('Artigos:', '${ordem.artigos.length} item(ns)'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
