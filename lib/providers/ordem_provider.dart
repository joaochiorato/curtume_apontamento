import 'package:flutter/foundation.dart';
import '../models/ordem_producao.dart';
import '../repositories/ordem_repository.dart';

/// 🎯 Provider para gerenciar estado das Ordens de Produção
class OrdemProducaoProvider extends ChangeNotifier {
  final OrdemProducaoRepository _repository = OrdemProducaoRepository();
  
  List<OrdemProducao> _ordens = [];
  bool _isLoading = false;

  List<OrdemProducao> get ordens => _ordens;
  bool get isLoading => _isLoading;

  OrdemProducaoProvider() {
    carregarOrdens();
  }

  /// Carrega todas as ordens
  Future<void> carregarOrdens() async {
    _isLoading = true;
    notifyListeners();

    // Simula delay de carregamento
    await Future.delayed(const Duration(milliseconds: 500));
    
    _repository.inicializarDados();
    _ordens = _repository.listarOrdens();
    
    _isLoading = false;
    notifyListeners();
  }

  /// Busca ordem por ID
  OrdemProducao? buscarOrdemPorId(String id) {
    return _repository.buscarPorId(id);
  }

  /// Inicia um apontamento no estágio
  void iniciarApontamento(String ordemId, String estagioId, {
    required String responsavel,
    String? responsavelSuperior,
  }) {
    final ordem = _repository.buscarPorId(ordemId);
    if (ordem == null) return;

    final estagio = ordem.estagios.firstWhere((e) => e.id == estagioId);
    
    final estagioAtualizado = estagio.copyWith(
      dataInicio: DateTime.now(),
      responsavel: responsavel,
      responsavelSuperior: responsavelSuperior,
    );

    _repository.atualizarEstagio(ordemId, estagioAtualizado);
    
    // Atualiza status da ordem para Em Produção
    if (ordem.status == StatusOrdem.aguardando) {
      _repository.atualizarOrdem(ordem.copyWith(status: StatusOrdem.emProducao));
    }

    _atualizarListaLocal();
  }

  /// Registra processamento no estágio
  void processarQuantidade(
    String ordemId, 
    String estagioId, 
    int quantidade,
    {Map<String, dynamic>? dadosAdicionais}
  ) {
    final ordem = _repository.buscarPorId(ordemId);
    if (ordem == null) return;

    final estagio = ordem.estagios.firstWhere((e) => e.id == estagioId);
    
    final novaQuantidade = (estagio.quantidadeProcessada + quantidade)
        .clamp(0, estagio.quantidadeTotal);

    final estagioAtualizado = estagio.copyWith(
      quantidadeProcessada: novaQuantidade,
      dadosAdicionais: {
        ...estagio.dadosAdicionais,
        if (dadosAdicionais != null) ...dadosAdicionais,
      },
    );

    _repository.atualizarEstagio(ordemId, estagioAtualizado);
    _atualizarListaLocal();
  }

  /// Finaliza um estágio
  void finalizarEstagio(String ordemId, String estagioId) {
    final ordem = _repository.buscarPorId(ordemId);
    if (ordem == null) return;

    final estagio = ordem.estagios.firstWhere((e) => e.id == estagioId);
    
    final estagioAtualizado = estagio.copyWith(
      dataTermino: DateTime.now(),
      quantidadeProcessada: estagio.quantidadeTotal,
    );

    _repository.atualizarEstagio(ordemId, estagioAtualizado);
    
    // Verifica se todos os estágios foram concluídos
    final ordemAtualizada = _repository.buscarPorId(ordemId);
    if (ordemAtualizada != null && ordemAtualizada.isCompleta) {
      _repository.atualizarOrdem(
        ordemAtualizada.copyWith(status: StatusOrdem.finalizado)
      );
    }

    _atualizarListaLocal();
  }

  /// Pausa um apontamento
  void pausarApontamento(String ordemId, String estagioId) {
    // Implementar lógica de pausa se necessário
    notifyListeners();
  }

  /// Cancela um apontamento
  void cancelarApontamento(String ordemId, String estagioId) {
    final ordem = _repository.buscarPorId(ordemId);
    if (ordem == null) return;

    final estagio = ordem.estagios.firstWhere((e) => e.id == estagioId);
    
    final estagioAtualizado = estagio.copyWith(
      dataInicio: null,
      dataTermino: null,
      quantidadeProcessada: 0,
      responsavel: null,
      responsavelSuperior: null,
    );

    _repository.atualizarEstagio(ordemId, estagioAtualizado);
    _atualizarListaLocal();
  }

  /// Atualiza variável de controle
  void atualizarVariavelControle(
    String ordemId,
    String estagioId,
    String nomeVariavel,
    dynamic valor,
  ) {
    final ordem = _repository.buscarPorId(ordemId);
    if (ordem == null) return;

    final estagio = ordem.estagios.firstWhere((e) => e.id == estagioId);
    final variaveisAtualizadas = List<VariavelControle>.from(estagio.variaveisControle);
    
    final index = variaveisAtualizadas.indexWhere((v) => v.nome == nomeVariavel);
    if (index != -1) {
      variaveisAtualizadas[index] = variaveisAtualizadas[index].copyWith(
        resultado: valor,
      );

      final estagioAtualizado = estagio.copyWith(
        variaveisControle: variaveisAtualizadas,
      );

      _repository.atualizarEstagio(ordemId, estagioAtualizado);
      _atualizarListaLocal();
    }
  }

  /// Atualiza dados adicionais do estágio
  void atualizarDadosAdicionais(
    String ordemId,
    String estagioId,
    Map<String, dynamic> dados,
  ) {
    final ordem = _repository.buscarPorId(ordemId);
    if (ordem == null) return;

    final estagio = ordem.estagios.firstWhere((e) => e.id == estagioId);
    
    final estagioAtualizado = estagio.copyWith(
      dadosAdicionais: {
        ...estagio.dadosAdicionais,
        ...dados,
      },
    );

    _repository.atualizarEstagio(ordemId, estagioAtualizado);
    _atualizarListaLocal();
  }

  /// Atualiza lista local de ordens
  void _atualizarListaLocal() {
    _ordens = _repository.listarOrdens();
    notifyListeners();
  }

  /// Cancela uma ordem completa
  void cancelarOrdem(String ordemId) {
    final ordem = _repository.buscarPorId(ordemId);
    if (ordem != null) {
      _repository.atualizarOrdem(
        ordem.copyWith(status: StatusOrdem.cancelado)
      );
      _atualizarListaLocal();
    }
  }
}
