import 'package:flutter/material.dart';
import 'orders_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _acessarOrdens(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const OrdersPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF424242), // Cinza escuro do Frigosoft
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 HEADER COM LOGO ATAK
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF424242),
              ),
              child: Column(
                children: [
                  // Logo ATAK SISTEMAS
                  const Text(
                    'ATAK',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 8,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'SISTEMAS',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Onda decorativa (igual ao Frigosoft)
            CustomPaint(
              size: const Size(double.infinity, 50),
              painter: WavePainter(),
            ),

            // 📋 CONTEÚDO PRINCIPAL
            Expanded(
              child: Container(
                color: const Color(0xFFF5F5F5), // Fundo cinza claro
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card principal com ícone
                    GestureDetector(
                      onTap: () => _acessarOrdens(context),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ícone grande
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF424242).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.factory_outlined,
                                size: 60,
                                color: Color(0xFF424242),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Título
                            const Text(
                              'APONTAMENTO',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF424242),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtítulo
                            Text(
                              'Sistema de Apontamento de Couro',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão de acesso
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _acessarOrdens(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF424242),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'ACESSAR ORDENS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 📍 RODAPÉ COM VERSÃO
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: Text(
                  'Versão: 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🌊 Painter para criar a onda decorativa
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..lineTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.8,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.2,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
