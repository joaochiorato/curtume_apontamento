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
        // Botão INICIAR
        Expanded(
          child: FilledButton(
            onPressed: (status == StageStatus.idle || status == StageStatus.paused)
                ? () => onStatusChange(StageStatus.running)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Iniciar'),
          ),
        ),
        const SizedBox(width: 8),
        
        // Botão PAUSAR
        Expanded(
          child: FilledButton(
            onPressed: status == StageStatus.running 
                ? () => onStatusChange(StageStatus.paused)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Pausar'),
          ),
        ),
        const SizedBox(width: 8),
        
        // Botão ENCERRAR
        Expanded(
          child: FilledButton(
            onPressed: (status == StageStatus.running || status == StageStatus.paused)
                ? () => onStatusChange(StageStatus.closed)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Encerrar'),
          ),
        ),
        const SizedBox(width: 8),
        
        // Botão REABRIR
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