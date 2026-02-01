/// Modelo de Filial
class FilialModel {
  final String codigo;
  final String nome;

  const FilialModel({
    required this.codigo,
    required this.nome,
  });

  String get displayName => '$codigo - $nome';
}

/// Modelo de Posto de Trabalho
class PostoTrabalhoModel {
  final String codigo;
  final String nome;

  const PostoTrabalhoModel({
    required this.codigo,
    required this.nome,
  });

  String get displayName => '$codigo - $nome';
}

/// Lista de filiais disponíveis
const List<FilialModel> filiaisDisponiveis = [
  FilialModel(codigo: '120', nome: 'ATAK Sistemas'),
  FilialModel(codigo: '121', nome: 'Filial Norte'),
  FilialModel(codigo: '122', nome: 'Filial Sul'),
];

/// Lista de postos de trabalho disponíveis
/// (Sincronizado com os estágios em stage.dart)
const List<PostoTrabalhoModel> postosTrabalhoDisponiveis = [
  PostoTrabalhoModel(codigo: 'REM', nome: 'REMOLHO'),
  PostoTrabalhoModel(codigo: 'ENX', nome: 'ENXUGADEIRA'),
  PostoTrabalhoModel(codigo: 'DIV', nome: 'DIVISORA'),
  PostoTrabalhoModel(codigo: 'REB', nome: 'REBAIXADEIRA'),
  PostoTrabalhoModel(codigo: 'REF', nome: 'REFILA'),
];
