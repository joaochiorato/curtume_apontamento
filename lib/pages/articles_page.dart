import 'package:flutter/material.dart';
import '../models/order.dart';
import 'stage_page.dart';

class ArticlesPage extends StatelessWidget {
  final OrdemModel of;
  const ArticlesPage({super.key, required this.of});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OF ${of.of}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('${of.artigos.length} artigo(s)'),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: of.artigos.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (_, i) {
          final a = of.artigos[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${i + 1}'),
              ),
              title: Text(a.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Código: ${a.codigo}\nQuantidade: ${a.quantidade}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              isThreeLine: true,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => StagePage(
                    articleHeader: {
                      'of': of.of,
                      'artigo': a.descricao,
                      'codigo': a.codigo,
                    },
                  ),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}
