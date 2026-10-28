const cidades = ['São Paulo', 'Campinas', 'Jundiaí'];
const categorias = [
  'Academia',
  'Café',
  'Restaurante',
  'Parque',
  'Cultura',
  'Hospital',
];

class Local {
  final String id, nome, categoria, cidade, horario, descricao, endereco;
  final double avaliacao, distancia, mapaX, mapaY;
  final bool favorito;
  final int avaliacoes;
  const Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    this.favorito = false,
    this.avaliacoes = 0,
    this.endereco = '',
    this.mapaX = .5,
    this.mapaY = .5,
  });
  factory Local.fromMap(String id, Map<String, dynamic> data) => Local(
    id: id,
    nome: data['nome'] as String? ?? '',
    categoria: data['categoria'] as String? ?? 'Café',
    cidade: data['cidade'] as String? ?? cidades.first,
    avaliacao: (data['avaliacao'] as num? ?? 0).toDouble(),
    distancia: (data['distancia'] as num? ?? 0).toDouble(),
    horario: data['horario'] as String? ?? '',
    descricao: data['descricao'] as String? ?? '',
    endereco: data['endereco'] as String? ?? '',
    favorito: data['favorito'] as bool? ?? false,
    avaliacoes: (data['avaliacoes'] as num? ?? 0).toInt(),
    mapaX: (data['mapaX'] as num? ?? .5).toDouble().clamp(.08, .92),
    mapaY: (data['mapaY'] as num? ?? .5).toDouble().clamp(.12, .85),
  );
  Map<String, dynamic> toMap() => {
    'nome': nome,
    'categoria': categoria,
    'cidade': cidade,
    'avaliacao': avaliacao,
    'distancia': distancia,
    'horario': horario,
    'descricao': descricao,
    'favorito': favorito,
    'avaliacoes': avaliacoes,
    'endereco': endereco,
    'mapaX': mapaX,
    'mapaY': mapaY,
  };
  Local copyWith({String? id, bool? favorito}) =>
      Local.fromMap(id ?? this.id, {...toMap(), 'favorito': ?favorito});
}

String normalizar(String valor) {
  var resultado = valor.toLowerCase().trim();
  const origem = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const destino = 'aaaaaeeeeiiiiooooouuuuc';
  for (var i = 0; i < origem.length; i++) {
    resultado = resultado.replaceAll(origem[i], destino[i]);
  }
  return resultado;
}

enum Ordenacao { proximidade, avaliacao, nome }

List<Local> filtrarLocais(
  List<Local> locais, {
  String pesquisa = '',
  String cidade = 'Todas',
  String categoria = 'Todos',
  bool favoritos = false,
  Ordenacao ordem = Ordenacao.proximidade,
}) {
  final termo = normalizar(pesquisa);
  final resultado = locais
      .where(
        (local) =>
            (cidade == 'Todas' || local.cidade == cidade) &&
            (categoria == 'Todos' || local.categoria == categoria) &&
            (!favoritos || local.favorito) &&
            (normalizar(local.nome).contains(termo) ||
                normalizar(local.categoria).contains(termo)),
      )
      .toList();
  resultado.sort(
    (a, b) => switch (ordem) {
      Ordenacao.proximidade => a.distancia.compareTo(b.distancia),
      Ordenacao.avaliacao => b.avaliacao.compareTo(a.avaliacao),
      Ordenacao.nome => normalizar(a.nome).compareTo(normalizar(b.nome)),
    },
  );
  return resultado;
}
