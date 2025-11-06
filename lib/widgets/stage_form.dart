import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stage.dart';
import '../models/formulacoes_model.dart';
import './stage_action_bar.dart';
import './formulacoes_dialog.dart';

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
  QuimicosFormulacaoData? _quimicosData;
  final _obs = TextEditingController();
  final _qtdProcessadaCtrl = TextEditingController();
  final _scroll = ScrollController();
  // REMOVIDO: final _qtyKey = GlobalKey(); // ← Não estava sendo usado

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
        if (savedData['responsavel'] != null) {
          _respSel = savedData['responsavel'];
        }
        if (savedData['responsavelSuperior'] != null) {
          _respSupSel = savedData['responsavelSuperior'];
        }
        if (savedData['observacao'] != null) {
          _obs.text = savedData['observacao'];
        }
        if (savedData['qtdProcessada'] != null) {
          _qtdProcessadaCtrl.text = savedData['qtdProcessada'].toString();
        }
        if (savedData['start'] != null) {
          _start = DateTime.parse(savedData['start']);
        }
        if (savedData['end'] != null) {
          _end = DateTime.parse(savedData['end']);
        }
        if (savedData['status'] != null) {
          _status = StageStatus.values.firstWhere(
            (s) => s.name == savedData['status'],
            orElse: () => StageStatus.idle,
          );
        }
        if (savedData['variables'] != null) {
          final vars = savedData['variables'] as Map<String, dynamic>;
          vars.forEach((key, value) {
            if (_controllers.containsKey(key)) {
              _controllers[key]!.text = value.toString();
            }
          });
        }
        if (savedData['quimicos'] != null) {
          _quimicosData = QuimicosFormulacaoData.fromJson(
            savedData['quimicos'] as Map<String, dynamic>,
          );
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

  int _getQuimicosInformados() {
    return _quimicosData?.getQuantidadeInformados() ?? 0;
  }

  Future<void> _openQuimicosDialog() async {
    final canEdit =
        _status == StageStatus.running || _status == StageStatus.idle;

    final resultado = await showQuimicosDialog(
      context,
      dadosAtuais: _quimicosData,
      canEdit: canEdit,
    );

    if (resultado != null) {
      setState(() {
        _quimicosData = resultado;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_respSel == '— selecione —') {
      _show('Selecione o responsável', isError: true);
      return;
    }
    if (widget.stage.needsResponsibleSuperior &&
        _respSupSel == '— selecione —') {
      _show('Selecione o responsável superior', isError: true);
      return;
    }
    if (_start == null || _end == null) {
      _show('Inicie e encerre o apontamento', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final variablesMap = <String, String>{};
    for (final v in widget.stage.variables) {
      variablesMap[v.name] = _controllers[v.name]!.text;
    }

    final data = {
      'stage': widget.stage.code,
      'start': _start?.toIso8601String(),
      'end': _end?.toIso8601String(),
      'status': _status.name,
      'variables': variablesMap,
      'quimicos': _quimicosData?.toJson(),
      'responsavel': _respSel,
      if (widget.stage.needsResponsibleSuperior)
        'responsavelSuperior': _respSupSel,
      'observacao': _obs.text,
      'fulao': _fulaoSel,
      'qtdProcessada': int.tryParse(_qtdProcessadaCtrl.text) ?? 0,
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
                    StageActionBar(
                      status: _status,
                      onStatusChange: _onStatusChange,
                      start: _start,
                      end: _end,
                    ),
                    const SizedBox(height: 20),
                    if (widget.stage.hasFulao) ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _fulaoSel,
                              decoration:
                                  const InputDecoration(labelText: 'Fulão'),
                              items: (widget.stage.machines ?? [])
                                  .map((m) => int.parse(m))
                                  .map((i) => DropdownMenuItem(
                                      value: i, child: Text('Fulão $i')))
                                  .toList(),
                              onChanged: (_status == StageStatus.idle ||
                                      _status == StageStatus.running)
                                  ? (v) => setState(() => _fulaoSel = v)
                                  : null,
                              validator: (_) =>
                                  _fulaoSel == null ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _openQuimicosDialog,
                              icon: const Icon(Icons.science),
                              label: Text(
                                  'Químicos (${_getQuimicosInformados()})'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (widget.stage.machines != null &&
                        !widget.stage.hasFulao) ...[
                      const Text('Máquina',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: widget.stage.machines!
                            .map((m) => ChoiceChip(
                                  label: Text(m),
                                  selected: false,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text('Responsável',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _respSel,
                      items: _responsaveis
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => _respSel = v!),
                    ),
                    if (widget.stage.needsResponsibleSuperior) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _respSupSel,
                        decoration: const InputDecoration(
                            labelText: 'Responsável Superior'),
                        items: _responsaveisSup
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setState(() => _respSupSel = v!),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('QTD Processada',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _qtdProcessadaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0',
                        suffixText: 'pçs',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Variáveis do Processo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...widget.stage.variables.map((v) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: _controllers[v.name],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: v.name,
                            suffixText: v.unit,
                            hintText: v.hint,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Obrigatório';
                            final num = double.tryParse(val);
                            if (num == null) return 'Número inválido';
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
                    }).toList(),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
