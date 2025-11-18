import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../widgets/stage_form.dart';
import 'stage_memory_storage.dart';

class StagePage extends StatefulWidget {
  final Map<String, String> articleHeader;
  const StagePage({super.key, required this.articleHeader});

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  final storage = StageMemoryStorage();

  @override
  void initState() {
    super.initState();
    final qtdTotal =
        int.tryParse(widget.articleHeader['quantidade'] ?? '0') ?? 0;
    storage.setQuantidadeTotal(qtdTotal);
  }

  void _openStageForm(StageModel stage) {
    final info = storage.getStageInfo(stage.code);
    final processada = info['processada'] as int;
    final total = info['total'] as int;
    final restante = info['restante'] as int;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(stage.title),
          actions: [
            if (total > 0)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '$processada / $total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: restante == 0 ? Colors.green : Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: StageForm(
          stage: stage,
          initialData: storage.getLastData(stage.code),
          quantidadeTotal: total,
          quantidadeProcessada: processada,
          quantidadeRestante: restante,
          onSaved: (data) {
            final qtdApontamento =
                int.tryParse(data['qtdProcessada']?.toString() ?? '0') ?? 0;

            if (processada + qtdApontamento > total) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Quantidade excede o total! Restam apenas $restante peles.',
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
              return;
            }

            final finalizarEstagio = (processada + qtdApontamento) >= total;
            storage.saveData(stage.code, data, finalizar: finalizarEstagio);

            setState(() {});
            Navigator.pop(context);

            final novoTotal = processada + qtdApontamento;
            final msg = finalizarEstagio
                ? '✓ ${stage.title} FINALIZADO! ($novoTotal / $total)'
                : '✓ Apontamento salvo! ($novoTotal / $total) - Restam ${total - novoTotal}';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: finalizarEstagio ? Colors.green : Colors.blue,
                duration: const Duration(seconds: 3),
              ),
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

  // ✅ NOVO: Mostra histórico de apontamentos
  void _showStageDetails(StageModel stage) {
    final info = storage.getStageInfo(stage.code);
    final apontamentos = storage.getApontamentos(stage.code);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${stage.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Total:', '${info['total']} peles'),
              _buildInfoRow('Processada:', '${info['processada']} peles'),
              _buildInfoRow('Restante:', '${info['restante']} peles'),
              _buildInfoRow(
                'Percentual:',
                '${info['percentual'].toStringAsFixed(1)}%',
              ),
              const Divider(height: 24),
              Text(
                'Apontamentos (${apontamentos.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (apontamentos.isEmpty)
                const Text('Nenhum apontamento realizado.')
              else
                ...apontamentos.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final apt = entry.value;
                  final qtd = apt['qtdProcessada'] ?? 0;
                  final resp = apt['responsavel'] ?? 'Não informado';
                  final start = apt['start'] != null
                      ? DateTime.parse(apt['start'])
                          .toString()
                          .substring(11, 16)
                      : '-';
                  final end = apt['end'] != null
                      ? DateTime.parse(apt['end']).toString().substring(11, 16)
                      : '-';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Apontamento #$idx',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  '$qtd peles',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                resp,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '$start - $end',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finishedCount = storage.getFinishedCount();
    final qtdTotal = storage.getQuantidadeTotal();

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
          // Card com informações da OF/Artigo
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OF: ${widget.articleHeader['of'] ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          '$qtdTotal peles',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Artigo: ${widget.articleHeader['artigo'] ?? '-'}'),
                ],
              ),
            ),
          ),

          // Card de progresso
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 8),
                  Text(
                    'Progresso: $finishedCount de ${availableStages.length} estágios',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lista de estágios
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: availableStages.length,
              itemBuilder: (context, index) {
                final stage = availableStages[index];
                final info = storage.getStageInfo(stage.code);
                final isFinalizado = info['completo'] as bool;
                final processada = info['processada'] as int;
                final restante = info['restante'] as int;
                final apontamentos = info['apontamentos'] as int;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _openStageForm(stage),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Ícone de status
                          Icon(
                            isFinalizado
                                ? Icons.check_circle
                                : processada > 0
                                    ? Icons.play_circle
                                    : Icons.circle_outlined,
                            color: isFinalizado
                                ? Colors.green
                                : processada > 0
                                    ? Colors.orange
                                    : Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(width: 12),

                          // Informações do estágio
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$processada / $qtdTotal peles',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                if (apontamentos > 0)
                                  Text(
                                    '$apontamentos apontamento${apontamentos > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Badge de falta
                          if (restante > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Text(
                                'Faltam $restante',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          // ✅ NOVO: Botão de histórico
                          if (apontamentos > 0) ...[
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.history),
                              color: Colors.blue.shade700,
                              tooltip: 'Apontamentos',
                              onPressed: () => _showStageDetails(stage),
                            ),
                          ],
                        ],
                      ),
                    ),
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
