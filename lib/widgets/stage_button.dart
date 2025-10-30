import 'package:flutter/material.dart';

class StageButton extends StatelessWidget {
  final String label;
  final bool finalizado;
  final VoidCallback onTap;

  const StageButton({
    super.key,
    required this.label,
    required this.finalizado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: finalizado ? Colors.green : const Color(0xFF546E7A),
          child: Icon(
            finalizado ? Icons.check : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: finalizado
            ? const Chip(
                label: Text('Concluído', style: TextStyle(fontSize: 11)),
                backgroundColor: Color(0xFF4CAF50),
                labelStyle: TextStyle(color: Colors.white),
              )
            : const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
