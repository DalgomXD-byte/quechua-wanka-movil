import '../../../aplicacion/servicios/compositor_respuesta.dart';
import '../../../aplicacion/servicios/detector_idioma.dart';
import '../../../aplicacion/servicios/evaluador_confianza.dart';
import '../../../dominio/entidades/entrada_historial.dart';
import '../../../dominio/entidades/fragmento_respaldo.dart';
import '../../../dominio/entidades/respuesta.dart';
import '../../../dominio/objetos_valor/idioma.dart';
import '../../../dominio/puertos/asistente_port.dart';
import 'indice_portable.dart';
import 'traductor_tabla.dart';

const _avisoAlcance =
    'Esta es una consulta sobre fuentes documentales publicadas; no constituye una '
    'validación por hablantes de la comunidad.';

const _sinRespaldo = {
  Idioma.espanol:
      'No dispongo de respaldo documental para esa consulta en el corpus indexado. '
          'No propongo ninguna traducción, para evitar introducir una forma no documentada.',
  Idioma.ingles:
      'I have no documentary support for that query in the indexed corpus. I will not '
          'propose a translation, to avoid introducing an undocumented form.',
};

const _conPasajes = {
  Idioma.espanol:
      'No tengo una respuesta confirmada para esa consulta. Estos pasajes del corpus '
          'podrían tratarla; léelos y juzga tú.',
  Idioma.ingles:
      'I have no confirmed answer for that query. These passages from the corpus may '
          'deal with it; read them and judge for yourself.',
};

/// Resuelve la consulta en el propio dispositivo, sin red de ninguna clase.
///
/// Cumple el mismo puerto que el adaptador HTTP, de modo que sustituirlo no obliga a
/// tocar el dominio, los casos de uso ni una sola pantalla: es el cambio de una linea en
/// el contenedor. Nada sale del telefono, que es lo que exigen RF-12 y RNF-06 y lo que
/// sostiene el marco de soberania de datos del proyecto.
class AsistenteLocal implements AsistentePort {
  AsistenteLocal._(this._indice, this._traductor);

  final IndicePortable _indice;
  final TraductorTabla _traductor;

  static const _detector = DetectorIdioma();
  static const _evaluador = EvaluadorConfianza();
  static const _compositor = CompositorRespuesta();

  final List<EntradaHistorial> _historial = [];
  var _contador = 0;

  static Future<AsistenteLocal> cargar() async {
    final indice = await IndicePortable.cargar();
    final traductor = await TraductorTabla.cargar();
    return AsistenteLocal._(indice, traductor);
  }

  @override
  Future<EstadoSistema> estado() async => EstadoSistema(
        fragmentosIndexados: _indice.fragmentos.length,
        umbralAbstencion: _indice.umbralAbstencion,
        disponible: true,
      );

  @override
  Future<List<EntradaHistorial>> historial({int limite = 20}) async =>
      _historial.reversed.take(limite).toList();

  @override
  Future<Respuesta> consultar(String texto) async {
    final respuesta = _resolver(texto);
    _historial.add(
      EntradaHistorial(
        consulta: texto,
        respuesta: respuesta.texto,
        abstenida: respuesta.abstenida,
        similitudMaxima: respuesta.similitudMaxima,
        momento: DateTime.now(),
      ),
    );
    return respuesta;
  }

  Respuesta _resolver(String texto) {
    final id = '${DateTime.now().millisecondsSinceEpoch}-${_contador++}';
    var idioma = _detector.detectar(texto);
    final termino = _indice.depurador.depurar(texto);

    var candidatas = _traductor.candidatas(termino, aproximar: idioma == Idioma.ingles);
    // Una palabra inglesa suelta ("love") no trae ninguna marca funcional que contar, de
    // modo que el detector la asume espanola y nunca se traduciria. Si el termino no
    // encabeza ninguna entrada del corpus pero si figura en la tabla como palabra
    // inglesa, la evidencia lexica pesa mas que la heuristica.
    if (candidatas.isNotEmpty &&
        idioma == Idioma.espanol &&
        !candidatas.contains(termino) &&
        !_indice.esLema(termino)) {
      idioma = Idioma.ingles;
      candidatas = _traductor.candidatas(termino, aproximar: true);
    }

    final variantes = <String>[texto, ...candidatas.where((c) => c != texto)];
    final (recuperados, origen) = _recuperarConVariantes(variantes);

    if (!_evaluador.responder(recuperados)) {
      // Antes de abstenerse del todo se busca en la prosa, que se consulta aparte porque
      // las entradas de diccionario, mucho mas cortas, copan siempre las primeras
      // posiciones. Lo recuperado no se afirma: se entrega literal y citado.
      final pasajes = _evaluador.ofrecerPasajes(
        _indice.recuperarProsa(texto, k: 3),
        consulta: termino,
      );
      return Respuesta(
        consultaId: id,
        texto: (pasajes.isNotEmpty ? _conPasajes : _sinRespaldo)[idioma]!,
        abstenida: true,
        idioma: idioma,
        similitudMaxima: _evaluador.similitudMaxima(recuperados),
        pasajes: pasajes,
        aviso: _avisoAlcance,
      );
    }

    final mejor = recuperados.first;
    final buscado = origen[mejor.id] ?? texto;
    final terminoBuscado = _indice.depurador.depurar(buscado);
    final entrada = _compositor.extraer(mejor.texto, terminoBuscado);

    return Respuesta(
      consultaId: id,
      // Sin entrada que descomponer no se redacta nada: se entrega el fragmento literal.
      // Es el caso de un fragmento de prosa que supero el umbral, donde no hay una
      // correspondencia que reordenar y cualquier parafrasis seria invencion.
      texto: entrada == null
          ? mejor.texto
          : _compositor.componer(entrada, idioma, terminoBuscado),
      abstenida: false,
      idioma: idioma,
      similitudMaxima: _evaluador.similitudMaxima(recuperados),
      respaldo: recuperados,
      consultaTraducida: buscado == texto ? null : terminoBuscado,
      aviso: _avisoAlcance,
    );
  }

  /// Recupera con la consulta original y con cada lectura espanola plausible, conservando
  /// para cada fragmento la mejor puntuacion, y registrando con que variante se logro.
  (List<FragmentoRespaldo>, Map<String, String>) _recuperarConVariantes(
    List<String> variantes,
  ) {
    final mejores = <String, FragmentoRespaldo>{};
    final origen = <String, String>{};

    for (final variante in variantes) {
      for (final recuperado in _indice.recuperar(variante, k: 5)) {
        final previo = mejores[recuperado.id];
        if (previo == null || _orden(recuperado) > _orden(previo)) {
          mejores[recuperado.id] = recuperado;
          origen[recuperado.id] = variante;
        }
      }
    }

    final ordenados = mejores.values.toList()
      ..sort((a, b) => _orden(b).compareTo(_orden(a)));
    return (ordenados.take(5).toList(), origen);
  }

  /// La coincidencia de lema manda sobre la puntuacion.
  static double _orden(FragmentoRespaldo r) =>
      (r.coincidenciaLema ? 1.0 : 0.0) + r.puntuacion;
}
