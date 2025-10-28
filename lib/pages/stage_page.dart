import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../widgets/stage_button.dart';
import '../widgets/stage_form.dart';

// Singleton para manter dados em memória durante toda a execução do app
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

  Map<String, dynamic>? getData(String stageCode) {
    return _data[stageCode];
  }

  bool isFinalized(String stageCode) {
    return _finalized[stageCode] ?? false;
  }

  int getFinishedCount() {
    return _finalized.values.where((f) => f).length;
  }

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
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StageForm(
                  stage: stage,
                  initialData: storage.getData(stage.code),
                  onSaved: (data) {
                    storage.saveData(stage.code, data, finalizar: true);
                    setState(() {}); // Atualiza a tela
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${stage.title} salvo com sucesso!')),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Dados'),
        content: const Text('Deseja realmente limpar todos os dados dos estágios?'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dados limpos')),
              );
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stages = getAllStages();
    final finishedCount = storage.getFinishedCount();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estágios de Produção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpar todos os dados',
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com informações do artigo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 12, 
                  runSpacing: 8,
                  children: [
                    Text('OF: ${widget.articleHeader['of'] ?? '-'}'),
                    Text('Artigo: ${widget.articleHeader['artigo'] ?? '-'}'),
                    Text('Cor: ${widget.articleHeader['cor'] ?? '-'}'),
                    Text('Classe: ${widget.articleHeader['classe'] ?? '-'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Indicador de progresso
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20),
                    const SizedBox(width: 8),
                    Text('Progresso: $finishedCount de ${stages.length} estágios finalizados'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Lista de estágios
            Expanded(
              child: ListView.builder(
                itemCount: stages.length,
                itemBuilder: (context, index) {
                  final stage = stages[index];
                  final isFinalizado = storage.isFinalized(stage.code);
                  
                  return StageButton(
                    label: 'APONTAR ${stage.title}',
                    icon: stage.icon,
                    cor: stage.color,
                    finalizado: isFinalizado,
                    onTap: () => _openStageForm(stage),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
