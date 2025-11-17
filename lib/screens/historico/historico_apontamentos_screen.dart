import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/apontamento_evento.dart';

class HistoricoApontamentosScreen extends StatelessWidget {
  final String estagioNome;
  final List<ApontamentoCompleto> apontamentos;

  const HistoricoApontamentosScreen({
    super.key,
    required this.estagioNome,
    required this.apontamentos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Histórico - $estagioNome'),
        elevation: 0,
      ),
      body: apontamentos.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apontamentos.length,
              itemBuilder: (context, index) {
                final apontamento = apontamentos[index];
                return _buildApontamentoCard(context, apontamento, index + 1);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum apontamento registrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Os apontamentos aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApontamentoCard(
    BuildContext context,
    ApontamentoCompleto apontamento,
    int numero,
  ) {
    final dfDate = DateFormat('dd/MM/yyyy');
    final dfTime = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade700,
          child: Text(
            '#$numero',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apontamento #$numero',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dfDate.format(apontamento.dataCriacao),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '${apontamento.quantidadeProcessada} peles',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  apontamento.responsavel ?? 'Não informado',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              if (apontamento.duracaoTotal != null) ...[
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatDuracao(apontamento.duracaoTotal!),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          
          // Timeline de eventos
          _buildTimelineEventos(apontamento.eventos, dfTime),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Dados do apontamento
          _buildDadosApontamento(apontamento),
        ],
      ),
    );
  }

  Widget _buildTimelineEventos(List<ApontamentoEvento> eventos, DateFormat dfTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline de Eventos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        ...eventos.asMap().entries.map((entry) {
          final index = entry.key;
          final evento = entry.value;
          final isLast = index == eventos.length - 1;
          
          return _buildTimelineItem(
            evento: evento,
            dfTime: dfTime,
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem({
    required ApontamentoEvento evento,
    required DateFormat dfTime,
    required bool isLast,
  }) {
    Color cor = Colors.grey;
    switch (evento.tipo) {
      case TipoEvento.iniciado:
        cor = Colors.green;
        break;
      case TipoEvento.pausado:
        cor = Colors.orange;
        break;
      case TipoEvento.encerrado:
        cor = Colors.blue;
        break;
      case TipoEvento.reaberto:
        cor = Colors.purple;
        break;
      case TipoEvento.alterado:
        cor = Colors.grey;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha vertical e círculo
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(
                  evento.iconeEvento,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Informações do evento
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      evento.nomeEvento,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: cor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dfTime.format(evento.dataHora),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (evento.responsavel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Por: ${evento.responsavel}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (evento.observacao != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    evento.observacao!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDadosApontamento(ApontamentoCompleto apontamento) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados do Apontamento',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildInfoRow('Quantidade:', '${apontamento.quantidadeProcessada} peles'),
        _buildInfoRow('Responsável:', apontamento.responsavel ?? 'Não informado'),
        
        if (apontamento.responsavelSuperior != null)
          _buildInfoRow('Supervisor:', apontamento.responsavelSuperior!),
        
        if (apontamento.fulao != null)
          _buildInfoRow('Fulão:', apontamento.fulao!),
        
        if (apontamento.observacao != null && apontamento.observacao!.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Observação:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            apontamento.observacao!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
        
        // Variáveis do processo
        if (apontamento.dadosFinais['variables'] != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Variáveis do Processo:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...(apontamento.dadosFinais['variables'] as Map<String, dynamic>)
              .entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '• ${entry.key}:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuracao(Duration duracao) {
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);
    
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else {
      return '${minutos}min';
    }
  }
}
