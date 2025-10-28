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
        // Filtro por número da OF
        final matchOF = _filtroOF.text.isEmpty ||
            ordem.of.toLowerCase().contains(_filtroOF.text.toLowerCase());

        // Filtro por data (simulado - se tivesse data na ordem)
        // Como não tem data no modelo, sempre retorna true
        // Você pode adicionar campo de data no modelo depois
        final matchData = true;

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
                    color: Colors.grey[900],
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
                              decoration: InputDecoration(
                                labelText: 'Buscar OF',
                                hintText: 'Ex: 18283',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _filtroOF.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => _filtroOF.clear(),
                                      )
                                    : null,
                                border: const OutlineInputBorder(),
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
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                _dataFiltro == null
                                    ? 'Data'
                                    : dfDate.format(_dataFiltro!),
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
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
                              icon: const Icon(Icons.filter_alt_off),
                              tooltip: 'Limpar filtros',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),
                      
                      // Indicador de filtros ativos
                      if (_filtroOF.text.isNotEmpty || _dataFiltro != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (_filtroOF.text.isNotEmpty)
                              Chip(
                                avatar: const Icon(Icons.filter_list, size: 16),
                                label: Text('OF: ${_filtroOF.text}'),
                                onDeleted: () => _filtroOF.clear(),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            if (_dataFiltro != null)
                              Chip(
                                avatar: const Icon(Icons.calendar_today, size: 16),
                                label: Text('Data: ${dfDate.format(_dataFiltro!)}'),
                                onDeleted: () {
                                  setState(() {
                                    _dataFiltro = null;
                                    _aplicarFiltros();
                                  });
                                },
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Lista de ordens filtradas
                Expanded(
                  child: _ordensFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[600],
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
                              TextButton.icon(
                                onPressed: _limparFiltros,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Limpar filtros'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _ordensFiltradas.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (_, i) {
                            final o = _ordensFiltradas[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF546E7A),
                                child: Text(
                                  o.of,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text('OF ${o.of}'),
                              subtitle: Text('${o.artigos.length} artigo(s)'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArticlesPage(of: o),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
