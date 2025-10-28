import 'package:flutter/material.dart';
import '../models/order.dart';
import '../widgets/order_info_card.dart';
import 'stage_page.dart';

class ArticlesPage extends StatelessWidget {
  final OrdemModel of;
  const ArticlesPage({super.key, required this.of});

  @override
  Widget build(BuildContext context) {
    // Dados da ordem (exemplo - você pode expandir isso)
    final orderData = {
      'of': of.of,
      'lote': '32666', // Adicione ao modelo depois
      'artigo': 'QUARTZO',
      'pve': '7315',
      'cor': 'E - BROWN',
      'classe': 'G119',
      'po': '7315CK08',
      'crustItem': '1165',
      'espFinal': '1.1/1.5',
      'nPcsNf': '350',
      'metragemNf': '21.295,25',
      'avg': '60,84',
      'nPcsEnx': '',
      'metragemEnx': '',
      'pesoLiquido': '9.855,00',
      'diferenca': '',
      'obs': '',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('OF ${of.of}'),
        actions: [
          // Indicador de quantidade de artigos
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: const Icon(Icons.inventory_2, size: 16),
                label: Text('${of.artigos.length} artigo(s)'),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Card com informações detalhadas da ordem
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  OrderInfoCard(orderData: orderData),

                  // Título da seção de artigos
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.list_alt, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'ARTIGOS DA ORDEM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de artigos
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: of.artigos.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0, indent: 16, endIndent: 16),
                    itemBuilder: (_, i) {
                      final a = of.artigos[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 83, 83, 83),
                        ),
                        title: Text('Artigo ${a.name}'),
                        subtitle: Text(
                            'PO ${a.po} • Cor ${a.cor} • Classe ${a.classe}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StagePage(
                                articleHeader: {
                                  'of': of.of,
                                  'artigo': a.name,
                                  'cor': a.cor,
                                  'classe': a.classe,
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
