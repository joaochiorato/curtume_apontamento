import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/ordem_producao.dart';
import '../../providers/ordem_provider.dart';
import '../../core/theme/app_theme.dart';
import '../ordem_detail/ordem_detail_screen.dart';

/// 🏠 Tela inicial com listagem de ordens
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Produção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdemProducaoProvider>().carregarOrdens();
            },
          ),
        ],
      ),
      body: Consumer<OrdemProducaoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.ordens.isEmpty) {
            return const Center(
              child: Text('Nenhuma ordem encontrada'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.carregarOrdens,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: provider.ordens.length,
              itemBuilder: (context, index) {
                final ordem = provider.ordens[index];
                return OrdemCard(ordem: ordem);
              },
            ),
          );
        },
      ),
    );
  }
}

/// 🎴 Card de Ordem de Produção
class OrdemCard extends StatelessWidget {
  final OrdemProducao ordem;

  const OrdemCard({
    super.key,
    required this.ordem,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final progresso = ordem.progresso;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrdemDetailScreen(ordemId: ordem.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OF ${ordem.numeroOf}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(context, ordem.status),
                ],
              ),
              const SizedBox(height: 12),

              // Informações principais
              _buildInfoRow(
                context,
                icon: Icons.business,
                label: 'Cliente',
                value: 'Vancouros',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today,
                label: 'Data',
                value: dateFormat.format(ordem.dataCriacao),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: Icons.inventory_2,
                label: 'Artigo',
                value: ordem.artigo,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: Icons.format_paint,
                label: 'Cor',
                value: ordem.cor,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: Icons.analytics,
                label: 'Quantidade',
                value: '${ordem.numeroPecasNF} peças',
              ),

              // Barra de progresso (apenas se em produção)
              if (ordem.status == StatusOrdem.emProducao ||
                  ordem.status == StatusOrdem.finalizado) ...[
                const SizedBox(height: 16),
                _buildProgressBar(context, progresso, ordem),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, StatusOrdem status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getStatusColor(status.label).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getStatusColor(status.label),
          width: 1,
        ),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: AppTheme.getStatusColor(status.label),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    double progresso,
    OrdemProducao ordem,
  ) {
    final percentual = (progresso * 100).toStringAsFixed(0);
    final concluidos = ordem.estagios.where((e) => e.isConcluido).length;
    final total = ordem.estagios.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '$percentual% ($concluidos/$total estágios)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progresso,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              ordem.status == StatusOrdem.finalizado
                  ? AppTheme.statusFinalizado
                  : AppTheme.statusEmProducao,
            ),
          ),
        ),
      ],
    );
  }
}
