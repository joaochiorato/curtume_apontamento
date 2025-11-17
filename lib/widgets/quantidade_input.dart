import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

/// 🔢 Input para quantidade processada
class QuantidadeInput extends StatefulWidget {
  final String label;
  final String unidade;
  final int maximo;
  final ValueChanged<int> onChanged;
  final int? valorInicial;

  const QuantidadeInput({
    super.key,
    required this.label,
    required this.unidade,
    required this.maximo,
    required this.onChanged,
    this.valorInicial,
  });

  @override
  State<QuantidadeInput> createState() => _QuantidadeInputState();
}

class _QuantidadeInputState extends State<QuantidadeInput> {
  late TextEditingController _controller;
  int _quantidade = 0;

  @override
  void initState() {
    super.initState();
    _quantidade = widget.valorInicial ?? 0;
    _controller = TextEditingController(
      text: _quantidade > 0 ? _quantidade.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantidade(int valor) {
    setState(() {
      _quantidade = valor.clamp(0, widget.maximo);
      _controller.text = _quantidade.toString();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    widget.onChanged(_quantidade);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: _quantidade > widget.maximo
              ? AppTheme.error
              : Colors.orange.shade400,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                ),
          ),
          const SizedBox(height: 12),

          // Input principal
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: widget.unidade,
                    suffixStyle: Theme.of(context).textTheme.titleLarge,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    final numero = int.tryParse(value) ?? 0;
                    setState(() => _quantidade = numero);
                    widget.onChanged(numero);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Informação de máximo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Máximo: ${widget.maximo} ${widget.unidade}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_quantidade > widget.maximo)
                Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: AppTheme.error),
                    const SizedBox(width: 4),
                    Text(
                      'Excede o máximo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
