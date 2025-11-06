import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/stage.dart';
import '../models/formulacoes_model.dart';
import '../widgets/stage_action_bar.dart';
import '../widgets/formulacoes_dialog.dart';

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

    // Sugere processar o restante
    _qtdProcessadaCtrl.text = widget.quantidadeRestante.toString();

    // ✅ NÃO carrega dados anteriores - cada apontamento é novo
    // Comentado: _loadSavedData();
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

    // Validação adicional de quantidade
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

    // ✅ Validação: Deve ter iniciado e encerrado o estágio
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
                                  'Total da OF:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${widget.quantidadeTotal} peles',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
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

                    // ✅ Barra de ações: SEMPRE permite Iniciar/Pausar/Encerrar
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
                              validator: (_) => _fulaoSel == null
                                  ? 'Selecione o fulão'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _openQuimicosDialog,
                            icon: const Icon(Icons.science, size: 18),
                            label:
                                Text('Químicos (${_getQuimicosInformados()})'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    DropdownButtonFormField<String>(
                      value: _respSel,
                      decoration:
                          const InputDecoration(labelText: 'Responsável'),
                      items: _responsaveis
                          .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (_status == StageStatus.idle ||
                              _status == StageStatus.running)
                          ? (v) => setState(() => _respSel = v!)
                          : null,
                      validator: (v) => v == '— selecione —'
                          ? 'Selecione o responsável'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    if (widget.stage.needsResponsibleSuperior)
                      DropdownButtonFormField<String>(
                        value: _respSupSel,
                        decoration: const InputDecoration(
                            labelText: 'Responsável Superior'),
                        items: _responsaveisSup
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (_status == StageStatus.idle ||
                                _status == StageStatus.running)
                            ? (v) => setState(() => _respSupSel = v!)
                            : null,
                        validator: (v) => v == '— selecione —'
                            ? 'Selecione o responsável superior'
                            : null,
                      ),

                    if (widget.stage.needsResponsibleSuperior)
                      const SizedBox(height: 16),

                    // Campo de quantidade processada com destaque
                    TextFormField(
                      controller: _qtdProcessadaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'QTD PROCESSADA NESTE APONTAMENTO *',
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        suffixText: 'peles',
                        suffixStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        helperText:
                            'Máximo: ${widget.quantidadeRestante} peles',
                        helperStyle: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.orange.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.orange.shade200, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.orange.shade300, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.orange.shade700, width: 2),
                        ),
                      ),
                      validator: (txt) {
                        if (txt == null || txt.isEmpty)
                          return 'Informe a quantidade';
                        final n = int.tryParse(txt);
                        if (n == null) return 'Valor inválido';
                        if (n <= 0) return 'Quantidade deve ser maior que 0';
                        if (n > widget.quantidadeRestante) {
                          return 'Máximo: ${widget.quantidadeRestante} peles';
                        }
                        return null;
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

          // Rodapé com botões
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
                        : const Text('Salvar Apontamento'),
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
