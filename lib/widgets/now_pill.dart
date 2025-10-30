import 'package:flutter/material.dart';
import '../theme.dart';

class NowPill extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const NowPill({super.key, required this.onTap, this.label = 'Agora'});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: roxoClaro.withOpacity(.25),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: roxoClaro.withOpacity(.6)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text('AGORA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: .2)),
          ],
        ),
      ),
    );
  }
}
