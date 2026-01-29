import 'order.dart';
import 'stage.dart';

/// Representa um item de apontamento (Ordem + Artigo + Estágio)
/// para exibição na lista unificada
class ApontamentoItem {
  final OrdemModel ordem;
  final ArtigoModel artigo;
  final StageModel estagio;

  ApontamentoItem({
    required this.ordem,
    required this.artigo,
    required this.estagio,
  });

  /// Identificador único do item (para controle de estado)
  String get id => '${ordem.Doc}_${artigo.codigo}_${estagio.code}';
}
