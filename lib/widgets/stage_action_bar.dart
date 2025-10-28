import 'package:flutter/material.dart';

enum StageStatus { idle, running, paused, closed }

class StageActionBar extends StatelessWidget {
  final StageStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onClose;
  final VoidCallback onReopen;

  const StageActionBar({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onClose,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final canStart  = status == StageStatus.idle;
    final canPause  = status == StageStatus.running;
    final canClose  = status == StageStatus.running || status == StageStatus.paused;
    final canReopen = status == StageStatus.closed || status == StageStatus.paused;

    return Row(
      children: [
        Expanded(child: FilledButton(onPressed: canStart  ? onStart  : null, child: const Text('Iniciar'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton.tonal(onPressed: canPause  ? onPause  : null, child: const Text('Pausar'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton.tonal(onPressed: canClose  ? onClose  : null, child: const Text('Encerrar'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton(onPressed: canReopen ? onReopen : null, child: const Text('Reabrir'))),
      ],
    );
  }
}
