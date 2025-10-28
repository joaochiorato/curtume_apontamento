import 'package:flutter/material.dart';

class OrderInfoCard extends StatelessWidget {
  final Map<String, String> orderData;
  
  const OrderInfoCard({super.key, required this.orderData});

  Widget _buildInfoItem(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF616161), // Cinza médio mais escuro
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: bold ? 15 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: const Color(0xFF424242), // Cinza escuro
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Fundo cinza claro
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0), // Borda cinza
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF757575), // Cinza médio
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242), // Cinza escuro
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    Color? headerColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor ?? const Color(0xFF424242), // Cinza escuro Frigosoft
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Conteúdo da seção
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ CABEÇALHO PRINCIPAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF424242), // Cinza escuro Frigosoft
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Ícone
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informações
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OF Nº ${orderData['of'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lote WET BLUE: ${orderData['lote'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 📦 SEÇÃO ARTIGO
            _buildSectionCard(
              title: 'ARTIGO',
              headerColor: const Color(0xFF424242),
              children: [
                _buildInfoItem('Artigo', orderData['artigo'] ?? '-', bold: true),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildGridItem('PVE', orderData['pve'] ?? '-')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGridItem('Classe', orderData['classe'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildGridItem('Cor', orderData['cor'] ?? '-')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGridItem('PO', orderData['po'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildGridItem('Crust Item', orderData['crustItem'] ?? '-')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGridItem('Esp. Final', orderData['espFinal'] ?? '-')),
                  ],
                ),
              ],
            ),

            // 📊 SEÇÃO QUANTIDADES
            _buildSectionCard(
              title: 'QUANTIDADES',
              headerColor: const Color(0xFF546E7A),
              children: [
                Row(
                  children: [
                    Expanded(child: _buildGridItem('Nº Peças NF', orderData['nPcsNf'] ?? '-')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGridItem('Metragem NF', orderData['metragemNf'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 8),
                _buildGridItem('AVG', orderData['avg'] ?? '-'),
                if (orderData['nPcsEnx']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildGridItem('Nº Peças ENX', orderData['nPcsEnx'] ?? '-')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildGridItem('Metragem ENX', orderData['metragemEnx'] ?? '-')),
                    ],
                  ),
                ],
              ],
            ),

            // ⚖️ SEÇÃO PESO
            _buildSectionCard(
              title: 'PESO',
              headerColor: const Color(0xFF4CAF50), // Verde Frigosoft
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.scale,
                        color: Color(0xFF4CAF50),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Peso Líquido',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF616161),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${orderData['pesoLiquido'] ?? '-'} kg',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (orderData['diferenca']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  _buildInfoItem('Diferença %', orderData['diferenca'] ?? '-'),
                ],
              ],
            ),

            // 📝 OBSERVAÇÕES (se houver)
            if (orderData['obs']?.isNotEmpty ?? false)
              _buildSectionCard(
                title: 'OBSERVAÇÕES',
                headerColor: const Color(0xFFFF9800), // Laranja Frigosoft
                children: [
                  Text(
                    orderData['obs'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF424242),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
