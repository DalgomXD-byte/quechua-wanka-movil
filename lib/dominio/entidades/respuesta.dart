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
    this.pasajes = const [],
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

  /// Pasajes de prosa que podrian tratar la consulta, sin que el sistema lo afirme.
  ///
  /// La similitud lexica no distingue una pregunta de gramatica que el corpus cubre de
  /// una que no: basta cambiar el nombre de la lengua para que deje de estarlo sin que
  /// las palabras cambien. En lugar de simular una certeza que no existe, el material se
  /// entrega literal y citado para que lo juzgue quien consulta.
  final List<FragmentoRespaldo> pasajes;

  bool get tienePasajes => pasajes.isNotEmpty;
}
