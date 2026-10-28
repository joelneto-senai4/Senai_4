import '../models/local.dart';

// Estabelecimentos, avaliações e distâncias fictícios para a atividade escolar.
List<Local> legacyDemoLocais() {
  const nomes = [
    [
      'Café Botânico',
      'Academia Movimento',
      'Mesa da Vila',
      'Parque do Horizonte',
      'Casa das Histórias',
    ],
    [
      'Café do Largo',
      'Academia Essência',
      'Quintal da Mesa',
      'Parque das Águas',
      'Espaço da Palavra',
    ],
    [
      'Café da Serra',
      'Academia Ritmo',
      'Cozinha do Jardim',
      'Parque dos Ipês',
      'Ateliê da Cidade',
    ],
  ];
  const tipos = ['Café', 'Academia', 'Restaurante', 'Parque', 'Cultura'];
  const descricoes = [
    'Uma pausa boa no meio da cidade. Cafés especiais, pães artesanais e um ambiente cheio de plantas para conversar, ler ou trabalhar com calma.',
    'Movimente o dia no seu ritmo. Espaço de musculação e treinamento funcional com orientação profissional e aulas em pequenos grupos.',
    'Comida feita com tempo e ingredientes da estação. Um espaço acolhedor para reunir amigos e descobrir os sabores da cozinha brasileira.',
    'Um respiro ao ar livre. Caminhos arborizados, jardins e áreas de descanso convidam a caminhar, fazer um piquenique e aproveitar a paisagem.',
    'Um encontro com novas ideias. Livros, exposições e oficinas em um espaço dedicado à arte e à cultura, com programação para todas as idades.',
  ];
  const horarios = [
    '08:00 - 19:00',
    '06:00 - 22:00',
    '11:30 - 22:00',
    '06:00 - 18:00',
    '09:00 - 18:00',
  ];
  const xs = [.29, .73, .58, .22, .78];
  const ys = [.26, .30, .51, .67, .75];
  return [
    for (var c = 0; c < cidades.length; c++)
      for (var i = 0; i < tipos.length; i++)
        Local(
          id: 'demo-$c-$i',
          nome: nomes[c][i],
          categoria: tipos[i],
          cidade: cidades[c],
          avaliacao: [4.8, 4.6, 4.9, 4.7, 4.5][i],
          distancia: [.4, 1.2, 1.6, 2.1, 2.8][i],
          horario: horarios[i],
          descricao: descricoes[i],
          endereco: 'Rua das Flores, ${120 + i * 84} · ${cidades[c]}',
          mapaX: xs[i],
          mapaY: ys[i],
        ),
  ];
}

// Os cinco primeiros registros reproduzem os exemplos da referência visual.
List<Local> demoLocais() {
  const nomes = [
    'Academia Fitness',
    'Smart Fit',
    'Body Center',
    'Proforma Academia',
    'Iron Gym',
  ];
  const notas = [4.8, 4.5, 4.3, 4.0, 4.2];
  const distancias = [1.2, 2.4, 3.1, 4.7, 5.2];
  const xs = [.18, .82, .18, .73, .39];
  const ys = [.14, .11, .46, .48, .70];
  final antigos = legacyDemoLocais();
  return [
    for (var i = 0; i < 5; i++)
      Local(
        id: 'demo-0-$i',
        nome: nomes[i],
        categoria: 'Academia',
        cidade: 'São Paulo',
        avaliacao: notas[i],
        distancia: distancias[i],
        horario: '06:00 - 22:00',
        avaliacoes: [124, 98, 76, 64, 52][i],
        descricao: i == 0
            ? 'Academia completa com musculação, funcional, aulas coletivas e personal trainer.\nAmbiente moderno e bem equipado.'
            : 'Musculação, treinamento funcional e aulas coletivas para cuidar da sua saúde com acompanhamento profissional.',
        endereco: 'Rua das Flores, ${120 + i * 84} · São Paulo',
        mapaX: xs[i],
        mapaY: ys[i],
      ),
    ...antigos.where((l) => l.cidade != 'São Paulo'),
  ];
}

List<Local> atualizarExemplosIntactos(List<Local> locais) {
  final antigos = {for (final local in legacyDemoLocais()) local.id: local};
  final novos = {for (final local in demoLocais()) local.id: local};
  return locais.map((local) {
    final antigo = antigos[local.id];
    final novo = novos[local.id];
    if (antigo == null || novo == null) return local;
    final original = antigo.toMap()..remove('favorito');
    final atual = local.toMap()..remove('favorito');
    // Não substitui cadastro, edição, exclusão nem estado de favorito do usuário.
    if (!original.keys.every((key) => original[key] == atual[key])) {
      return local;
    }
    return novo.copyWith(favorito: local.favorito);
  }).toList();
}
