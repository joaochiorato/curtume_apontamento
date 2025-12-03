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

  void _openStageForm(StageModel stage, {Map<String, dynamic>? dadosParaEditar, int? indexApontamento}) {
    final info = storage.getStageInfo(stage.code);
    final processada = info['processada'] as int;
    final total = info['total'] as int;
    final restante = info['restante'] as int;
    final currentStatus = info['status'] as StageProgressStatus;
    final startTime = info['startTime'] as DateTime?;
    final elapsedTime = info['elapsedTime'] as Duration?;
    final lastResumeTime = info['lastResumeTime'] as DateTime?; // ✅ Adicionado
    final savedFormData = info['formData'] as StageFormData?;

    int restanteAjustado = restante;
    int processadaAjustada = processada;
    if (dadosParaEditar != null && indexApontamento != null) {
      final qtdApontamentoOriginal = dadosParaEditar['qtdProcessada'] as int? ?? 0;
      restanteAjustado = restante + qtdApontamentoOriginal;
      processadaAjustada = processada - qtdApontamentoOriginal;
    }

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
                    '${dadosParaEditar != null ? processadaAjustada : processada} / $total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: restanteAjustado == 0 ? Colors.green : Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: StageForm(
          stage: stage,
          initialData: dadosParaEditar ?? storage.getLastData(stage.code),
          quantidadeTotal: total,
          quantidadeProcessada: dadosParaEditar != null ? processadaAjustada : processada,
          quantidadeRestante: restanteAjustado,
          isEditing: dadosParaEditar != null,
          currentStatus: dadosParaEditar != null ? StageProgressStatus.finalizado : currentStatus,
          startTime: dadosParaEditar != null ? null : startTime,
          elapsedTime: dadosParaEditar != null ? null : elapsedTime,
          lastResumeTime: dadosParaEditar != null ? null : lastResumeTime, // ✅ Adicionado
          savedFormData: dadosParaEditar != null ? null : savedFormData,
          onStatusChanged: (status, start, elapsed, lastResume) {
            // ✅ Salvar status, startTime, elapsedTime e lastResumeTime
            storage.setStageStatus(stage.code, status);
            if (start != null) {
              storage.setStageStartTime(stage.code, start);
            }
            if (elapsed != null) {
              storage.setStageElapsedTime(stage.code, elapsed);
            }
            if (lastResume != null) {
              storage.setStageLastResumeTime(stage.code, lastResume);
            }
            // ✅ Não chamar setState aqui - será atualizado ao voltar
          },
          onFormDataChanged: (formData) {
            storage.setStageFormData(stage.code, formData);
          },
          onSaved: (data) {
            final qtdApontamento =
                int.tryParse(data['qtdProcessada']?.toString() ?? '0') ?? 0;

            if ((dadosParaEditar != null ? processadaAjustada : processada) + qtdApontamento > total) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Quantidade excede o total! Restam apenas $restanteAjustado peles.',
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
              return;
            }

            if (dadosParaEditar != null && indexApontamento != null) {
              storage.updateApontamento(stage.code, indexApontamento, data);
            } else {
              final finalizarEstagio = (processada + qtdApontamento) >= total;
              storage.saveData(stage.code, data, finalizar: finalizarEstagio);
            }

            setState(() {});
            Navigator.pop(context);

            final novoProcessado = dadosParaEditar != null 
                ? processadaAjustada + qtdApontamento
                : processada + qtdApontamento;
            final finalizou = novoProcessado >= total;
            
            final msg = dadosParaEditar != null
                ? '✓ Apontamento atualizado! ($novoProcessado / $total)'
                : finalizou
                    ? '✓ ${stage.title} FINALIZADO! ($novoProcessado / $total)'
                    : '✓ Apontamento salvo! ($novoProcessado / $total) - Restam ${total - novoProcessado}';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: finalizou ? Colors.green : Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    )).then((_) {
      setState(() {});
    });
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

  void _showAllStagesHistory() {
    int totalApontamentos = 0;
    int totalPelesProcessadas = 0;
    
    for (final stage in availableStages) {
      totalApontamentos += storage.getApontamentos(stage.code).length;
      totalPelesProcessadas += storage.getQuantidadeProcessada(stage.code);
    }

    // ✅ Quantidade Total da OF (não a soma dos apontamentos)
    final qtdTotalOF = storage.getQuantidadeTotal();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.history, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Histórico de Apontamentos'),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Total de Apontamentos:',
                        '$totalApontamentos',
                      ),
                      const SizedBox(height: 4),
                      // ✅ CORRIGIDO: Mostra quantidade da OF, não soma
                      _buildSummaryRow(
                        'Quantidade da OF:',
                        '$qtdTotalOF peles',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                if (totalApontamentos == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Nenhum apontamento realizado.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...availableStages.map((stage) {
                    final stageApontamentos = storage.getApontamentos(stage.code);
                    if (stageApontamentos.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final info = storage.getStageInfo(stage.code);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: info['completo'] == true
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                info['completo'] == true
                                    ? Icons.check_circle
                                    : Icons.play_circle,
                                size: 18,
                                color: info['completo'] == true
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  stage.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '${info['processada']} / ${info['total']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: info['completo'] == true
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        ...stageApontamentos.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final apt = entry.value;
                          final qtd = apt['qtdProcessada'] ?? 0;
                          final resp = apt['responsavelSuperior'] ?? 'Não informado';
                          final start = apt['start'] != null
                              ? DateTime.parse(apt['start'])
                                  .toString()
                                  .substring(11, 16)
                              : '-';
                          final end = apt['end'] != null
                              ? DateTime.parse(apt['end'])
                                  .toString()
                                  .substring(11, 16)
                              : '-';

                          String duracao = '-';
                          if (apt['start'] != null && apt['end'] != null) {
                            final startDt = DateTime.parse(apt['start']);
                            final endDt = DateTime.parse(apt['end']);
                            final diff = endDt.difference(startDt);
                            final minutes = diff.inMinutes;
                            final seconds = diff.inSeconds.remainder(60);
                            duracao = '${minutes}m ${seconds}s';
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8, left: 8),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Apontamento #${idx + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.green.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          '$qtd peles',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Responsável: $resp',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Horário: $start → $end ($duracao)',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _openStageForm(
                                          stage,
                                          dadosParaEditar: apt,
                                          indexApontamento: idx,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange.shade700,
                                        side: BorderSide(color: Colors.orange.shade300),
                                      ),
                                      child: const Text('REABRIR'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
              ],
            ),
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(StageProgressStatus status, bool isComplete) {
    String text;
    Color bgColor;
    Color textColor;
    
    if (isComplete) {
      text = 'Finalizado';
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
    } else {
      switch (status) {
        case StageProgressStatus.aguardando:
          text = 'Aguardando';
          bgColor = Colors.grey.shade100;
          textColor = Colors.grey.shade700;
          break;
        case StageProgressStatus.emProducao:
          text = 'Em Produção';
          bgColor = Colors.green.shade100;
          textColor = Colors.green.shade700;
          break;
        case StageProgressStatus.parado:
          text = 'Parado';
          bgColor = Colors.orange.shade100;
          textColor = Colors.orange.shade700;
          break;
        case StageProgressStatus.finalizado:
          text = 'Aguardando';
          bgColor = Colors.grey.shade100;
          textColor = Colors.grey.shade700;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finishedCount = storage.getFinishedCount();
    final qtdTotal = storage.getQuantidadeTotal();

    int totalApontamentos = 0;
    for (final stage in availableStages) {
      totalApontamentos += storage.getApontamentos(stage.code).length;
    }

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

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Progresso: $finishedCount de ${availableStages.length} estágios',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showAllStagesHistory,
                    icon: const Icon(Icons.history, size: 18),
                    label: Text(
                      'Apontamentos${totalApontamentos > 0 ? ' ($totalApontamentos)' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
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
                final info = storage.getStageInfo(stage.code);
                final isComplete = info['completo'] as bool;
                final processada = info['processada'] as int;
                final apontamentos = info['apontamentos'] as int;
                final status = info['status'] as StageProgressStatus;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _openStageForm(stage),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            isComplete
                                ? Icons.check_circle
                                : status == StageProgressStatus.emProducao
                                    ? Icons.play_circle
                                    : status == StageProgressStatus.parado
                                        ? Icons.pause_circle
                                        : Icons.circle_outlined,
                            color: isComplete
                                ? Colors.green
                                : status == StageProgressStatus.emProducao
                                    ? Colors.green
                                    : status == StageProgressStatus.parado
                                        ? Colors.orange
                                        : Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(width: 12),

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

                          _buildStatusBadge(status, isComplete),
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