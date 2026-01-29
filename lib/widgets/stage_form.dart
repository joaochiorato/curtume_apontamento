import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/stage.dart';
import '../widgets/variaveis_dialog.dart';
import '../pages/stage_memory_storage.dart';

class StageForm extends StatefulWidget {
  final StageModel stage;
  final void Function(Map<String, dynamic>) onSaved;
  final void Function(StageProgressStatus status, DateTime? startTime,
      Duration? elapsed, DateTime? lastResumeTime)? onStatusChanged;
  final void Function(StageFormData data)? onFormDataChanged;
  final void Function(String justificativa)? onPauseJustification;
  final Map<String, dynamic>? initialData;
  final Map<String, String>? articleHeader;
  final int quantidadeTotal;
  final int quantidadeProcessada;
  final int quantidadeRestante;
  final bool isEditing;
  final StageProgressStatus currentStatus;
  final DateTime? startTime;
  final Duration? elapsedTime;
  final DateTime? lastResumeTime; // ✅ Adicionado
  final StageFormData? savedFormData;
  final bool autoStart; // ✅ Novo: indica se deve auto-iniciar

  const StageForm({
    super.key,
    required this.stage,
    required this.onSaved,
    this.onStatusChanged,
    this.onFormDataChanged,
    this.onPauseJustification,
    this.initialData,
    this.articleHeader,
    required this.quantidadeTotal,
    required this.quantidadeProcessada,
    required this.quantidadeRestante,
    this.isEditing = false,
    this.currentStatus = StageProgressStatus.Aguardando,
    this.startTime,
    this.elapsedTime,
    this.lastResumeTime, // ✅ Adicionado
    this.savedFormData,
    this.autoStart = false, // ✅ Novo: padrão false para não quebrar código existente
  });

  @override
  State<StageForm> createState() => _StageFormState();
}

