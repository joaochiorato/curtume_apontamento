import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ordem_producao.dart';
import '../../providers/ordem_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/responsavel_dropdown.dart';
import '../../widgets/quantidade_input.dart';

/// 🏭 Tela de apontamento de estágio
class StageScreen extends StatefulWidget {
  final String ordemId;
  final String estagioId;

  const StageScreen({
    super.key,
    required this.ordemId,
    required this.estagioId,
  });

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  String? _responsavel;
  String? _responsavelSuperior;
  int _quantidadeProcessada = 0;
  final Map<String, dynamic> _dadosAdicionais = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Apontamento'),
      ),
      body: Consumer<OrdemProducaoProvider>(
        builder: (context, provider, child) {
          final ordem = provider.buscarOrdemPorId(widget.ordemId);
          if (ordem == null) {
            return const Center(child: Text('Ordem não encontrada'));
          }

          final estagio = ordem.estagios.firstWhere((e) => e.id == widget.estagioId);
          final restante = estagio.quantidadeTotal - estagio.quantidadeProcessada;

          return Column(
            children: [
              // Header com informações da OF
              _buildHeader(context, ordem, estagio, restante),

              // Conteúdo com scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seleção de Fulão/Máquina (se aplicável)
                      if (_precisaMaquina(estagio))
                        _buildMaquinaSelector(context, estagio),

                      // Campo de Químicos (exemplo)
                      if (estagio.id == 'remolho')
                        _buildQuimicosButton(context),

                      const SizedBox(height: 20),

                      // Responsável
                      ResponsavelDropdown(
                        label: 'Responsável',
                        value: _responsavel,
                        onChanged: (value) {
                          setState(() => _responsavel = value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Responsável Superior
                      ResponsavelDropdown(
                        label: 'Responsável Superior',
                        value: _responsavelSuperior,
                        onChanged: (value) {
                          setState(() => _responsavelSuperior = value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Quantidade Processada
                      QuantidadeInput(
                        label: 'Quantidade Processada*',
                        unidade: 'peles',
                        maximo: restante,
                        onChanged: (value) {
                          setState(() => _quantidadeProcessada = value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Variáveis do Processo
                      if (estagio.variaveisControle.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 20),
                        Text(
                          'Variáveis do Processo',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...estagio.variaveisControle.map((variavel) {
                          return _buildVariavelControl(context, variavel);
                        }).toList(),
                      ],

                      const SizedBox(height: 100), // Espaço para os botões fixos
                    ],
                  ),
                ),
              ),

              // Botões fixos no rodapé
              _buildFooterButtons(context, provider, ordem, estagio, restante),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OrdemProducao ordem, Estagio estagio, int restante) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            estagio.nome,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip('Total da OF:', '${estagio.quantidadeTotal} peles'),
              _buildInfoChip('Já processado:', '${estagio.quantidadeProcessada} peles', 
                  color: AppTheme.statusFinalizado),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'RESTANTE: $restante peles',
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  bool _precisaMaquina(Estagio estagio) {
    return ['remolho', 'enxugadeira', 'divisora', 'rebaixadeira'].contains(estagio.id);
  }

  Widget _buildMaquinaSelector(BuildContext context, Estagio estagio) {
    final opcoes = _getOpcoesMaquina(estagio);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLabelMaquina(estagio),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            hintText: '— selecione —',
          ),
          items: opcoes.map((opcao) {
            return DropdownMenuItem(
              value: opcao,
              child: Text(opcao),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _dadosAdicionais[_getKeyMaquina(estagio)] = value;
            });
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _getLabelMaquina(Estagio estagio) {
    if (estagio.id == 'remolho') return 'Fulão';
    return 'Máquina';
  }

  String _getKeyMaquina(Estagio estagio) {
    if (estagio.id == 'remolho') return 'fulao';
    return 'maquina';
  }

  List<String> _getOpcoesMaquina(Estagio estagio) {
    switch (estagio.id) {
      case 'remolho':
        return ['1', '2', '3', '4'];
      case 'enxugadeira':
      case 'divisora':
        return ['1', '2'];
      case 'rebaixadeira':
        return ['1', '2', '3', '4', '5', '6'];
      default:
        return [];
    }
  }

  Widget _buildQuimicosButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Abrir tela de químicos
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Função de químicos em desenvolvimento')),
          );
        },
        icon: const Icon(Icons.science),
        label: const Text('Químicos (0)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accentColor,
          side: const BorderSide(color: AppTheme.accentColor),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Widget _buildVariavelControl(BuildContext context, VariavelControle variavel) {
    final controller = _controllers.putIfAbsent(
      variavel.nome,
      () => TextEditingController(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  variavel.nome,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (variavel.padrao != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Padrão: ${variavel.padrao}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Digite o valor',
              suffixText: variavel.unidade,
            ),
            onChanged: (value) {
              final numericValue = double.tryParse(value);
              variavel.resultado = numericValue;
            },
          ),
          if (variavel.valorMinimo != null || variavel.valorMaximo != null) ...[
            const SizedBox(height: 4),
            Text(
              'Limite: ${variavel.valorMinimo ?? '-'} a ${variavel.valorMaximo ?? '-'} ${variavel.unidade}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHint,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterButtons(
    BuildContext context,
    OrdemProducaoProvider provider,
    OrdemProducao ordem,
    Estagio estagio,
    int restante,
  ) {
    final bool podeIniciar = !estagio.isIniciado && _responsavel != null;
    final bool podeSalvar = estagio.isIniciado && _quantidadeProcessada > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão Cancelar
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),

          // Botão Salvar/Iniciar/Encerrar
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _buildActionButton(
                context,
                provider,
                ordem,
                estagio,
                restante,
                podeIniciar,
                podeSalvar,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: AppTheme.accentColor,
              ),
              child: Text(_getButtonLabel(estagio, podeIniciar, podeSalvar)),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonLabel(Estagio estagio, bool podeIniciar, bool podeSalvar) {
    if (!estagio.isIniciado && podeIniciar) {
      return 'Iniciar';
    } else if (estagio.isIniciado && !estagio.isConcluido) {
      return 'Salvar Apontamento';
    }
    return 'Salvar Apontamento';
  }

  VoidCallback? _buildActionButton(
    BuildContext context,
    OrdemProducaoProvider provider,
    OrdemProducao ordem,
    Estagio estagio,
    int restante,
    bool podeIniciar,
    bool podeSalvar,
  ) {
    // Se ainda não iniciou
    if (!estagio.isIniciado) {
      if (!podeIniciar) return null;
      
      return () {
        provider.iniciarApontamento(
          widget.ordemId,
          widget.estagioId,
          responsavel: _responsavel!,
          responsavelSuperior: _responsavelSuperior,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apontamento iniciado com sucesso')),
        );
      };
    }

    // Se já iniciou, mas não pode salvar
    if (!podeSalvar) return null;

    // Pode salvar apontamento
    return () {
      // Atualiza dados adicionais
      if (_dadosAdicionais.isNotEmpty) {
        provider.atualizarDadosAdicionais(
          widget.ordemId,
          widget.estagioId,
          _dadosAdicionais,
        );
      }

      // Processa quantidade
      provider.processarQuantidade(
        widget.ordemId,
        widget.estagioId,
        _quantidadeProcessada,
      );

      // Se processou tudo, finaliza o estágio
      if (restante - _quantidadeProcessada <= 0) {
        provider.finalizarEstagio(widget.ordemId, widget.estagioId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restante - _quantidadeProcessada <= 0
                ? 'Estágio finalizado com sucesso'
                : 'Apontamento salvo com sucesso',
          ),
        ),
      );

      Navigator.pop(context);
    };
  }
}
