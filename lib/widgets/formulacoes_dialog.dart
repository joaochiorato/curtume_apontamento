import 'package:flutter/material.dart';
import '../models/formulacoes_model.dart';

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
                        // ✅ REMOVIDO: Caixa "Como Funciona"

                        // Dropdown Formulação
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
                            ),
                            items: locaisEstoque.map((local) {
                              return DropdownMenuItem(
                                value: local,
                                child: Text(
                                  local,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: local != '— selecione —'
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

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quimico.nome,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: ctrl,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Quantidade',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide(
                                                color: ctrl.text.isNotEmpty
                                                    ? const Color(0xFF4CAF50)
                                                    : const Color(0xFFE0E0E0),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: ctrl.text.isNotEmpty
                                                ? const Color(0xFFE8F5E9)
                                                : Colors.white,
                                          ),
                                          onChanged: (_) =>
                                              setDialogState(() {}),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: const Color(0xFFE0E0E0),
                                          ),
                                        ),
                                        child: Text(
                                          quimico.unidade,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),

                  // Footer com botões
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
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: formulacaoSelecionada.isEmpty ||
                                    localEstoque == '— selecione —'
                                ? null
                                : () {
                                    // Valida se há pelo menos um químico preenchido
                                    final quantidades = <String, String>{};
                                    bool temAlgumPreenchido = false;

                                    for (final entry in controllers.entries) {
                                      final valor = entry.value.text.trim();
                                      quantidades[entry.key] = valor;
                                      if (valor.isNotEmpty) {
                                        temAlgumPreenchido = true;
                                      }
                                    }

                                    if (!temAlgumPreenchido) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Informe pelo menos um químico'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final resultado = QuimicosFormulacaoData(
                                      formulacaoCodigo: formulacaoSelecionada,
                                      localEstoque: localEstoque,
                                      quantidades: quantidades,
                                    );

                                    Navigator.pop(ctx, resultado);
                                  },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                            child: const Text('Confirmar'),
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
