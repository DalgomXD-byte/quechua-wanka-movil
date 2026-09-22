import '../dominio/puertos/asistente_port.dart';
import 'adaptadores/salida/asistente_http.dart';

/// Unico lugar donde se decide con que tecnologia se cumple cada puerto.
///
/// El incremento offline cambia esta linea y nada mas: ni el dominio, ni la
/// interfaz, ni las pantallas conocen al adaptador que hay detras.
class Contenedor {
  Contenedor() : asistente = AsistenteHttp();

  final AsistentePort asistente;
}
