import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
    final raw = await rootBundle.loadString('assets/data/ofs_sample.json');
    final j = json.decode(raw) as Map<String, dynamic>;
    _ordens = (j['ordens'] as List).map((e) => OrdemModel.fromJson(e)).toList();
    _ordensFiltradas = _ordens;
    setState(() => _loading = false);
  }

  void _aplicarFiltros() {
    setState(() {
      _ordensFiltradas = _ordens.where((ordem) {
        final matchOF = _filtroOF.text.isEmpty ||
            ordem.of.toLowerCase().contains(_filtroOF.text.toLowerCase());
        return matchOF;
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
        title: const Text('ORDENS DE PRODUÇÃO'),
        actions: [
          // Contador de ordens
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar:
                    const Icon(Icons.assignment, size: 18, color: Colors.white),
                label: Text(
                  '${_ordensFiltradas.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFF424242),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando ordens...'),
                ],
              ),
            )
          : Column(
              children: [
                // 🔍 ÁREA DE FILTROS
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo de busca
                      TextField(
                        controller: _filtroOF,
                        decoration: InputDecoration(
                          labelText: 'Buscar Ordem de Produção',
                          hintText: 'Digite o número da OF...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _filtroOF.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _filtroOF.clear(),
                                )
                              : null,
                        ),
                      ),

                      // Botões de filtro
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Filtro por data
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selecionarData,
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                _dataFiltro == null
                                    ? 'Filtrar por Data'
                                    : dfDate.format(_dataFiltro!),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Botão limpar
                          if (_filtroOF.text.isNotEmpty || _dataFiltro != null)
                            IconButton(
                              onPressed: _limparFiltros,
                              icon: const Icon(Icons.filter_alt_off),
                              tooltip: 'Limpar filtros',
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE53935).withOpacity(0.1),
                                foregroundColor: const Color(0xFFE53935),
                              ),
                            ),
                        ],
                      ),

                      // Chips de filtros ativos
                      if (_filtroOF.text.isNotEmpty || _dataFiltro != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (_filtroOF.text.isNotEmpty)
                              Chip(
                                avatar: const Icon(Icons.assignment, size: 16),
                                label: Text('OF: ${_filtroOF.text}'),
                                onDeleted: () => _filtroOF.clear(),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                backgroundColor:
                                    const Color(0xFF4CAF50).withOpacity(0.1),
                              ),
                            if (_dataFiltro != null)
                              Chip(
                                avatar:
                                    const Icon(Icons.calendar_today, size: 16),
                                label: Text(dfDate.format(_dataFiltro!)),
                                onDeleted: () {
                                  setState(() {
                                    _dataFiltro = null;
                                    _aplicarFiltros();
                                  });
                                },
                                deleteIcon: const Icon(Icons.close, size: 16),
                                backgroundColor:
                                    const Color(0xFF4CAF50).withOpacity(0.1),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Divider
                const Divider(height: 1),

                // 📋 LISTA DE ORDENS
                Expanded(
                  child: _ordensFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma ordem encontrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tente ajustar os filtros',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _ordensFiltradas.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final ordem = _ordensFiltradas[i];
                            return _buildOrderCard(context, ordem);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // 🎨 Card de Ordem
  Widget _buildOrderCard(BuildContext context, OrdemModel ordem) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticlesPage(of: ordem),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF424242).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment,
                  size: 28,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(width: 16),

              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'OF ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ordem.of,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF424242).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                size: 14,
                                color: Color(0xFF424242),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${ordem.artigos.length} artigo(s)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF424242),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Seta
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
