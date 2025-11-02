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
    
    _ordens = [
      OrdemModel(
        of: '18283',
        cliente: 'Cliente A',
        data: DateTime.now(),
        status: 'Em Produção',
        artigos: [
          ArtigoModel(codigo: 'ART001', descricao: 'QUARTZO', quantidade: 350),
          ArtigoModel(codigo: 'ART002', descricao: 'GRANITO', quantidade: 200),
        ],
      ),
      OrdemModel(
        of: '18284',
        cliente: 'Cliente B',
        data: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Aguardando',
        artigos: [
          ArtigoModel(codigo: 'ART003', descricao: 'MÁRMORE', quantidade: 150),
        ],
      ),
      OrdemModel(
        of: '18285',
        cliente: 'Cliente C',
        data: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Em Produção',
        artigos: [
          ArtigoModel(codigo: 'ART004', descricao: 'BASALTO', quantidade: 400),
          ArtigoModel(codigo: 'ART005', descricao: 'ARDÓSIA', quantidade: 250),
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
            ordem.of.toLowerCase().contains(_filtroOF.text.toLowerCase());

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
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() => _dataFiltro = picked);
      _aplicarFiltros();
    }
  }

  void _limparFiltroData() {
    setState(() => _dataFiltro = null);
    _aplicarFiltros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('SELECIONE A ORDEM'),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Instrução no topo - estilo Frigosoft
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: const Text(
                    'Click duas vezes no item para selecionar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Filtros
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _filtroOF,
                          decoration: InputDecoration(
                            labelText: 'Filtrar por OF',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _selecionarData,
                        icon: const Icon(Icons.calendar_today),
                        style: IconButton.styleFrom(
                          backgroundColor: _dataFiltro != null
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF424242),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      if (_dataFiltro != null)
                        IconButton(
                          onPressed: _limparFiltroData,
                          icon: const Icon(Icons.clear),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                    ],
                  ),
                ),

                // Contador de resultados
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFFE0E0E0),
                  child: Text(
                    '${_ordensFiltradas.length} ordem(ns) encontrada(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),

                // Lista de ordens
                Expanded(
                  child: _ordensFiltradas.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma ordem encontrada',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _ordensFiltradas.length,
                          itemBuilder: (context, index) {
                            final ordem = _ordensFiltradas[index];
                            return _buildOrderCard(ordem);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderCard(OrdemModel ordem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onDoubleTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticlesPage(of: ordem),
            ),
          );
        },
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
                    'OF: ${ordem.of}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  _buildStatusBadge(ordem.status),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Informações detalhadas
              _buildInfoRow('Cliente', ordem.cliente),
              const SizedBox(height: 6),
              _buildInfoRow('Data', dfDate.format(ordem.data)),
              const SizedBox(height: 6),
              _buildInfoRow('Artigos', '${ordem.artigos.length} item(ns)'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF424242),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isProduction = status == 'Em Produção';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isProduction 
            ? const Color(0xFF4CAF50) 
            : const Color(0xFFFF9800),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
