import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../widgets/stage_button.dart';
import '../widgets/stage_form.dart';

class StageMemoryStorage {
  static final StageMemoryStorage _instance = StageMemoryStorage._internal();
  factory StageMemoryStorage() => _instance;
  StageMemoryStorage._internal();

  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, bool> _finalized = {};

  void saveData(String stageCode, Map<String, dynamic> data, {bool finalizar = true}) {
    _data[stageCode] = data;
    _finalized[stageCode] = finalizar;
  }

  Map<String, dynamic>? getData(String stageCode) => _data[stageCode];
  bool isFinalized(String stageCode) => _finalized[stageCode] ?? false;
  int getFinishedCount() => _finalized.values.where((f) => f).length;
  void clear(String stageCode) {
    _data.remove(stageCode);
    _finalized.remove(stageCode);
  }
  void clearAll() {
    _data.clear();
    _finalized.clear();
  }
}

class StagePage extends StatefulWidget {
  final Map<String, String> articleHeader;
  const StagePage({super.key, required this.articleHeader});

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  final storage = StageMemoryStorage();

  void _openStageForm(StageModel stage) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(stage.title)),
        // ✅ CORREÇÃO: Remover SingleChildScrollView
        // O StageForm já tem seu próprio scroll interno
        body: StageForm(
          stage: stage,
          initialData: storage.getData(stage.code),
          onSaved: (data) {
            storage.saveData(stage.code, data, finalizar: true);
            setState(() {});
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${stage.title} salvo!')),
            );
          },
        ),
      ),
    ));
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Dados'),
        content: const Text('Deseja limpar todos os dados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              storage.clearAll();
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finishedCount = storage.getFinishedCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estágios'),
        actions: [
          IconButton(
            onPressed: _clearAllData,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpar todos os dados',
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OF: ${widget.articleHeader['of'] ?? '-'}'),
                  Text('Artigo: ${widget.articleHeader['artigo'] ?? '-'}'),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 8),
                  Text('Progresso: $finishedCount de ${availableStages.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: availableStages.length,
              itemBuilder: (context, index) {
                final stage = availableStages[index];
                final isFinalizado = storage.isFinalized(stage.code);
                return StageButton(
                  label: stage.title,
                  finalizado: isFinalizado,
                  onTap: () => _openStageForm(stage),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}