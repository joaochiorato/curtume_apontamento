import 'package:flutter/material.dart';
import '../models/stage.dart';

class StageActionBar extends StatelessWidget {
  final StageStatus status;
  final void Function(StageStatus) onStatusChange;
  final DateTime? start;
  final DateTime? end;

  const StageActionBar({
    super.key,
    required this.status,
    required this.onStatusChange,
    this.start,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: status == StageStatus.idle 
                ? () => onStatusChange(StageStatus.running)
                : null,
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
            onPressed: status == StageStatus.running 
                ? () => onStatusChange(StageStatus.paused)
                : null,
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
            onPressed: status == StageStatus.running || status == StageStatus.paused 
                ? () => onStatusChange(StageStatus.closed)
                : null,
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
            onPressed: status == StageStatus.closed 
                ? () => onStatusChange(StageStatus.running)
                : null,
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