class _StageFormState extends State<StageForm> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String> _variaveisData = {};
  final _obs = TextEditingController();
  final _qtdProcessadaCtrl = TextEditingController();
  final _scroll = ScrollController();

  final List<String> _responsaveisSup = const [
    '— selecione —',
    'Supervisor A',
    'Supervisor B',
    'Supervisor C'
  ];

  String _respSupSel = '— selecione —';
  DateTime? _start;
  DateTime? _end;
  StageStatus _status = StageStatus.idle;
  bool _isSaving = false;

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _elapsedBeforePause = Duration.zero;
  DateTime? _lastResumeTime;

  bool _isViewingClosed = false;

  // Histórico de pausas
  final List<Map<String, dynamic>> _pauseHistory = [];

  final dfDate = DateFormat('dd/MM/yyyy');
  final dfTime = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _qtdProcessadaCtrl.text = '0';

    if (widget.isEditing && widget.initialData != null) {
      _loadInitialData();
      _isViewingClosed = true;
      _status = StageStatus.closed;
    } else if (widget.currentStatus == StageProgressStatus.emProducao ||
        widget.currentStatus == StageProgressStatus.parado) {
      // ✅ Restaurar estado de estágio em andamento
      _start = widget.startTime;
      _elapsedBeforePause = widget.elapsedTime ?? Duration.zero;

      // ✅ Carregar dados parciais salvos
      if (widget.savedFormData != null) {
        _loadSavedFormData();
      }

      if (widget.currentStatus == StageProgressStatus.emProducao) {
        _status = StageStatus.running;

        // ✅ CORREÇÃO: Usar lastResumeTime salvo para manter o tempo correndo
        if (widget.lastResumeTime != null) {
          // Tem lastResumeTime salvo - tempo continuou correndo fora da tela
          _lastResumeTime = widget.lastResumeTime;
          // O timer vai calcular: _elapsedBeforePause + (now - _lastResumeTime)
          // Isso inclui o tempo que passou enquanto estava fora da tela
        } else {
          // Não tem lastResumeTime, começar do _elapsedBeforePause
          _lastResumeTime = DateTime.now();
        }

        _startTimer();
      } else {
        // ✅ Parado - restaurar tempo sem iniciar timer
        _status = StageStatus.paused;
        _elapsed = _elapsedBeforePause;
      }
    } else if (widget.savedFormData != null) {
      _loadSavedFormData();
    }

    // ✅ Auto-iniciar: abrir diálogo de variáveis e iniciar apontamento
    if (widget.autoStart && _status == StageStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoStartWorkflow();
      });
    }
  }

  void _loadSavedFormData() {
    final data = widget.savedFormData!;
    if (data.responsavelSuperior != null)
      _respSupSel = data.responsavelSuperior!;
    if (data.quantidade != null)
      _qtdProcessadaCtrl.text = data.quantidade.toString();
    if (data.observacao != null) _obs.text = data.observacao!;
    if (data.variaveis != null) _variaveisData = Map.from(data.variaveis!);
  }

  void _saveFormData() {
    widget.onFormDataChanged?.call(StageFormData(
      responsavelSuperior: _respSupSel,
      quantidade: int.tryParse(_qtdProcessadaCtrl.text),
      observacao: _obs.text,
      variaveis: _variaveisData.isNotEmpty ? Map.from(_variaveisData) : null,
    ));
  }

  void _loadInitialData() {
    final data = widget.initialData!;

    _respSupSel = data['responsavelSuperior'] as String? ?? '— selecione —';
    _qtdProcessadaCtrl.text = (data['qtdProcessada'] ?? 0).toString();
    _obs.text = data['observacao'] as String? ?? '';

    if (data['start'] != null) {
      _start = DateTime.parse(data['start']);
    }
    if (data['end'] != null) {
      _end = DateTime.parse(data['end']);
    }
    if (_start != null && _end != null) {
      _elapsed = _end!.difference(_start!);
      _elapsedBeforePause = _elapsed;
    }

    final variables = data['variables'] as Map<String, dynamic>?;
    if (variables != null) {
      _variaveisData =
          variables.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // ✅ Salvar tempo atual antes de sair se estiver rodando
    if (_status == StageStatus.running && _start != null) {
      // Salvar de forma síncrona no storage (não usa setState)
      widget.onStatusChanged?.call(StageProgressStatus.emProducao, _start,
          _elapsedBeforePause, _lastResumeTime);
    } else if (_status == StageStatus.paused && _start != null) {
      widget.onStatusChanged
          ?.call(StageProgressStatus.parado, _start, _elapsed, null);
    }
    _obs.dispose();
    _qtdProcessadaCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _hasVariables => widget.stage.variables.isNotEmpty;
  bool get _isFieldsLocked => _isViewingClosed;

  int _getVariaveisPreenchidas() {
    return _variaveisData.values.where((v) => v.isNotEmpty).length;
  }

  void _startTimer() {
    _timer?.cancel();
    // ✅ Se não tem lastResumeTime, definir agora
    _lastResumeTime ??= DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status == StageStatus.running && _lastResumeTime != null) {
        setState(() {
          _elapsed =
              _elapsedBeforePause + DateTime.now().difference(_lastResumeTime!);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _elapsedBeforePause = _elapsed;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _openVariaveisDialog() async {
    if (_isFieldsLocked) {
      _showLockedMessage();
      return;
    }

    final canEdit = (_status == StageStatus.idle ||
        _status == StageStatus.running ||
        _status == StageStatus.paused);

    final result = await showVariaveisDialog(
      context,
      variables: widget.stage.variables,
      valoresAtuais: _variaveisData,
      canEdit: canEdit,
    );

    if (result != null) {
      setState(() {
        _variaveisData = result;
      });
      _saveFormData();
    }
  }

  /// ✅ Novo: workflow de auto-inicialização
  Future<void> _autoStartWorkflow() async {
    // Se o estágio tem variáveis, abrir o diálogo primeiro
    if (_hasVariables) {
      final result = await showVariaveisDialog(
        context,
        variables: widget.stage.variables,
        valoresAtuais: _variaveisData,
        canEdit: true,
      );

      // Se o usuário preencheu as variáveis, salvar e iniciar
      if (result != null) {
        setState(() {
          _variaveisData = result;
        });
        _saveFormData();

        // Iniciar o apontamento automaticamente
        _onStatusChange(StageStatus.running);
      }
    } else {
      // Se não tem variáveis, apenas iniciar direto
      _onStatusChange(StageStatus.running);
    }
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clique em REABRIR para editar este apontamento.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  int get _currentValue => int.tryParse(_qtdProcessadaCtrl.text) ?? 0;

  void _updateValue(int newValue) {
    if (_isFieldsLocked) {
      _showLockedMessage();
      return;
    }
    if (newValue < 0) newValue = 0;
    setState(() {
      _qtdProcessadaCtrl.text = newValue.toString();
    });
    _saveFormData();
  }

  void _increment(int amount) {
    _updateValue(_currentValue + amount);
  }

  void _decrement() {
    _updateValue(_currentValue - 1);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final qtdApontamento = int.tryParse(_qtdProcessadaCtrl.text) ?? 0;

    if (qtdApontamento > widget.quantidadeRestante) {
      _show(
        'Quantidade excede o saldo! Restam apenas ${widget.quantidadeRestante} peles.',
        isError: true,
      );
      return;
    }

    if (_status != StageStatus.closed) {
      _show('Você deve Iniciar e Encerrar o estágio antes de salvar!',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final data = <String, dynamic>{
      'responsavelSuperior': _respSupSel,
      'qtdProcessada': qtdApontamento,
      'observacao': _obs.text,
      'start': _start?.toIso8601String(),
      'end': _end?.toIso8601String(),
      'status': _status.name,
      'variables': _variaveisData,
      'pauseHistory': _pauseHistory,
      'totalElapsedSeconds': _elapsed.inSeconds,
    };

    widget.onSaved(data);
    setState(() => _isSaving = false);
  }

  void _show(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _mostrarDialogoPausarComJustificativa() {
    String? justificativaSelecionada;
    final outrosController = TextEditingController();
    final observacaoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Motivo da Pausa'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione o motivo da pausa:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text('Parada técnica'),
                    value: 'Parada técnica',
                    groupValue: justificativaSelecionada,
                    onChanged: (value) {
                      setStateDialog(() {
                        justificativaSelecionada = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Almoço'),
                    value: 'Almoço',
                    groupValue: justificativaSelecionada,
                    onChanged: (value) {
                      setStateDialog(() {
                        justificativaSelecionada = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Outros'),
                    value: 'Outros',
                    groupValue: justificativaSelecionada,
                    onChanged: (value) {
                      setStateDialog(() {
                        justificativaSelecionada = value;
                      });
                    },
                  ),
                  if (justificativaSelecionada == 'Outros')
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
                      child: TextField(
                        controller: outrosController,
                        decoration: const InputDecoration(
                          labelText: 'Especifique o motivo',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: observacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Observação (opcional)',
                      hintText: 'Adicione informações adicionais sobre a pausa',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (justificativaSelecionada == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecione um motivo para pausar'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (justificativaSelecionada == 'Outros' &&
                      outrosController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Especifique o motivo da pausa'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  String justificativaFinal = justificativaSelecionada == 'Outros'
                      ? 'Outros: ${outrosController.text.trim()}'
                      : justificativaSelecionada!;

                  // Adicionar observação se foi preenchida
                  if (observacaoController.text.trim().isNotEmpty) {
                    justificativaFinal += ' | Obs: ${observacaoController.text.trim()}';
                  }

                  Navigator.pop(context);

                  // Aqui pausamos com a justificativa
                  _onStatusChange(StageStatus.paused, justificativa: justificativaFinal);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Pausar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onStatusChange(StageStatus newStatus, {String? justificativa}) {
    setState(() {
      if (newStatus == StageStatus.running) {
        if (_start == null) {
          _start = DateTime.now();
          _elapsedBeforePause = Duration.zero;
          _elapsed = Duration.zero;
          _lastResumeTime = DateTime.now();
        } else if (_status == StageStatus.paused) {
          // Retomando de pausa - atualizar lastResumeTime e registrar retomada
          _lastResumeTime = DateTime.now();

          // Atualizar o último registro de pausa com o horário de retomada
          if (_pauseHistory.isNotEmpty) {
            _pauseHistory.last['resumeTime'] = DateTime.now().toIso8601String();
            final pauseTime = DateTime.parse(_pauseHistory.last['pauseTime'] as String);
            final resumeTime = DateTime.now();
            _pauseHistory.last['pauseDuration'] = resumeTime.difference(pauseTime).inSeconds;
          }
        }
        _startTimer();
        _isViewingClosed = false;
        widget.onStatusChanged?.call(StageProgressStatus.emProducao, _start,
            _elapsedBeforePause, _lastResumeTime);
      } else if (newStatus == StageStatus.paused) {
        _stopTimer();

        // Registrar pausa no histórico
        _pauseHistory.add({
          'pauseTime': DateTime.now().toIso8601String(),
          'justificativa': justificativa ?? 'Não informada',
          'elapsedAtPause': _elapsed.inSeconds,
        });

        widget.onStatusChanged
            ?.call(StageProgressStatus.parado, _start, _elapsed, null);
        if (justificativa != null) {
          widget.onPauseJustification?.call(justificativa);
        }
        _saveFormData();
      } else if (newStatus == StageStatus.closed) {
        _end = DateTime.now();
        _stopTimer();
        widget.onStatusChanged
            ?.call(StageProgressStatus.finalizado, _start, _elapsed, null);
      } else if (newStatus == StageStatus.idle && _isViewingClosed) {
        // ✅ REABRIR: Não mudar o status aqui, apenas resetar flags
        _end = null;
        _isViewingClosed = false;
        // Não mudar para running aqui - será feito pelo _autoStartWorkflow
      }

      _status = newStatus;
    });

    // ✅ Se está reabrindo um estágio encerrado, executar workflow de auto-start
    if (newStatus == StageStatus.idle && !_isViewingClosed && _start != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoStartWorkflow();
      });
    }

    if (newStatus == StageStatus.closed && !widget.isEditing) {
      _save();
    } else if (newStatus == StageStatus.closed &&
        widget.isEditing &&
        !_isViewingClosed) {
      _save();
    }
  }

  void _onResponsavelSupChanged(String? value) {
    if (value == null || _isFieldsLocked) return;
    setState(() => _respSupSel = value);
    _saveFormData();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActionBar(),

                    const SizedBox(height: 16),

                    if (widget.articleHeader != null) ...[
                      _buildArticleInfoCard(),
                      const SizedBox(height: 16),
                    ],

                    if (_isViewingClosed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock,
                                color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Apontamento Aguardando. Clique em REABRIR para editar.',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_start != null)
                      Card(
                        color: _status == StageStatus.running
                            ? Colors.green.shade50
                            : _status == StageStatus.paused
                                ? Colors.orange.shade50
                                : Colors.grey.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _status == StageStatus.running
                                ? Colors.green.shade300
                                : _status == StageStatus.paused
                                    ? Colors.orange.shade300
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Início:',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      '${dfDate.format(_start!)} ${dfTime.format(_start!)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (_end != null) ...[
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Término:',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        '${dfDate.format(_end!)} ${dfTime.format(_end!)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _status == StageStatus.running
                                      ? Colors.green.shade100
                                      : _status == StageStatus.paused
                                          ? Colors.orange.shade100
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _status == StageStatus.running
                                        ? Colors.green.shade400
                                        : _status == StageStatus.paused
                                            ? Colors.orange.shade400
                                            : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _status == StageStatus.running
                                          ? Icons.timer
                                          : _status == StageStatus.paused
                                              ? Icons.pause
                                              : Icons.check_circle,
                                      size: 24,
                                      color: _status == StageStatus.running
                                          ? Colors.green.shade700
                                          : _status == StageStatus.paused
                                              ? Colors.orange.shade700
                                              : Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDuration(_elapsed),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        fontFamily: 'monospace',
                                        color: _status == StageStatus.running
                                            ? Colors.green.shade700
                                            : _status == StageStatus.paused
                                                ? Colors.orange.shade700
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_start != null) const SizedBox(height: 16),

                    // BOTÃO VARIÁVEIS - Todos os estágios
                    if (_hasVariables) ...[
                      OutlinedButton.icon(
                        onPressed: _openVariaveisDialog,
                        icon: const Icon(Icons.tune, size: 18),
                        label: Text(
                            'Variáveis (${_getVariaveisPreenchidas()}/${widget.stage.variables.length})'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: BorderSide(
                            color: _isFieldsLocked
                                ? Colors.grey
                                : Colors.green.shade700,
                            width: 2,
                          ),
                          foregroundColor: _isFieldsLocked
                              ? Colors.grey
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Responsável
                    DropdownButtonFormField<String>(
                      value: _respSupSel,
                      decoration: InputDecoration(
                        labelText: 'Responsável',
                        border: const OutlineInputBorder(),
                        enabled: !_isFieldsLocked,
                      ),
                      items: _responsaveisSup
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged:
                          _isFieldsLocked ? null : _onResponsavelSupChanged,
                    ),

                    const SizedBox(height: 20),

                    // Quantidade Processada
                    const Text(
                      'Quantidade Processada*',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isFieldsLocked
                            ? Colors.grey.shade100
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isFieldsLocked
                              ? Colors.grey.shade300
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                color: _isFieldsLocked
                                    ? Colors.grey
                                    : Colors.red.shade400,
                                borderRadius: BorderRadius.circular(25),
                                child: InkWell(
                                  onTap: _isFieldsLocked ? null : _decrement,
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.remove,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                constraints: const BoxConstraints(minWidth: 80),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _isFieldsLocked
                                        ? Colors.grey
                                        : Colors.orange.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _currentValue.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _isFieldsLocked
                                        ? Colors.grey
                                        : Colors.orange.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Material(
                                color: _isFieldsLocked
                                    ? Colors.grey
                                    : Colors.green.shade400,
                                borderRadius: BorderRadius.circular(25),
                                child: InkWell(
                                  onTap: _isFieldsLocked
                                      ? null
                                      : () => _increment(1),
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('peles',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildQuickButton(
                                  '+10',
                                  _isFieldsLocked
                                      ? null
                                      : () => _increment(10)),
                              const SizedBox(width: 12),
                              _buildQuickButton(
                                  '+20',
                                  _isFieldsLocked
                                      ? null
                                      : () => _increment(20)),
                              const SizedBox(width: 12),
                              _buildQuickButton(
                                  '+50',
                                  _isFieldsLocked
                                      ? null
                                      : () => _increment(50)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Máximo: ${widget.quantidadeRestante} peles',
                            style: TextStyle(
                              color: _isFieldsLocked
                                  ? Colors.grey
                                  : Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Observação
                    TextFormField(
                      controller: _obs,
                      enabled: !_isFieldsLocked,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      onChanged:
                          _isFieldsLocked ? null : (_) => _saveFormData(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleInfoCard() {
    final header = widget.articleHeader!;
    final cor = header['cor'] ?? '';
    final classe = header['classe'] ?? '';
    final crustItem = header['crustItem'] ?? '';
    final espFinal = header['espFinal'] ?? '';
    final loteWetBlue = header['loteWetBlue'] ?? '';
    final numeroPecasNF = header['numeroPecasNF'] ?? '';
    final metragemNF = header['metragemNF'] ?? '';
    final avg = header['avg'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMAÇÕES DO ARTIGO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildInfoRow('Cor', cor),
            const SizedBox(height: 8),
            _buildInfoRow('Classe', classe),
            const SizedBox(height: 8),
            _buildInfoRow('Crust Item', crustItem),
            const SizedBox(height: 8),
            _buildInfoRow('Esp Final', espFinal),
            const SizedBox(height: 8),
            _buildInfoRow('Lote WET BLUE', loteWetBlue),
            const SizedBox(height: 8),
            _buildInfoRow('Nº Pçs NF', numeroPecasNF),
            const SizedBox(height: 8),
            _buildInfoRow('Metragem NF', metragemNF),
            const SizedBox(height: 8),
            _buildInfoRow('AVG', avg),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF616161),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: (_status == StageStatus.idle ||
                        _status == StageStatus.paused) &&
                    !_isViewingClosed
                ? () => _onStatusChange(StageStatus.running)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_status == StageStatus.idle ||
                          _status == StageStatus.paused) &&
                      !_isViewingClosed
                  ? Colors.green
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(_status == StageStatus.paused ? 'Retomar' : 'Iniciar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: _status == StageStatus.running
                ? _mostrarDialogoPausarComJustificativa
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _status == StageStatus.running
                  ? Colors.orange
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Pausar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: (_status == StageStatus.running ||
                    _status == StageStatus.paused)
                ? () => _onStatusChange(StageStatus.closed)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_status == StageStatus.running ||
                      _status == StageStatus.paused)
                  ? Colors.red
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Encerrar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: _isViewingClosed
                ? () => _onStatusChange(StageStatus.idle)
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: _isViewingClosed ? Colors.blue : Colors.grey,
              side: BorderSide(
                color: _isViewingClosed ? Colors.blue : Colors.grey.shade300,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Reabrir'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, VoidCallback? onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              onPressed != null ? Colors.blue.shade500 : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
