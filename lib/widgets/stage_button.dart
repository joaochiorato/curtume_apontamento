import 'package:flutter/material.dart';
import '../theme.dart';

class StageButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color cor;
  final bool finalizado;
  final VoidCallback? onTap;

  const StageButton({
    super.key,
    required this.label,
    required this.icon,
    required this.cor,
    this.finalizado = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const texto = Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(icon, color: texto),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3,
                    fontSize: 14,
                  ),
                ),
              ),
              if (finalizado)
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor:
                        MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.1),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 24),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: verde.withOpacity(.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: verde.withOpacity(.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 14, color: verde),
                        const SizedBox(width: 4),
                        Text(
                          'finalizado',
                          style: TextStyle(
                            color: verde,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
