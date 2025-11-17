import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/stage.dart';
import '../models/formulacoes_model.dart';
import '../widgets/stage_action_bar.dart';
import '../widgets/formulacoes_dialog.dart';
import '../widgets/variaveis_dialog.dart'; // ✅ NOVO IMPORT

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
  QuimicosFormulacaoData? _quimicosData;
  Map<String, String> _variaveisData = {}; // ✅ NOVO: Dados das variáveis
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
    _qtdProcessadaCtrl.text = '0';
  }

  @override
  void dispose() {
    _obs.dispose();
    _qtdProcessadaCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _isRemolho => widget.stage.code.toUpperCase() == 'REMOLHO';
  bool get _hasMachines => widget.stage.machines != null && widget.stage.machines!.isNotEmpty;

  int _getQuimicosInformados() {
    return _quimicosData?.getQuantidadeInformados() ?? 0;
  }

  // ✅ NOVO: Conta variáveis preenchidas
  int _getVariaveisPreenchidas() {
    return _variaveisData.values.where((v) => v.isNotEmpty).length;
  }

  Future<void> _openQuimicosDialog() async {
    final canEdit = (_status == StageStatus.idle || _status == StageStatus.running);

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

  // ✅ NOVO: Abre dialog de variáveis
  Future<void> _openVariaveisDialog() async {
    final canEdit = (_status == StageStatus.idle || _status == StageStatus.running);

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
    }
  }

  // ✅ Métodos do contador
  int get _currentValue => int.tryParse(_qtdProcessadaCtrl.text) ?? 0;

  void _updateValue(int newValue) {
    if (newValue < 0) newValue = 0;
    setState(() {
      _qtdProcessadaCtrl.text = newValue.toString();
    });
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

    // ✅ Usa _variaveisData ao invés de controllers
    final data = <String, dynamic>{
      'fulao': _fulaoSel,
      'responsavel': _respSel,
      'responsavelSuperior': _respSupSel,
      'qtdProcessada': qtdApontamento,
      'observacao': _obs.text,
      'start': _start?.toIso8601String(),
      'end': _end?.toIso8601String(),
      'status': _status.name,
      'variables': _variaveisData,
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
                    // Barra de ações: Iniciar/Pausar/Encerrar/Reabrir
                    StageActionBar(
                      status: _status,
                      onStatusChange: _onStatusChange,
                      start: _start,
                      end: _end,
                    ),

                    const SizedBox(height: 16),

                    // ✅ Botões Químicos e Variáveis lado a lado (REMOLHO)
                    if (_isRemolho)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openQuimicosDialog,
                              icon: const Icon(Icons.science),
                              label: Text('Químicos (${_getQuimicosInformados()})'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                side: BorderSide(color: Colors.blue.shade700, width: 2),
                                foregroundColor: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openVariaveisDialog,
                              icon: const Icon(Icons.tune),
                              label: Text('Variáveis (${_getVariaveisPreenchidas()}/${widget.stage.variables.length})'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                side: BorderSide(color: Colors.green.shade700, width: 2),
                                foregroundColor: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

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

                    const SizedBox(height: 16),

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

                    // ✅ CONTADOR DE QUANTIDADE (COMPACTO)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantidade Processada*',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Linha com - [ valor ] +
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Botão -
                                  Material(
                                    color: Colors.red.shade400,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: _decrement,
                                      customBorder: const CircleBorder(),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Display do valor
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 80),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      _currentValue.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Botão +
                                  Material(
                                    color: Colors.green.shade400,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: () => _increment(1),
                                      customBorder: const CircleBorder(),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    'peles',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              
                              Divider(
                                color: Colors.orange.shade200,
                                thickness: 1,
                                height: 1,
                              ),
                              
                              const SizedBox(height: 12),

                              // Botões de incremento rápido (COMPACTOS)
                              Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(6),
                                      child: InkWell(
                                        onTap: () => _increment(10),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Text(
                                            '+10',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Material(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(6),
                                      child: InkWell(
                                        onTap: () => _increment(20),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Text(
                                            '+20',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Material(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(6),
                                      child: InkWell(
                                        onTap: () => _increment(50),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Text(
                                            '+50',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Máximo: ${widget.quantidadeRestante} peles',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

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
