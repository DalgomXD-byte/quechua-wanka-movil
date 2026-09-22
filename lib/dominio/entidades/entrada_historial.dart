/// Consulta ya resuelta, tal como se guarda para poder volver a ella.
class EntradaHistorial {
  const EntradaHistorial({
    required this.consulta,
    required this.respuesta,
    required this.abstenida,
    required this.similitudMaxima,
    required this.momento,
  });

  final String consulta;
  final String respuesta;
  final bool abstenida;
  final double similitudMaxima;
  final DateTime momento;
}
