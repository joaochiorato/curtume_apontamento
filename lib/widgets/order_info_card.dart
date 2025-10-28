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
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: bold ? 15 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: Colors.white,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (headerColor ?? const Color(0xFF546E7A)).withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: headerColor ?? const Color(0xFF546E7A),
                letterSpacing: 1,
              ),
            ),
          ),
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
            // Cabeçalho Principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF546E7A),
                    Color(0xFF455A64),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OF Nº ${orderData['of'] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lote WET BLUE: ${orderData['lote'] ?? '-'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Seção Artigo em Grid
            _buildSectionCard(
              title: 'ARTIGO',
              headerColor: const Color(0xFF546E7A),
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

            // Seção Quantidades
            _buildSectionCard(
              title: 'QUANTIDADES',
              headerColor: const Color(0xFF607D8B),
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

            // Seção Peso
            _buildSectionCard(
              title: 'PESO',
              headerColor: const Color(0xFF546E7A),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF66BB6A).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.scale,
                        color: Color(0xFF66BB6A),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peso Líquido',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${orderData['pesoLiquido'] ?? '-'} kg',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (orderData['diferenca']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  _buildInfoItem('Diferença %', orderData['diferenca'] ?? '-'),
                ],
              ],
            ),

            // Observações (se houver)
            if (orderData['obs']?.isNotEmpty ?? false)
              _buildSectionCard(
                title: 'OBSERVAÇÕES',
                headerColor: const Color(0xFF78909C),
                children: [
                  Text(
                    orderData['obs'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
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
