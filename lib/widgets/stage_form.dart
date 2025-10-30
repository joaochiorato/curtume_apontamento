import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stage.dart';
import './stage_action_bar.dart';
import './qty_counter.dart';

// Modelo para os químicos
class Quimico {
  final String nome;
  final String unidade;
  
  const Quimico({required this.nome, this.unidade = 'kg'});
}

// Lista de químicos
const List<Quimico> quimicos = [
  Quimico(nome: 'Cal virgem (hidróxido de cálcio)', unidade: 'kg'),
  Quimico(nome: 'Sulfeto de sódio (Na₂S)', unidade: 'kg'),
  Quimico(nome: 'Hidrossulfeto de sódio (NaHS)', unidade: 'kg'),
  Quimico(nome: 'Desulfex, EcoLime, Biosafe', unidade: 'kg'),
  Quimico(nome: 'Tensoativo / umectante', unidade: 'L'),
  Quimico(nome: 'Agente sequestrante', unidade: 'L'),
];

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
  final Map<String, TextEditingController> _quimicosControllers = {};
  final _obs = TextEditingController();
  final _qtdProcessadaCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _qtyKey = GlobalKey();

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
    
    // Inicializa controllers das variáveis
    for (final v in widget.stage.variables) {
      _controllers[v.name] = TextEditingController();
    }
    
    // Inicializa controllers dos químicos
    for (final q in quimicos) {
      _quimicosControllers[q.nome] = TextEditingController();
    }
    
    _qtdProcessadaCtrl.text = '0';
    
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
        if (savedData['fulao'] != null) _fulaoSel = savedData['fulao'];
        if (savedData['responsavel'] != null) _respSel = savedData['responsavel'];
        if (savedData['responsavelSuperior'] != null) _respSupSel = savedData['responsavelSuperior'];
        if (savedData['obs'] != null) _obs.text = savedData['obs'];
        if (savedData['qtdProcessada'] != null) {
          _qtd = savedData['qtdProcessada'];
          _qtdProcessadaCtrl.text = '$_qtd';
        }
        
        if (savedData['status'] != null) {
          final statusStr = savedData['status'];
          if (statusStr == 'running') _status = StageStatus.running;
          else if (statusStr == 'paused') _status = StageStatus.paused;
          else if (statusStr == 'closed') _status = StageStatus.closed;
        }
        
        if (savedData['start'] != null) _start = DateTime.parse(savedData['start']);
        if (savedData['end'] != null) _end = DateTime.parse(savedData['end']);
        
        // Carrega variáveis
        if (savedData['variables'] != null) {
          final vars = savedData['variables'] as Map<String, dynamic>;
          vars.forEach((key, value) {
            if (_controllers.containsKey(key) && value != null) {
              _controllers[key]!.text = value.toString();
            }
          });
        }
        
        // Carrega químicos
        if (savedData['quimicos'] != null) {
          final quims = savedData['quimicos'] as Map<String, dynamic>;
          quims.forEach((key, value) {
            if (_quimicosControllers.containsKey(key) && value != null) {
              _quimicosControllers[key]!.text = value.toString();
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
    for (final c in _quimicosControllers.values) {
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

  bool _canStart() => true;

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

  // Conta quantos químicos foram informados
  int _getQuimicosInformados() {
    return _quimicosControllers.values
        .where((ctrl) => ctrl.text.isNotEmpty)
        .length;
  }

  // Abre o dialog de químicos
  Future<void> _openQuimicosDialog() async {
    final canEdit = _status == StageStatus.running || _status == StageStatus.idle;
    
    if (!canEdit) {
      _show('Inicie o processo para informar os químicos.', isError: true);
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF546E7A),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.science, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Químicos Utilizados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de químicos
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: quimicos.map((q) {
                          final ctrl = _quimicosControllers[q.nome]!;
                          final hasValue = ctrl.text.isNotEmpty;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nome do químico
                                Text(
                                  q.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Botão para informar quantidade
                                OutlinedButton(
                                  onPressed: () async {
                                    final result = await _openNumpad(
                                      titulo: q.nome,
                                      controller: ctrl,
                                      unidade: q.unidade,
                                    );
                                    
                                    if (result != null) {
                                      setDialogState(() {
                                        ctrl.text = result;
                                      });
                                      setState(() {}); // Atualiza contador no botão
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: hasValue
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFF424242),
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    backgroundColor: hasValue
                                        ? const Color(0xFF4CAF50).withOpacity(0.05)
                                        : const Color(0xFFF5F5F5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ctrl.text.isEmpty
                                              ? 'Informar quantidade'
                                              : '${ctrl.text} ${q.unidade}',
                                          style: TextStyle(
                                            color: hasValue
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFF424242),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit_outlined,
                                        color: hasValue
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFF616161),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Botão fechar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.check),
                        label: const Text('Concluir'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _fulaoSelector() {
    final enabled = _status == StageStatus.running || _status == StageStatus.idle;
    final quimicosCount = _getQuimicosInformados();
    
    return Row(
      children: [
        // Dropdown Fulão
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<int>(
            value: _fulaoSel,
            items: [1, 2, 3, 4]
                .map((n) => DropdownMenuItem(value: n, child: Text('Fulão $n')))
                .toList(),
            onChanged: enabled ? (v) => setState(() => _fulaoSel = v) : null,
            decoration: const InputDecoration(
              labelText: 'Fulão',
              prefixIcon: Icon(Icons.precision_manufacturing),
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Botão Químicos
        Expanded(
          flex: 1,
          child: FilledButton.icon(
            onPressed: _openQuimicosDialog,
            icon: const Icon(Icons.science, size: 20),
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Químicos',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                if (quimicosCount > 0)
                  Text(
                    '$quimicosCount/${quimicos.length}',
                    style: const TextStyle(fontSize: 10),
                  ),
              ],
            ),
            style: FilledButton.styleFrom(
              backgroundColor: quimicosCount > 0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF546E7A),
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeRow() {
    final startTxt = _start == null
        ? 'Início — aguardando'
        : 'Início: ${dfDate.format(_start!)} ${dfTime.format(_start!)}';

    final endTxt = _end == null
        ? 'Término — aguardando'
        : 'Término: ${dfDate.format(_end!)} ${dfTime.format(_end!)}';

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
          color: (color ?? const Color(0xFFE0E0E0)).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color ?? const Color(0xFF9E9E9E)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? const Color(0xFF616161)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color ?? const Color(0xFF424242),
                  fontSize: 13,
                ),
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
                    color: _start != null ? const Color(0xFF4CAF50) : null)),
            const SizedBox(width: 12),
            Expanded(
                child: chip(Icons.stop, endTxt,
                    color: _end != null ? const Color(0xFFF44336) : null)),
          ],
        ),
        if (duracao != null) ...[
          const SizedBox(height: 8),
          chip(Icons.timer_outlined, duracao, color: const Color(0xFF2196F3)),
        ],
      ],
    );
  }

  Future<String?> _openNumpad({
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
                      child: Text(k, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  if (txtPadrao.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      txtPadrao,
                      style: TextStyle(
                        fontSize: 13,
                        color: isOutOfRange
                            ? const Color(0xFFFF9800)
                            : const Color(0xFF616161),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    style: TextStyle(
                      fontSize: 24,
                      color: isOutOfRange ? Colors.amber : const Color(0xFF424242),
                    ),
                    controller: TextEditingController(text: buf),
                    decoration: InputDecoration(
                      hintText: 'Digite a quantidade',
                      suffixText: unidade,
                      errorText: isOutOfRange ? 'Valor fora do padrão!' : null,
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: const OutlineInputBorder(),
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

    return result;
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    if (_formKey.currentState?.validate() != true) {
      _show('Preencha todos os campos obrigatórios.', isError: true);
      return;
    }

    for (final v in widget.stage.variables) {
      if (_controllers[v.name]!.text.trim().isEmpty) {
        _show('Informe o resultado de "${v.name}".', isError: true);
        return;
      }
    }

    if (_respSel == '— selecione —') {
      _show('Selecione o responsável.', isError: true);
      return;
    }

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
        'quimicos': _quimicosControllers.map((k, c) => MapEntry(k, c.text)),
      };

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
    final canEdit = _status == StageStatus.running || _status == StageStatus.idle;

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
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(),
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
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(),
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
            const SizedBox(height: 10),
            
            TextFormField(
              controller: _obs,
              maxLines: 3,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Observação',
                hintText: 'Tempo de Remolho 120 minutos +/- 60 min',
                prefixIcon: Icon(Icons.notes),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF424242),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science, size: 20, color: Color(0xFF424242)),
                      const SizedBox(width: 8),
                      const Text(
                        'Variáveis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...s.variables.map((v) {
                    final ctrl = _controllers[v.name]!;
                    final min = v.min, max = v.max;
                    double? val;
                    if (ctrl.text.isNotEmpty) {
                      val = double.tryParse(ctrl.text.replaceAll(',', '.'));
                    }
                    final isOut = _isOutOfRange(val, min, max);
                    final hasValue = ctrl.text.isNotEmpty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  v.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ),
                              if (hasValue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOut
                                        ? const Color(0xFFFF9800)
                                        : const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOut ? Icons.warning_rounded : Icons.check_circle_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isOut ? 'Fora' : 'OK',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          if (v.hint != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                v.hint!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ),
                          
                          if (min != null || max != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Padrão: ${min ?? '-'} a ${max ?? '-'} ${v.unit}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ),
                          
                          OutlinedButton(
                            onPressed: (_status == StageStatus.running)
                                ? () async {
                                    final result = await _openNumpad(
                                      titulo: v.name,
                                      controller: ctrl,
                                      unidade: v.unit,
                                      min: min,
                                      max: max,
                                    );
                                    if (result != null) {
                                      setState(() => ctrl.text = result);
                                    }
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: hasValue
                                    ? (isOut 
                                        ? const Color(0xFFFF9800)
                                        : const Color(0xFF4CAF50))
                                    : const Color(0xFF424242),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              backgroundColor: hasValue && !isOut
                                  ? const Color(0xFF4CAF50).withOpacity(0.05)
                                  : (hasValue && isOut
                                      ? const Color(0xFFFF9800).withOpacity(0.05)
                                      : const Color(0xFFF5F5F5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ctrl.text.isEmpty
                                        ? 'Informar'
                                        : '${ctrl.text} ${v.unit}',
                                    style: TextStyle(
                                      color: hasValue
                                          ? (isOut 
                                              ? const Color(0xFFFF9800)
                                              : const Color(0xFF4CAF50))
                                          : const Color(0xFF424242),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.edit_outlined,
                                  color: hasValue
                                      ? (isOut 
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFF4CAF50))
                                      : const Color(0xFF616161),
                                  size: 20,
                                ),
                              ],
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
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
