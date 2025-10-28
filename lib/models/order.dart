class ArtigoModel {
  final String name;
  final String po;
  final String cor;
  final String classe;
  ArtigoModel({required this.name, required this.po, required this.cor, required this.classe});
  factory ArtigoModel.fromJson(Map<String, dynamic> j) => ArtigoModel(name: j['name'], po: j['po'], cor: j['cor'], classe: j['classe']);
}
class OrdemModel {
  final String of;
  final List<ArtigoModel> artigos;
  OrdemModel({required this.of, required this.artigos});
  factory OrdemModel.fromJson(Map<String, dynamic> j) => OrdemModel(of: j['of'], artigos: (j['artigos'] as List).map((e)=>ArtigoModel.fromJson(e)).toList());
}
