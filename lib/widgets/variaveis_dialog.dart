import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/stage.dart';

/// Dialog para preenchimento das variáveis do processo
class VariaveisDialog extends StatefulWidget {
  final List<VariableModel> variables;
  final Map<String, String>? valoresAtuais;
  final bool canEdit;

  const VariaveisDialog({
    super.key,
    required this.variables,
    this.valoresAtuais,
    this.canEdit = true,
  });

  @override
  State<VariaveisDialog> createState() => _VariaveisDialogState();
}

class _VariaveisDialogState extends State<VariaveisDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    
    // Inicializa os controllers com valores atuais (se existirem)
    for (final variable in widget.variables) {
      _controllers[variable.name] = TextEditingController(
        text: widget.valoresAtuais?[variable.name] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final valores = <String, String>{};
    _controllers.forEach((key, controller) {
      valores[key] = controller.text;
    });

    Navigator.pop(context, valores);
  }

  int _getPreenchidos() {
    return _controllers.values
        .where((ctrl) => ctrl.text.isNotEmpty)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final preenchidos = _getPreenchidos();
    final total = widget.variables.length;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.science,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Variáveis do Processo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$preenchidos de $total preenchidas',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: widget.variables.length,
                  itemBuilder: (context, index) {
                    final variable = widget.variables[index];
                    final controller = _controllers[variable.name]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome da variável
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  variable.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Campo de entrada
                          TextFormField(
                            controller: controller,
                            enabled: widget.canEdit,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: variable.unit,
                              hintText: variable.hint,
                              helperText: variable.min != null && variable.max != null
                                  ? 'Faixa: ${variable.min} - ${variable.max}'
                                  : null,
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: widget.canEdit
                                  ? Colors.white
                                  : Colors.grey.shade100,
                            ),
                            validator: (txt) {
                              if (txt == null || txt.isEmpty) {
                                return 'Informe ${variable.name}';
                              }
                              final num = double.tryParse(txt.replaceAll(',', '.'));
                              if (num == null) return 'Valor inválido';
                              if (variable.min != null && num < variable.min!) {
                                return 'Mínimo: ${variable.min}';
                              }
                              if (variable.max != null && num > variable.max!) {
                                return 'Máximo: ${variable.max}';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Rodapé com botões
            if (widget.canEdit)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.check),
                      label: Text('Salvar ($preenchidos/$total)'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Função helper para mostrar o dialog
Future<Map<String, String>?> showVariaveisDialog(
  BuildContext context, {
  required List<VariableModel> variables,
  Map<String, String>? valoresAtuais,
  bool canEdit = true,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => VariaveisDialog(
      variables: variables,
      valoresAtuais: valoresAtuais,
      canEdit: canEdit,
    ),
  );
}
