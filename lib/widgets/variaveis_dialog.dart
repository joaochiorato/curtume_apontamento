import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/stage.dart';

/// Cores padrão do app (mesmo tom da tela principal)
const Color _primaryColor = Color(0xFF607D8B); // Blue Grey
const Color _primaryDark = Color(0xFF455A64);
const Color _primaryLight = Color(0xFFCFD8DC);
const Color _accentColor = Color(0xFF26A69A); // Teal

/// Dialog para preenchimento das variáveis do processo
Future<Map<String, String>?> showVariaveisDialog(
  BuildContext context, {
  required List<VariableModel> variables,
  Map<String, String>? valoresAtuais,
  bool canEdit = true,
}) async {
  if (!canEdit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inicie o processo para informar as variáveis.'),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }

  final Map<String, TextEditingController> controllers = {};
  for (final variable in variables) {
    controllers[variable.name] = TextEditingController(
      text: valoresAtuais?[variable.name] ?? '',
    );
  }

  return await showDialog<Map<String, String>?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          int getPreenchidos() {
            return controllers.values.where((ctrl) => ctrl.text.isNotEmpty).length;
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: _primaryDark,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Variáveis do Processo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${getPreenchidos()}/${variables.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close, color: Colors.white70, size: 22),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...variables.asMap().entries.map((entry) {
                            final index = entry.key;
                            final variable = entry.value;
                            final ctrl = controllers[variable.name]!;
                            final hasFaixa = variable.min != null && variable.max != null;
                            
                            return Padding(
                              padding: EdgeInsets.only(bottom: index < variables.length - 1 ? 14 : 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: ctrl.text.isNotEmpty ? _accentColor : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          variable.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF37474F),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          height: 40,
                                          child: TextField(
                                            controller: ctrl,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                            ],
                                            decoration: InputDecoration(
                                              hintText: hasFaixa ? '${variable.min} - ${variable.max}' : 'Valor',
                                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Colors.grey.shade300),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Colors.grey.shade300),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: _accentColor, width: 1.5),
                                              ),
                                              suffixText: variable.unit,
                                              suffixStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: const TextStyle(fontSize: 14),
                                            onChanged: (_) => setDialogState(() {}),
                                          ),
                                        ),
                                        if (hasFaixa) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            'Faixa: ${variable.min} - ${variable.max} ${variable.unit}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () {
                            final valores = <String, String>{};
                            controllers.forEach((key, ctrl) {
                              valores[key] = ctrl.text;
                            });
                            Navigator.pop(ctx, valores);
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: Text('Salvar (${getPreenchidos()}/${variables.length})'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _primaryDark,
                          ),
                        ),
                      ],
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