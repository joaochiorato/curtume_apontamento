import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/formulacoes_model.dart';

/// Cores padrão do app (mesmo tom da tela principal)
const Color _primaryColor = Color(0xFF607D8B); // Blue Grey
const Color _primaryDark = Color(0xFF455A64);
const Color _primaryLight = Color(0xFFCFD8DC);
const Color _accentColor = Color(0xFF26A69A); // Teal

/// Dialog para gerenciar apontamentos de químicos do REMOLHO
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

  QuimicosFormulacaoData quimicosData = dadosAtuais ?? QuimicosFormulacaoData();

  return await showDialog<QuimicosFormulacaoData?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final dfTime = DateFormat('HH:mm');

          void _addNovoApontamento() async {
            final result = await _showFormularioQuimico(context);
            if (result != null) {
              setDialogState(() {
                quimicosData = quimicosData.addApontamento(result);
              });
            }
          }

          void _editarApontamento(int index) async {
            final apontamento = quimicosData.apontamentos[index];
            final result = await _showFormularioQuimico(
              context,
              apontamentoExistente: apontamento,
            );
            if (result != null) {
              setDialogState(() {
                quimicosData = quimicosData.updateApontamento(index, result);
              });
            }
          }

          void _removerApontamento(int index) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Remover Apontamento'),
                content: const Text('Deseja remover este apontamento de químicos?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setDialogState(() {
                        quimicosData = quimicosData.removeApontamento(index);
                      });
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Remover'),
                  ),
                ],
              ),
            );
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 550),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header - Cor padrão
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: _primaryDark,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.science, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Apontamento Químicos',
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
                            '${quimicosData.apontamentos.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx, quimicosData),
                          child: const Icon(Icons.close, color: Colors.white70, size: 22),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo
                  Flexible(
                    child: quimicosData.apontamentos.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    size: 48,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nenhum químico lançado',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Clique em "+ Novo" para adicionar',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: quimicosData.apontamentos.length,
                            itemBuilder: (context, index) {
                              final apt = quimicosData.apontamentos[index];
                              final qtdQuimicos = apt.getQuantidadeInformados();

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: _primaryColor,
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
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
                                                  'Fulão ${apt.fulao} - ${apt.localEstoque}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Color(0xFF37474F),
                                                  ),
                                                ),
                                                Text(
                                                  '${dfTime.format(apt.dataHora)} • $qtdQuimicos químico${qtdQuimicos != 1 ? 's' : ''}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _editarApontamento(index),
                                            icon: Icon(Icons.edit_outlined, size: 18, color: _primaryColor),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          ),
                                          IconButton(
                                            onPressed: () => _removerApontamento(index),
                                            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          ),
                                        ],
                                      ),
                                      
                                      if (qtdQuimicos > 0) ...[
                                        const Divider(height: 16),
                                        ...quimicosRemolho.where((q) => 
                                          apt.quantidades[q.codigo]?.isNotEmpty == true
                                        ).map((q) {
                                          final qtd = apt.quantidades[q.codigo]!;
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 2),
                                            child: Row(
                                              children: [
                                                Icon(Icons.circle, size: 6, color: _accentColor),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    q.nome,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '$qtd ${q.unidade}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: _accentColor,
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
                              );
                            },
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
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addNovoApontamento,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Novo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryDark,
                              side: const BorderSide(color: _primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(ctx, quimicosData),
                            style: FilledButton.styleFrom(
                              backgroundColor: _primaryDark,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Fechar'),
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

/// Dialog interno para formulário de um único apontamento
Future<ApontamentoQuimico?> _showFormularioQuimico(
  BuildContext context, {
  ApontamentoQuimico? apontamentoExistente,
}) async {
  int? fulaoSelecionado = apontamentoExistente?.fulao;
  String localEstoque = apontamentoExistente?.localEstoque ?? '— selecione —';
  
  final Map<String, TextEditingController> controllers = {};
  for (final quimico in quimicosRemolho) {
    controllers[quimico.codigo] = TextEditingController(
      text: apontamentoExistente?.quantidades[quimico.codigo] ?? '',
    );
  }

  final isEditing = apontamentoExistente != null;

  return await showDialog<ApontamentoQuimico?>(
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
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isEditing ? Icons.edit : Icons.add_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isEditing ? 'Editar Químico' : 'Novo Químico',
                            style: const TextStyle(
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
                            '${getPreenchidos()}/${quimicosRemolho.length}',
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
                          _buildLabel('Fulão'),
                          const SizedBox(height: 6),
                          _buildDropdown<int>(
                            value: fulaoSelecionado,
                            hint: '— selecione —',
                            items: [1, 2, 3, 4].map((n) => 
                              DropdownMenuItem(value: n, child: Text('Fulão $n'))
                            ).toList(),
                            onChanged: (v) => setDialogState(() => fulaoSelecionado = v),
                          ),

                          const SizedBox(height: 14),

                          _buildLabel('Local de Estoque'),
                          const SizedBox(height: 6),
                          _buildDropdown<String>(
                            value: localEstoque == '— selecione —' ? null : localEstoque,
                            hint: '— selecione —',
                            items: locaisEstoque.where((l) => l != '— selecione —').map((l) => 
                              DropdownMenuItem(value: l, child: Text(l))
                            ).toList(),
                            onChanged: (v) => setDialogState(() => localEstoque = v ?? '— selecione —'),
                          ),

                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade200),
                          const SizedBox(height: 12),

                          ...quimicosRemolho.asMap().entries.map((entry) {
                            final index = entry.key;
                            final quimico = entry.value;
                            final ctrl = controllers[quimico.codigo]!;
                            
                            return Padding(
                              padding: EdgeInsets.only(bottom: index < quimicosRemolho.length - 1 ? 12 : 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
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
                                          quimico.nome,
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
                                              hintText: 'Quantidade',
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
                                              suffixText: quimico.unidade,
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
                            if (fulaoSelecionado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selecione o Fulão!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (localEstoque == '— selecione —') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selecione o Local de Estoque!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final temQuimico = controllers.values.any((c) => c.text.isNotEmpty);
                            if (!temQuimico) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Informe pelo menos um químico!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final quantidades = <String, String>{};
                            controllers.forEach((codigo, ctrl) {
                              quantidades[codigo] = ctrl.text;
                            });

                            Navigator.pop(ctx, ApontamentoQuimico(
                              fulao: fulaoSelecionado!,
                              localEstoque: localEstoque,
                              quantidades: quantidades,
                              dataHora: apontamentoExistente?.dataHora,
                            ));
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(isEditing ? 'Atualizar' : 'Salvar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _accentColor,
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

Widget _buildLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF546E7A),
    ),
  );
}

Widget _buildDropdown<T>({
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?) onChanged,
}) {
  return Container(
    height: 44,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        hint: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(hint, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        items: items,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF37474F)),
      ),
    ),
  );
}