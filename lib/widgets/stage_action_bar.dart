import 'package:flutter/material.dart';
import '../models/stage.dart';

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
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: status == StageStatus.idle ? onStart : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Iniciar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: status == StageStatus.running ? onPause : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Pausar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: status == StageStatus.running || status == StageStatus.paused ? onClose : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Encerrar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: status == StageStatus.closed ? onReopen : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Reabrir'),
          ),
        ),
      ],
    );
  }
}
