import '../dominio/puertos/asistente_port.dart';
import 'adaptadores/salida/asistente_local.dart';

/// Unico lugar donde se decide con que tecnologia se cumple cada puerto.
///
/// Aqui estaba, hasta el incremento offline, `AsistenteHttp()`, que resolvia la consulta
/// contra el servicio de escritorio. Cambiar esa linea por `AsistenteLocal.cargar()` es
/// todo lo que hizo falta para que la aplicacion deje de necesitar red: ni el dominio, ni
/// los casos de uso, ni una sola pantalla se tocaron. El adaptador HTTP sigue en el
/// proyecto y sigue siendo valido, por si conviene volver a apuntar al escritorio para
/// comparar comportamientos.
class Contenedor {
  const Contenedor._(this.asistente);

  final AsistentePort asistente;

  static Future<Contenedor> cargar() async =>
      Contenedor._(await AsistenteLocal.cargar());
}
