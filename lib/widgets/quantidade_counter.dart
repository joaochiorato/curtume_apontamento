import 'package:flutter/material.dart';

/// Widget contador de quantidade com botões de incremento rápido
class QuantidadeCounter extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Function(int)? onChanged;

  const QuantidadeCounter({
    super.key,
    required this.controller,
    this.label = 'Quantidade Processada*',
    this.helperText,
    this.onChanged,
  });

  @override
  State<QuantidadeCounter> createState() => _QuantidadeCounterState();
}

class _QuantidadeCounterState extends State<QuantidadeCounter> {
  int get _currentValue => int.tryParse(widget.controller.text) ?? 0;

  void _updateValue(int newValue) {
    if (newValue < 0) newValue = 0;
    setState(() {
      widget.controller.text = newValue.toString();
    });
    widget.onChanged?.call(newValue);
  }

  void _increment(int amount) {
    _updateValue(_currentValue + amount);
  }

  void _decrement() {
    _updateValue(_currentValue - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Contador principal com botões - e +
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Linha com - [ valor ] +
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão -
                  _buildCircleButton(
                    icon: Icons.remove,
                    onPressed: _decrement,
                    color: Colors.red.shade400,
                  ),

                  const SizedBox(width: 20),

                  // Display do valor
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade400,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _currentValue.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Botão +
                  _buildCircleButton(
                    icon: Icons.add,
                    onPressed: () => _increment(1),
                    color: Colors.green.shade400,
                  ),

                  const SizedBox(width: 12),

                  // Texto "peles"
                  Text(
                    'peles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              
              // Linha de separação
              Divider(
                color: Colors.orange.shade200,
                thickness: 1,
              ),
              
              const SizedBox(height: 16),

              // Botões de incremento rápido
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickButton(10),
                  const SizedBox(width: 12),
                  _buildQuickButton(20),
                  const SizedBox(width: 12),
                  _buildQuickButton(50),
                ],
              ),
            ],
          ),
        ),

        // Helper text (se fornecido)
        if (widget.helperText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.helperText!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(int amount) {
    return Expanded(
      child: Material(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _increment(amount),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Text(
              '+$amount',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
