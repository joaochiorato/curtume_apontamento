import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/stage.dart';
import '../models/formulacoes_model.dart';
import '../widgets/stage_action_bar.dart';
import '../widgets/formulacoes_dialog.dart';
import '../widgets/quantidade_counter.dart'; // ✅ NOVO IMPORT

class StageForm extends StatefulWidget {
  final StageModel stage;
  final void Function(Map<String, dynamic>) onSaved;
  final Map<String, dynamic>? initialData;
  final int quantidadeTotal;
  final int quantidadeProcessada;
  final int quantidadeRestante;

  const StageForm({
    super.key,
    required this.stage,
    required this.onSaved,
    this.initialData,
    required this.quantidadeTotal,
    required this.quantidadeProcessada,
    required this.quantidadeRestante,
  });

  @override
  State<StageForm> createState() => _StageFormState();
}

class _StageFormState extends State<StageForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  QuimicosFormulacaoData? _quimicosData;
  final _obs = TextEditingController();
  final _qtdProcessadaCtrl = TextEditingController();
  final _scroll = ScrollController();

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

  // Verifica se o estágio é REMOLHO (único que tem Fulão e Químicos)
  bool get _isRemolho => widget.stage.code.toUpperCase() == 'REMOLHO';
  
  // Verifica se tem máquinas/fulões disponíveis
  bool get _hasMachines => widget.stage.machines != null && widget.stage.machines!.isNotEmpty;

  int _getQuimicosInformados() {
    return _quimicosData?.getQuantidadeInformados() ?? 0;
  }

  Future<void> _openQuimicosDialog() async {
    final canEdit =
        (_status == StageStatus.idle || _status == StageStatus.running);

    final result = await showQuimicosDialog(
      context,
      dadosAtuais: _quimicosData,
      canEdit: canEdit,
    );

    if (result != null) {
      setState(() {
        _quimicosData = result;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final qtdApontamento = int.tryParse(_qtdProcessadaCtrl.text) ?? 0;
    if (qtdApontamento <= 0) {
      _show('Informe uma quantidade válida!', isError: true);
      return;
    }

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

    final variables = <String, dynamic>{};
    _controllers.forEach((key, ctrl) {
      variables[key] = ctrl.text;
    });

    final data = <String, dynamic>{
      'fulao': _fulaoSel,
      'responsavel': _respSel,
      'responsavelSuperior': _respSupSel,
      'qtdProcessada': qtdApontamento,
      'observacao': _obs.text,
      'start': _start?.toIso8601String(),
      'end': _end?.toIso8601String(),
      'status': _status.name,
      'variables': variables,
      if (_quimicosData != null) 'quimicos': _quimicosData!.toJson(),
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

  void _onStatusChange(StageStatus newStatus) {
    setState(() {
      if (newStatus == StageStatus.running && _start == null) {
        _start = DateTime.now();
      } else if (newStatus == StageStatus.closed && _end == null) {
        _end = DateTime.now();
      }
      _status = newStatus;
    });

    // ✅ Ao clicar em ENCERRAR, salva automaticamente
    if (newStatus == StageStatus.closed) {
      _save();
    }
  }

  String _calcularDuracao(DateTime inicio, DateTime fim) {
    final duracao = fim.difference(inicio);
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);

    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else {
      return '${minutos}min';
    }
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
                    // Card com informações de quantidade
                    Card(
                      color: Colors.blue.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total da Ordem:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${widget.quantidadeTotal} peles',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Já processado:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${widget.quantidadeProcessada} peles',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'RESTANTE:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                Text(
                                  '${widget.quantidadeRestante} peles',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Barra de ações: Iniciar/Pausar/Encerrar/Reabrir
                    StageActionBar(
                      status: _status,
                      onStatusChange: _onStatusChange,
                      start: _start,
                      end: _end,
                    ),

                    const SizedBox(height: 16),

                    // Exibição de Hora Início e Hora Término
                    if (_start != null || _end != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (_start != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Início',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dfTime.format(_start!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            if (_start != null && _end != null)
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.grey.shade400,
                              ),
                            if (_end != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Término',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dfTime.format(_end!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            if (_start != null && _end != null) ...[
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.grey.shade400,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Duração',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _calcularDuracao(_start!, _end!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Dropdown Fulão e Botão Químicos (apenas para REMOLHO)
                    if (_isRemolho && _hasMachines)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _fulaoSel,
                              decoration: const InputDecoration(
                                labelText: 'Fulão',
                                border: OutlineInputBorder(),
                              ),
                              items: widget.stage.machines!
                                  .map((m) => int.parse(m))
                                  .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text('Fulão $m'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _fulaoSel = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openQuimicosDialog,
                              icon: const Icon(Icons.science),
                              label: Text('Químicos (${_getQuimicosInformados()})'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Responsável
                    DropdownButtonFormField<String>(
                      value: _respSel,
                      decoration: const InputDecoration(
                        labelText: 'Responsável',
                        border: OutlineInputBorder(),
                      ),
                      items: _responsaveis
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => _respSel = v!),
                    ),

                    const SizedBox(height: 16),

                    // Responsável Superior
                    DropdownButtonFormField<String>(
                      value: _respSupSel,
                      decoration: const InputDecoration(
                        labelText: 'Responsável Superior',
                        border: OutlineInputBorder(),
                      ),
                      items: _responsaveisSup
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => _respSupSel = v!),
                    ),

                    const SizedBox(height: 20),

                    // ✅ NOVO: Contador de Quantidade com botões
                    QuantidadeCounter(
                      controller: _qtdProcessadaCtrl,
                      label: 'Quantidade Processada*',
                      helperText: 'Máximo: ${widget.quantidadeRestante} peles',
                      onChanged: (value) {
                        setState(() {}); // Atualiza a UI
                      },
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    const Text(
                      'Variáveis do Processo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...widget.stage.variables.map((v) {
                      final ctrl = _controllers[v.name]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: ctrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: '${v.name} (${v.unit})',
                            hintText: v.hint,
                            helperText: v.min != null && v.max != null
                                ? 'Faixa: ${v.min} - ${v.max}'
                                : null,
                          ),
                          validator: (txt) {
                            if (txt == null || txt.isEmpty) {
                              return 'Informe ${v.name}';
                            }
                            final num =
                                double.tryParse(txt.replaceAll(',', '.'));
                            if (num == null) return 'Valor inválido';
                            if (v.min != null && num < v.min!) {
                              return 'Mínimo: ${v.min}';
                            }
                            if (v.max != null && num > v.max!) {
                              return 'Máximo: ${v.max}';
                            }
                            return null;
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _obs,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                        hintText: 'Adicione observações sobre o processo...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
