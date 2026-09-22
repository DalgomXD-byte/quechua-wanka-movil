import '../objetos_valor/idioma.dart';
import 'fragmento_respaldo.dart';

/// Resultado de una consulta al corpus.
///
/// Una respuesta abstenida no es un fallo: es la garantia de que el sistema no
/// propone formas en quechua que no esten documentadas.
class Respuesta {
  const Respuesta({
    required this.consultaId,
    required this.texto,
    required this.abstenida,
    required this.idioma,
    this.similitudMaxima = 0.0,
    this.respaldo = const [],
    this.consultaTraducida,
    this.aviso,
  });

  final String consultaId;
  final String texto;
  final bool abstenida;
  final Idioma idioma;
  final double similitudMaxima;
  final List<FragmentoRespaldo> respaldo;

  /// Termino en espanol con el que se busco, cuando la consulta venia en ingles.
  /// Se muestra al usuario porque explica por que se recupero lo que se recupero.
  final String? consultaTraducida;
  final String? aviso;
}
