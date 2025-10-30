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
    // Dados de exemplo (mockados)
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
        // Filtro por número da OF
        final matchOF = _filtroOF.text.isEmpty ||
            ordem.of.toLowerCase().contains(_filtroOF.text.toLowerCase());

        // Filtro por data
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
      setState(() {
        _dataFiltro = picked;
        _aplicarFiltros();
      });
    }
  }

  void _limparFiltros() {
    setState(() {
      _filtroOF.clear();
      _dataFiltro = null;
      _ordensFiltradas = _ordens;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Produção'),
        actions: [
          // Contador de ordens filtradas
          if (!_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_ordensFiltradas.length} OF(s)',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Área de filtros
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF37474F),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Filtro por número da OF
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _filtroOF,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Buscar OF',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                hintText: 'Ex: 18283',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                prefixIcon: const Icon(Icons.search, color: Colors.white),
                                suffixIcon: _filtroOF.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.white),
                                        onPressed: () => _filtroOF.clear(),
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Filtro por data
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: _selecionarData,
                              icon: const Icon(Icons.calendar_today, size: 18, color: Colors.white),
                              label: Text(
                                _dataFiltro == null
                                    ? 'Data'
                                    : dfDate.format(_dataFiltro!),
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Botão limpar filtros
                          if (_filtroOF.text.isNotEmpty || _dataFiltro != null)
                            IconButton(
                              onPressed: _limparFiltros,
                              icon: const Icon(Icons.filter_alt_off, color: Colors.white),
                              tooltip: 'Limpar filtros',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Lista de ordens filtradas
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
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF546E7A),
                                  child: Text(
                                    ordem.of.substring(ordem.of.length - 2),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'OF ${ordem.of}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Cliente: ${ordem.cliente}'),
                                    Text('Data: ${dfDate.format(ordem.data)}'),
                                    Text('${ordem.artigos.length} artigo(s)'),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ordem.status == 'Em Produção'
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ordem.status,
                                    style: TextStyle(
                                      color: ordem.status == 'Em Produção'
                                          ? Colors.green[700]
                                          : Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ArticlesPage(of: ordem),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
