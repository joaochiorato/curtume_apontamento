import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/formulacoes_model.dart';

/// Dialog para informar químicos do REMOLHO
/// Conforme Teste de Mesa - lista direta dos químicos (sem formulação)
Future<QuimicosFormulacaoData?> showQuimicosDialog(
  BuildContext context, {
  required QuimicosFormulacaoData? dadosAtuais,
  required bool canEdit,
}) async {
  if (!canEdit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inicie o processo para informar os químicos.'),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }

  // Estado inicial
  String localEstoque = dadosAtuais?.localEstoque ?? '— selecione —';
  
  // Controllers para cada químico do teste de mesa
  final Map<String, TextEditingController> controllers = {};
  for (final quimico in quimicosRemolho) {
    controllers[quimico.codigo] = TextEditingController(
      text: dadosAtuais?.quantidades[quimico.codigo] ?? '',
    );
  }

  return await showDialog<QuimicosFormulacaoData?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          // Conta químicos preenchidos
          int getPreenchidos() {
            return controllers.values
                .where((ctrl) => ctrl.text.isNotEmpty)
                .length;
          }

          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF546E7A),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
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
                        // Badge com quantidade preenchida
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${getPreenchidos()}/${quimicosRemolho.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Local de Estoque
                        const Text(
                          'Local de Estoque *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: localEstoque,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: localEstoque != '— selecione —'
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE0E0E0),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: localEstoque != '— selecione —'
                                ? const Color(0xFFE8F5E9)
                                : Colors.white,
                          ),
                          items: locaisEstoque.map((local) {
                            return DropdownMenuItem(
                              value: local,
                              child: Text(
                                local,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: local != '— selecione —'
                                      ? const Color(0xFF424242)
                                      : Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              localEstoque = value ?? '— selecione —';
                            });
                          },
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Título da lista de químicos
                        const Text(
                          'Quantidades dos Químicos',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Conforme roteiro de produção',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lista de químicos do teste de mesa
                        ...quimicosRemolho.map((quimico) {
                          final ctrl = controllers[quimico.codigo]!;
                          final hasValue = ctrl.text.isNotEmpty;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: hasValue
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: hasValue
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nome do químico
                                Row(
                                  children: [
                                    Icon(
                                      hasValue
                                          ? Icons.check_circle
                                          : Icons.science_outlined,
                                      size: 18,
                                      color: hasValue
                                          ? const Color(0xFF4CAF50)
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        quimico.nome,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: hasValue
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFF424242),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Código do produto
                                Text(
                                  'Código: ${quimico.codigo}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Campo de quantidade
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: ctrl,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*'),
                                          ),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Informe a quantidade',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          isDense: true,
                                        ),
                                        onChanged: (_) => setDialogState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Unidade
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEEEEE),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        quimico.unidade,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF616161),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Footer com botões
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            if (localEstoque == '— selecione —') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Selecione o local de estoque!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Coleta as quantidades
                            final quantidades = <String, String>{};
                            controllers.forEach((codigo, ctrl) {
                              quantidades[codigo] = ctrl.text;
                            });

                            // Retorna os dados
                            final data = QuimicosFormulacaoData(
                              localEstoque: localEstoque,
                              quantidades: quantidades,
                            );

                            Navigator.pop(ctx, data);
                          },
                          child: const Text('Salvar'),
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