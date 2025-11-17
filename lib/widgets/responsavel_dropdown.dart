import 'package:flutter/material.dart';

/// 👤 Dropdown para seleção de responsável
class ResponsavelDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const ResponsavelDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  // Lista de responsáveis (mockada, em produção viria de API)
  static final List<String> _responsaveis = [
    'João Silva',
    'Maria Santos',
    'Pedro Oliveira',
    'Ana Costa',
    'Carlos Ferreira',
    'Juliana Almeida',
    'Roberto Souza',
    'Fernanda Lima',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            hintText: '— selecione —',
          ),
          isExpanded: true,
          items: _responsaveis.map((nome) {
            return DropdownMenuItem<String>(
              value: nome,
              child: Text(nome),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
