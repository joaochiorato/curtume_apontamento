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
            controllers.removeWhere((key, _) => 
              !formulacao.quimicos.any((q) => q.nome == key));

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
                          initialValue: formulacaoSelecionada.isEmpty ? null : formulacaoSelecionada,
                          isExpanded: true, // ✅ Evita overflow
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12, // ✅ Reduzido de 16 para 12
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
                              child: Text(
                                form.nome, // ✅ Apenas o nome, sem linha extra
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF424242),
                                ),
                                overflow: TextOverflow.ellipsis, // ✅ Evita overflow
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

                        const SizedBox(height: 16),

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
                          Text(
                            'Local onde todos os químicos estão armazenados',
                            style: TextStyle(
                              fontSize: 11, // ✅ Reduzido de 12 para 11
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: localEstoque,
                            isExpanded: true, // ✅ Evita overflow
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12, // ✅ Reduzido
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
                                        ? const Color(0xFF424242)
                                        : Colors.grey[600],
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

                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

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
                              .firstWhere((f) => f.codigo == formulacaoSelecionada)
                              .quimicos
                              .map((quimico) {
                            final ctrl = controllers[quimico.nome]!;
                            final hasValue = ctrl.text.isNotEmpty;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nome do químico
                                  Expanded(
                                    flex: 3,
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
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Campo de quantidade
                                  SizedBox(
                                    width: 100, // ✅ Largura fixa menor
                                    child: TextField(
                                      controller: ctrl,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.right, // ✅ Alinhado à direita
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10, // ✅ Compacto
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                            color: hasValue
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFFE0E0E0),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: hasValue
                                            ? const Color(0xFFE8F5E9)
                                            : Colors.white,
                                        isDense: true, // ✅ Compacto
                                      ),
                                      onChanged: (_) => setDialogState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Unidade
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                      ),
                                    ),
                                    child: Text(
                                      quimico.unidade,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),

                  // Footer com botões
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Informe pelo menos um químico'),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
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