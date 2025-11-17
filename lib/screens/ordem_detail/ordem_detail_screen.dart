import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/ordem_producao.dart';
import '../../providers/ordem_provider.dart';
import '../../core/theme/app_theme.dart';
import '../stage/stage_screen.dart';

/// 📋 Tela de detalhes da Ordem de Produção
class OrdemDetailScreen extends StatelessWidget {
  final String ordemId;

  const OrdemDetailScreen({
    super.key,
    required this.ordemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Ordem'),
      ),
      body: Consumer<OrdemProducaoProvider>(
        builder: (context, provider, child) {
          final ordem = provider.buscarOrdemPorId(ordemId);

          if (ordem == null) {
            return const Center(
              child: Text('Ordem não encontrada'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho da OF
                _buildHeader(context, ordem),
                
                const Divider(height: 1),

                // Informações detalhadas
                _buildInfoSection(context, ordem),

                const Divider(height: 1),

                // Lista de estágios
                _buildEstagiosSection(context, ordem),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OrdemProducao ordem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OF ${ordem.numeroOf}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  ordem.artigo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
              _buildStatusBadge(ordem.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StatusOrdem status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: AppTheme.getStatusColor(status.label),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, OrdemProducao ordem) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações da Ordem',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // Grade de informações
          _buildInfoGrid(context, [
            {'label': 'PVE', 'value': ordem.pve},
            {'label': 'Cor', 'value': ordem.cor},
            {'label': 'Classe', 'value': ordem.classe},
            {'label': 'PO', 'value': ordem.po},
            {'label': 'Crust Item', 'value': ordem.crustItem},
            {'label': 'Esp Final', 'value': ordem.espFinal},
            {'label': 'Lote WET BLUE', 'value': ordem.loteWetBlue},
            {'label': 'Data', 'value': dateFormat.format(ordem.dataCriacao)},
          ]),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          Text(
            'Dados de Produção',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          _buildInfoGrid(context, [
            {'label': 'Nº Peças NF', 'value': ordem.numeroPecasNF.toString()},
            {'label': 'Metragem NF', 'value': ordem.metragemNF.toStringAsFixed(2)},
            {'label': 'AVG', 'value': ordem.avg.toStringAsFixed(2)},
            {'label': 'Peso Líquido', 'value': '${ordem.pesoLiquido.toStringAsFixed(2)} kg'},
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, List<Map<String, String>> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['label']!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item['value']!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEstagiosSection(BuildContext context, OrdemProducao ordem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estágios de Produção',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${ordem.estagios.where((e) => e.isConcluido).length}/${ordem.estagios.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: ordem.estagios.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final estagio = ordem.estagios[index];
            return EstagioCard(
              ordem: ordem,
              estagio: estagio,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// 🎴 Card de Estágio
class EstagioCard extends StatelessWidget {
  final OrdemProducao ordem;
  final Estagio estagio;

  const EstagioCard({
    super.key,
    required this.ordem,
    required this.estagio,
  });

  @override
  Widget build(BuildContext context) {
    final progresso = estagio.progresso;
    final percentual = (progresso * 100).toStringAsFixed(0);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: ordem.status == StatusOrdem.cancelado || ordem.status == StatusOrdem.finalizado
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StageScreen(
                      ordemId: ordem.id,
                      estagioId: estagio.id,
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Número do estágio
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: estagio.isConcluido
                          ? AppTheme.statusFinalizado
                          : estagio.isIniciado
                              ? AppTheme.statusEmProducao
                              : AppTheme.statusAguardando,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: estagio.isConcluido
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              '${estagio.ordem}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nome do estágio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estagio.nome,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (estagio.isIniciado)
                          Text(
                            '${estagio.quantidadeProcessada}/${estagio.quantidadeTotal} peças',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),

                  // Status
                  if (estagio.isConcluido)
                    const Icon(Icons.check_circle, color: AppTheme.statusFinalizado)
                  else if (estagio.isIniciado)
                    Text(
                      '$percentual%',
                      style: const TextStyle(
                        color: AppTheme.statusEmProducao,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textHint),
                ],
              ),

              // Barra de progresso
              if (estagio.isIniciado && !estagio.isConcluido) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.statusEmProducao,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
