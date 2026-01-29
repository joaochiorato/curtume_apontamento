import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../widgets/stage_form.dart';
import 'stage_memory_storage.dart';

/// Página que abre diretamente um estágio específico para apontamento
class DirectStagePage extends StatefulWidget {
  final Map<String, String> articleHeader;
  final StageModel stage;

  const DirectStagePage({
    super.key,
    required this.articleHeader,
    required this.stage,
  });

  @override
  State<DirectStagePage> createState() => _DirectStagePageState();
}

class _DirectStagePageState extends State<DirectStagePage> {
  final storage = StageMemoryStorage();

  /// Cria um identificador único para este apontamento específico
  /// Formato: "OF_CodigoArtigo_CodigoEstagio"
  String get _uniqueKey {
    final of = widget.articleHeader['of'] ?? '';
    final codigoArtigo = widget.articleHeader['codigo'] ?? '';
    final codigoEstagio = widget.stage.code;
    return '${of}_${codigoArtigo}_$codigoEstagio';
  }

  @override
  void initState() {
    super.initState();
    final qtdTotal =
        int.tryParse(widget.articleHeader['quantidade'] ?? '0') ?? 0;
    storage.setQuantidadeTotal(qtdTotal);
  }

  @override
  Widget build(BuildContext context) {
    final info = storage.getStageInfo(_uniqueKey);
    final processada = info['processada'] as int;
    final total = info['total'] as int;
    final restante = info['restante'] as int;
    final currentStatus = info['status'] as StageProgressStatus;
    final startTime = info['startTime'] as DateTime?;
    final elapsedTime = info['elapsedTime'] as Duration?;
    final lastResumeTime = info['lastResumeTime'] as DateTime?;
    final savedFormData = info['formData'] as StageFormData?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF546E7A),
        foregroundColor: Colors.white,
        title: Text(
          widget.stage.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
        stage: widget.stage,
        articleHeader: widget.articleHeader,
        initialData: storage.getLastData(_uniqueKey),
        quantidadeTotal: total,
        quantidadeProcessada: processada,
        quantidadeRestante: restante,
        isEditing: false,
        currentStatus: currentStatus,
        startTime: startTime,
        elapsedTime: elapsedTime,
        lastResumeTime: lastResumeTime,
        savedFormData: savedFormData,
        autoStart: currentStatus == StageProgressStatus.Aguardando, // ✅ Auto-iniciar apenas se não foi iniciado ainda
        onStatusChanged: (status, start, elapsed, lastResume) {
          storage.setStageStatus(_uniqueKey, status);
          if (start != null) {
            storage.setStageStartTime(_uniqueKey, start);
          }
          if (elapsed != null) {
            storage.setStageElapsedTime(_uniqueKey, elapsed);
          }
          if (lastResume != null) {
            storage.setStageLastResumeTime(_uniqueKey, lastResume);
          }
          setState(() {});
        },
        onFormDataChanged: (formData) {
          storage.setStageFormData(_uniqueKey, formData);
        },
        onPauseJustification: (justificativa) {
          storage.setStagePauseJustification(_uniqueKey, justificativa);
        },
        onSaved: (data) async {
          storage.saveData(_uniqueKey, data);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apontamento salvo com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          setState(() {});
        },
      ),
    );
  }
}
