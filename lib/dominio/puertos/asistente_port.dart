import '../entidades/entrada_historial.dart';
import '../entidades/respuesta.dart';

/// Puerto de consulta al corpus.
///
/// El unico contrato que la interfaz conoce. En el incremento actual lo cumple un
/// adaptador HTTP contra el servicio de escritorio; en el incremento offline lo
/// cumplira un adaptador que resuelve la consulta en el propio dispositivo, sin
/// que esta interfaz ni el resto de la aplicacion cambien.
abstract interface class AsistentePort {
  Future<Respuesta> consultar(String texto);

  Future<List<EntradaHistorial>> historial({int limite});

  Future<EstadoSistema> estado();
}

/// Estado del motor de consulta, para poder decir al usuario que ocurre.
class EstadoSistema {
  const EstadoSistema({
    required this.fragmentosIndexados,
    required this.umbralAbstencion,
    required this.disponible,
  });

  final int fragmentosIndexados;
  final double umbralAbstencion;
  final bool disponible;
}
