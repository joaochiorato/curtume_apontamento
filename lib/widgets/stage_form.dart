import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stage.dart';
import './stage_action_bar.dart';
import './qty_counter.dart';

class StageForm extends StatefulWidget {
  final StageModel stage;
  final void Function(Map<String, dynamic>) onSaved;
  final Map<String, dynamic>? initialData;
  const StageForm({
    super.key, 
    required this.stage, 
    required this.onSaved,
    this.initialData,
  });

  @override
  State<StageForm> createState() => _StageFormState();
}

class _StageFormState extends State<StageForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final _obs = TextEditingController();
  final _qtdProcessadaCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _qtyKey = GlobalKey();

  // Listas de opções
  final List<String> _responsaveis = const [
    '— selecione —',
    'Ana',
    'Bruno',
    'Carlos',
    'Daniela'
  ];
  final List<String> _responsaveisSup = const [
    '— selecione —',
    'Supervisor A',
    'Supervisor B',
    'Supervisor C'
  ];

  // Estado do formulário
  int? _fulaoSel;
  String _respSel = '— selecione —';
  String _respSupSel = '— selecione —';
  DateTime? _start;
  DateTime? _end;
  StageStatus _status = StageStatus.idle;
  int _qtd = 0;
  bool _isSaving = false;

  final dfDate = DateFormat('dd/MM/yyyy');
  final dfTime = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    for (final v in widget.stage.variables) {
      _controllers[v.name] = TextEditingController();
    }
    _qtdProcessadaCtrl.text = '0';
    
    // Carrega dados salvos se existirem
    if (widget.initialData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSavedData();
      });
    }
  }

  void _loadSavedData() {
    final savedData = widget.initialData;
    
    if (savedData != null) {
      setState(() {
        // Carrega dados básicos
        if (savedData['fulao'] != null) {
          _fulaoSel = savedData['fulao'];
        }
        if (savedData['responsavel'] != null) {
          _respSel = savedData['responsavel'];
        }
        if (savedData['responsavelSuperior'] != null) {
          _respSupSel = savedData['responsavelSuperior'];
        }
        if (savedData['obs'] != null) {
          _obs.text = savedData['obs'];
        }
        if (savedData['qtdProcessada'] != null) {
          _qtd = savedData['qtdProcessada'];
          _qtdProcessadaCtrl.text = '$_qtd';
        }
        
        // Carrega status e datas
        if (savedData['status'] != null) {
          final statusStr = savedData['status'];
          if (statusStr == 'running') _status = StageStatus.running;
          else if (statusStr == 'paused') _status = StageStatus.paused;
          else if (statusStr == 'closed') _status = StageStatus.closed;
        }
        
        if (savedData['start'] != null) {
          _start = DateTime.parse(savedData['start']);
        }
        if (savedData['end'] != null) {
          _end = DateTime.parse(savedData['end']);
        }
        
        // Carrega variáveis
        if (savedData['variables'] != null) {
          final vars = savedData['variables'] as Map<String, dynamic>;
          vars.forEach((key, value) {
            if (_controllers.containsKey(key) && value != null) {
              _controllers[key]!.text = value.toString();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _obs.dispose();
    _qtdProcessadaCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _show(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  bool _isOutOfRange(double? v, double? min, double? max) {
    if (v == null) return false;
    if (min != null && v < min) return true;
    if (max != null && v > max) return true;
    return false;
  }

  void _scrollToQty() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _qtyKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.05,
        );
      }
    });
  }

  // Validações antes de iniciar
  bool _canStart() {
    return true;
  }

  // Validações antes de encerrar
  Future<bool> _canClose() async {
    if (_qtd == 0) {
      final confirm = await _showConfirmDialog(
        'Quantidade Zerada',
        'A quantidade processada está zerada. Deseja realmente encerrar?',
      );
      return confirm ?? false;
    }
    return true;
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _fulaoSelector() {
    final enabled =
        _status == StageStatus.running || _status == StageStatus.idle;
    return DropdownButtonFormField<int>(
      value: _fulaoSel,
      items: [1, 2, 3, 4]
          .map((n) => DropdownMenuItem(value: n, child: Text('Fulão $n')))
          .toList(),
      onChanged: enabled ? (v) => setState(() => _fulaoSel = v) : null,
      decoration: const InputDecoration(
        labelText: 'Fulão',
        prefixIcon: Icon(Icons.precision_manufacturing),
      ),
    );
  }

  Widget _timeRow() {
    final startTxt = _start == null
        ? 'Início — aguardando'
        : 'Início: ${dfDate.format(_start!)} ${dfTime.format(_start!)}';

    final endTxt = _end == null
        ? 'Término — aguardando'
        : 'Término: ${dfDate.format(_end!)} ${dfTime.format(_end!)}';

    // Calcular duração se ambos existirem
    String? duracao;
    if (_start != null && _end != null) {
      final diff = _end!.difference(_start!);
      final horas = diff.inHours;
      final mins = diff.inMinutes.remainder(60);
      duracao = 'Duração: ${horas}h ${mins}min';
    }

    Widget chip(IconData icon, String text, {Color? color}) {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color?.withOpacity(0.3) ?? Colors.white24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: chip(Icons.play_arrow, startTxt,
                    color: _start != null ? Colors.green : null)),
            const SizedBox(width: 12),
            Expanded(
                child: chip(Icons.stop, endTxt,
                    color: _end != null ? Colors.red : null)),
          ],
        ),
        if (duracao != null) ...[
          const SizedBox(height: 8),
          chip(Icons.timer_outlined, duracao, color: Colors.blue),
        ],
      ],
    );
  }

  Future<void> _openNumpad({
    required String titulo,
    required TextEditingController controller,
    String? unidade,
    double? min,
    double? max,
  }) async {
    String buf = controller.text.replaceAll('.', ',');
    String normalize(String s) => s.replaceAll(',', '.');

    String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void push(String ch) {
              if (ch == ',' || ch == '.') {
                if (buf.contains(',') || buf.contains('.')) return;
                buf = buf.isEmpty ? '0,' : (buf + ',');
              } else {
                buf += ch;
              }
              setModalState(() {});
            }

            void back() {
              if (buf.isNotEmpty) buf = buf.substring(0, buf.length - 1);
              setModalState(() {});
            }

            void clear() {
              buf = '';
              setModalState(() {});
            }

            final txtPadrao = (min != null || max != null)
                ? 'Padrão: ${min ?? '-'} a ${max ?? '-'} ${unidade ?? ''}'
                : (unidade != null ? 'Unid.: $unidade' : '');

            // Validar valor em tempo real
            double? currentVal;
            bool isOutOfRange = false;
            if (buf.isNotEmpty) {
              currentVal = double.tryParse(normalize(buf));
              if (currentVal != null) {
                isOutOfRange = _isOutOfRange(currentVal, min, max);
              }
            }

            Widget key(String k, {VoidCallback? onTap}) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: FilledButton.tonal(
                      onPressed: onTap ?? () => push(k),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(k,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18)),
                  if (txtPadrao.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(txtPadrao,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isOutOfRange ? Colors.amber : Colors.white,
                    ),
                    controller: TextEditingController(text: buf),
                    decoration: InputDecoration(
                      hintText: 'Digite o resultado',
                      suffixText: unidade,
                      errorText: isOutOfRange ? 'Valor fora do padrão!' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [key('1'), key('2'), key('3')]),
                  Row(children: [key('4'), key('5'), key('6')]),
                  Row(children: [key('7'), key('8'), key('9')]),
                  Row(children: [
                    key(','),
                    key('0'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: FilledButton.tonalIcon(
                          onPressed: back,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                          ),
                          icon: const Icon(Icons.backspace_outlined),
                          label: const Text('Apagar'),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: clear,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Limpar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (buf.isEmpty) return Navigator.pop(ctx, '');
                            final val = double.tryParse(normalize(buf));
                            if (val == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Valor inválido')),
                              );
                              return;
                            }
                            Navigator.pop(ctx, buf);
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Confirmar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => controller.text = result);
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    // Validar formulário
    if (_formKey.currentState?.validate() != true) {
      _show('Preencha todos os campos obrigatórios.', isError: true);
      return;
    }

    // Validar variáveis
    for (final v in widget.stage.variables) {
      if (_controllers[v.name]!.text.trim().isEmpty) {
        _show('Informe o resultado de "${v.name}".', isError: true);
        return;
      }
    }

    // Validar responsáveis
    if (_respSel == '— selecione —') {
      _show('Selecione o responsável.', isError: true);
      return;
    }

    // Avisar sobre valores fora do padrão
    final outOfRange = <String>[];
    for (final v in widget.stage.variables) {
      final text = _controllers[v.name]!.text;
      final val = double.tryParse(text.replaceAll(',', '.'));
      if (val != null && _isOutOfRange(val, v.min, v.max)) {
        outOfRange.add(v.name);
      }
    }

    if (outOfRange.isNotEmpty) {
      final confirm = await _showConfirmDialog(
        'Valores Fora do Padrão',
        'As seguintes variáveis estão fora do padrão:\n${outOfRange.join(', ')}\n\nDeseja salvar mesmo assim?',
      );
      if (confirm != true) return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'status': _status.name,
        'fulao': _fulaoSel,
        'start': _start?.toIso8601String(),
        'end': _end?.toIso8601String(),
        'responsavel': _respSel,
        'responsavelSuperior': _respSupSel,
        'obs': _obs.text,
        'qtdProcessada': _qtd,
        'variables': _controllers.map((k, c) => MapEntry(k, c.text)),
      };

      // Simular delay de salvamento
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onSaved(data);
    } catch (e) {
      _show('Erro ao salvar: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stage;
    final canEdit =
        _status == StageStatus.running || _status == StageStatus.idle;

    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StageActionBar(
              status: _status,
              onStart: () {
                if (!_canStart()) return;
                setState(() {
                  _status = StageStatus.running;
                  _start = DateTime.now();
                  _end = null;
                });
                _show('Processo iniciado!');
                _scrollToQty();
              },
              onPause: () {
                setState(() => _status = StageStatus.paused);
                _show('Processo pausado.');
              },
              onClose: () async {
                if (!await _canClose()) return;
                setState(() {
                  _status = StageStatus.closed;
                  _end = DateTime.now();
                });
                _show('Processo encerrado!');
              },
              onReopen: () {
                setState(() {
                  _status = StageStatus.running;
                  _end = null;
                });
                _show('Processo reaberto.');
              },
            ),
            const SizedBox(height: 12),
            _timeRow(),
            const SizedBox(height: 12),
            _fulaoSelector(),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _respSel,
              items: _responsaveis
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: canEdit
                  ? (v) => setState(() => _respSel = v ?? '— selecione —')
                  : null,
              decoration: const InputDecoration(
                labelText: 'Responsável',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) =>
                  v == '— selecione —' ? 'Selecione o responsável' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _respSupSel,
              items: _responsaveisSup
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: canEdit
                  ? (v) => setState(() => _respSupSel = v ?? '— selecione —')
                  : null,
              decoration: const InputDecoration(
                labelText: 'Responsável Superior',
                prefixIcon: Icon(Icons.supervisor_account),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _obs,
              maxLines: 3,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Observação',
                hintText: 'Tempo de Remolho 120 minutos +/- 60 min',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              key: _qtyKey,
              child: QtyCounter(
                value: _qtd,
                enabled: canEdit,
                onChanged: (n) {
                  setState(() {
                    _qtd = n;
                    _qtdProcessadaCtrl.text = '$n';
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science, size: 20),
                      const SizedBox(width: 8),
                      Text('Variáveis',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...s.variables.map((v) {
                    final ctrl = _controllers[v.name]!;
                    final min = v.min, max = v.max;
                    double? val;
                    if (ctrl.text.isNotEmpty) {
                      val = double.tryParse(ctrl.text.replaceAll(',', '.'));
                    }
                    final isOut = _isOutOfRange(val, min, max);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                if (v.hint != null)
                                  Text(v.hint!,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white70)),
                                if (min != null || max != null)
                                  Text(
                                      'Padrão: ${min ?? '-'} a ${max ?? '-'} ${v.unit}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 150,
                            child: OutlinedButton(
                              onPressed: (_status == StageStatus.running)
                                  ? () => _openNumpad(
                                        titulo: v.name,
                                        controller: ctrl,
                                        unidade: v.unit,
                                        min: min,
                                        max: max,
                                      )
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color:
                                        isOut ? Colors.amber : Colors.white24,
                                    width: isOut ? 2 : 1),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 12),
                              ),
                              child: Text(
                                (ctrl.text.isEmpty)
                                    ? 'Informar'
                                    : '${ctrl.text} ${v.unit}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isOut ? Colors.amber : Colors.white,
                                  fontWeight: isOut
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
