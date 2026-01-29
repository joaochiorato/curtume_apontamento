import 'package:flutter/material.dart';
import '../models/filial_model.dart';
import 'orders_page.dart';

/// Página de seleção de Filial e Posto de Trabalho
class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  FilialModel? _filialSelecionada;
  PostoTrabalhoModel? _postoSelecionado;

  bool get _podeAvancar => _filialSelecionada != null && _postoSelecionado != null;

  void _avancar() {
    if (!_podeAvancar) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersPage(
          filial: _filialSelecionada!,
          postoTrabalho: _postoSelecionado!,
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
          'SELEÇÃO DE POSTO DE TRABALHO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone e título
                    const Icon(
                      Icons.business,
                      size: 64,
                      color: Color(0xFF546E7A),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selecione a Filial e o Posto de Trabalho',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escolha onde deseja realizar os apontamentos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Dropdown Filial
                    const Text(
                      'Filial',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<FilialModel>(
                          isExpanded: true,
                          value: _filialSelecionada,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Selecione a filial'),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          borderRadius: BorderRadius.circular(8),
                          items: filiaisDisponiveis.map((filial) {
                            return DropdownMenuItem<FilialModel>(
                              value: filial,
                              child: Row(
                                children: [
                                  const Icon(Icons.business, size: 20, color: Color(0xFF546E7A)),
                                  const SizedBox(width: 12),
                                  Text(
                                    filial.displayName,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _filialSelecionada = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dropdown Posto de Trabalho
                    const Text(
                      'Posto de Trabalho',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PostoTrabalhoModel>(
                          isExpanded: true,
                          value: _postoSelecionado,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Selecione o posto de trabalho'),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          borderRadius: BorderRadius.circular(8),
                          items: postosTrabalhoDisponiveis.map((posto) {
                            return DropdownMenuItem<PostoTrabalhoModel>(
                              value: posto,
                              child: Row(
                                children: [
                                  const Icon(Icons.settings, size: 20, color: Color(0xFF546E7A)),
                                  const SizedBox(width: 12),
                                  Text(
                                    posto.displayName,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _postoSelecionado = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botão Avançar
                    ElevatedButton(
                      onPressed: _podeAvancar ? _avancar : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF546E7A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: _podeAvancar ? 2 : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Avançar para Apontamentos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: _podeAvancar ? Colors.white : Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
