import 'package:flutter/material.dart';
import '../models/formulacoes_model.dart';

// Importar o modelo (ajustar o path conforme necessário)
// import '../models/formulacoes_model.dart';

/// Dialog para informar químicos com seleção de formulação
/// e local de estoque único para todos os químicos
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
  String formulacaoSelecionada = dadosAtuais?.formulacaoCodigo ?? '';
  String localEstoque = dadosAtuais?.localEstoque ?? '— selecione —';
  Map<String, TextEditingController> controllers = {};

  // Inicializa controllers se já houver formulação selecionada
  if (formulacaoSelecionada.isNotEmpty) {
    final formulacao = formulacoes.firstWhere(
      (f) => f.codigo == formulacaoSelecionada,
      orElse: () => formulacoes.first,
    );

    for (final q in formulacao.quimicos) {
      controllers[q.nome] = TextEditingController(
        text: dadosAtuais?.quantidades[q.nome] ?? '',
      );
    }
  }

  return await showDialog<QuimicosFormulacaoData?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          // Atualiza controllers quando formulação muda
          void atualizarControllers() {
            if (formulacaoSelecionada.isEmpty) {
              controllers.clear();
              return;
            }

            final formulacao = formulacoes.firstWhere(
              (f) => f.codigo == formulacaoSelecionada,
            );

            // Remove controllers não usados
            controllers.removeWhere(
                (key, _) => !formulacao.quimicos.any((q) => q.nome == key));

            // Adiciona novos controllers
            for (final q in formulacao.quimicos) {
              if (!controllers.containsKey(q.nome)) {
                controllers[q.nome] = TextEditingController();
              }
            }
          }

          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
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
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Info box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(4),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF1976D2),
                                width: 4,
                              ),
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📋 Como Funciona',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '1. Selecione a Formulação desejada\n'
                                '2. Informe o Local de Estoque (único para todos)\n'
                                '3. Preencha as quantidades dos químicos',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Seleção de Formulação
                        const Text(
                          'Formulação *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: formulacaoSelecionada.isEmpty
                              ? null
                              : formulacaoSelecionada,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color(0xFF424242),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: formulacaoSelecionada.isNotEmpty
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF424242),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color(0xFF1976D2),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: formulacaoSelecionada.isNotEmpty
                                ? const Color(0xFFE8F5E9)
                                : Colors.white,
                            hintText: 'Selecione a formulação...',
                          ),
                          items: formulacoes.map((form) {
                            return DropdownMenuItem(
                              value: form.codigo,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    form.nome,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  Text(
                                    '${form.quimicos.length} produtos químicos',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              formulacaoSelecionada = value ?? '';
                              atualizarControllers();
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF424242),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFE0E0E0), thickness: 1),
                        const SizedBox(height: 20),

                        // Local de Estoque (só aparece se formulação selecionada)
                        if (formulacaoSelecionada.isNotEmpty) ...[
                          const Text(
                            'Local de Estoque *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Local onde TODOS os químicos desta formulação estão armazenados',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: localEstoque,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFF424242),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: localEstoque != '— selecione —'
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF424242),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1976D2),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: localEstoque != '— selecione —'
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.white,
                              prefixIcon: const Icon(
                                Icons.warehouse_outlined,
                                color: Color(0xFF424242),
                              ),
                            ),
                            items: locaisEstoque.map((local) {
                              return DropdownMenuItem(
                                value: local,
                                child: Text(
                                  local,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: local == '— selecione —'
                                        ? const Color(0xFF757575)
                                        : const Color(0xFF424242),
                                    fontWeight: local != '— selecione —'
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                localEstoque = value ?? '— selecione —';
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF424242),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFE0E0E0), thickness: 1),
                          const SizedBox(height: 20),

                          // Lista de químicos da formulação
                          const Text(
                            'Quantidades dos Químicos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...formulacoes
                              .firstWhere(
                                  (f) => f.codigo == formulacaoSelecionada)
                              .quimicos
                              .map((quimico) {
                            final ctrl = controllers[quimico.nome]!;
                            final hasValue = ctrl.text.isNotEmpty;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quimico.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  OutlinedButton(
                                    onPressed: () async {
                                      final result = await _showNumpad(
                                        context: context,
                                        titulo: quimico.nome,
                                        controller: ctrl,
                                        unidade: quimico.unidade,
                                      );

                                      if (result != null) {
                                        setDialogState(() {
                                          ctrl.text = result;
                                        });
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
                                        vertical: 14,
                                        horizontal: 16,
                                      ),
                                      backgroundColor: hasValue
                                          ? const Color(0xFFE8F5E9)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            hasValue
                                                ? '${ctrl.text} ${quimico.unidade}'
                                                : 'Informar ${quimico.unidade}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: hasValue
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: hasValue
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFF757575),
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: hasValue
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFF757575),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],

                        // Mensagem se nenhuma formulação selecionada
                        if (formulacaoSelecionada.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.science_outlined,
                                  size: 64,
                                  color: Color(0xFFBDBDBD),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Selecione uma formulação para começar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
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
                          onPressed: formulacaoSelecionada.isEmpty
                              ? null
                              : () {
                                  // Validar se local foi selecionado
                                  if (localEstoque == '— selecione —') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Selecione o Local de Estoque',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  // Criar mapa com quantidades
                                  final Map<String, String> quantidades = {};
                                  controllers.forEach((nome, ctrl) {
                                    if (ctrl.text.isNotEmpty) {
                                      quantidades[nome] = ctrl.text;
                                    }
                                  });

                                  // Criar objeto de retorno
                                  final resultado = QuimicosFormulacaoData(
                                    formulacaoCodigo: formulacaoSelecionada,
                                    localEstoque: localEstoque,
                                    quantidades: quantidades,
                                  );

                                  Navigator.pop(ctx, resultado);
                                },
                          child: const Text('Confirmar'),
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

/// Abre teclado numérico para inserir quantidade
Future<String?> _showNumpad({
  required BuildContext context,
  required String titulo,
  required TextEditingController controller,
  required String unidade,
}) async {
  String valor = controller.text;

  return await showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              titulo,
              style: const TextStyle(fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display do valor
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    valor.isEmpty ? '0' : '$valor $unidade',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Teclado numérico
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    // Números 1-9
                    ...List.generate(9, (i) {
                      final num = i + 1;
                      return _numButton(num.toString(), () {
                        setState(() {
                          valor += num.toString();
                        });
                      });
                    }),

                    // Ponto decimal
                    _numButton('.', () {
                      if (!valor.contains('.')) {
                        setState(() {
                          valor += '.';
                        });
                      }
                    }),

                    // Zero
                    _numButton('0', () {
                      setState(() {
                        valor += '0';
                      });
                    }),

                    // Backspace
                    _numButton('⌫', () {
                      if (valor.isNotEmpty) {
                        setState(() {
                          valor = valor.substring(0, valor.length - 1);
                        });
                      }
                    }, isBackspace: true),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, valor),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _numButton(String label, VoidCallback onPressed,
    {bool isBackspace = false}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isBackspace ? const Color(0xFFFFEBEE) : Colors.white,
      foregroundColor:
          isBackspace ? const Color(0xFFD32F2F) : const Color(0xFF424242),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              isBackspace ? const Color(0xFFD32F2F) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isBackspace ? const Color(0xFFD32F2F) : const Color(0xFF424242),
      ),
    ),
  );
}
