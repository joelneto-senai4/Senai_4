String? obrigatorio(String? valor) =>
    valor == null || valor.trim().isEmpty ? 'Preencha este campo.' : null;
double? numero(String? valor) =>
    double.tryParse((valor ?? '').trim().replaceAll(',', '.'));
String? validarAvaliacao(String? valor) {
  final n = numero(valor);
  return n == null || !n.isFinite || n < 0 || n > 5
      ? 'Use um número de 0 a 5.'
      : null;
}

String? validarDistancia(String? valor) {
  final n = numero(valor);
  return n == null || !n.isFinite || n < 0
      ? 'Informe uma distância válida, a partir de 0.'
      : null;
}
