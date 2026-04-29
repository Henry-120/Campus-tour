class CamaraLevel {
  CamaraLevel({required this.recognitionFunction});

  final bool Function(String value) recognitionFunction;
}
