import 'package:flutter/material.dart';

class QtyCounter extends StatelessWidget {
  final int value;
  final bool enabled;
  final void Function(int) onChanged;

  const QtyCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  void _add(int delta) {
    final next = value + delta;
    if (next < 0) return;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quantidade Processada'),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                    onPressed: enabled ? () => _add(-1) : null,
                    icon: const Icon(Icons.remove)),
                Expanded(
                    child: Center(
                  child: Text('$value',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w700)),
                )),
                IconButton(
                    onPressed: enabled ? () => _add(1) : null,
                    icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ActionChip(
                  label: const Text('+5'),
                  onPressed: enabled ? () => _add(5) : null),
              ActionChip(
                  label: const Text('+10'),
                  onPressed: enabled ? () => _add(10) : null),
              ActionChip(
                  label: const Text('+50'),
                  onPressed: enabled ? () => _add(50) : null),
            ]),
          ],
        ),
      ),
    );
  }
}
