import 'package:flutter/material.dart';

class QtyCounter extends StatelessWidget {
  final int value;
  final bool enabled;
  final void Function(int) onChanged;

  const QtyCounter({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantidade Processada',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: enabled ? () => onChanged(value - 1 < 0 ? 0 : value - 1) : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: enabled ? const Color(0xFFF44336) : Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: enabled ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: enabled ? const Color(0xFF4CAF50) : Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickButton('+5', () => onChanged(value + 5)),
              const SizedBox(width: 8),
              _buildQuickButton('+10', () => onChanged(value + 10)),
              const SizedBox(width: 8),
              _buildQuickButton('+50', () => onChanged(value + 50)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      child: Text(label),
    );
  }
}
