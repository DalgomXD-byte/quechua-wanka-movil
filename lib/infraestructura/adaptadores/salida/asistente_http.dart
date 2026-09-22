import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../dominio/entidades/entrada_historial.dart';
import '../../../dominio/entidades/fragmento_respaldo.dart';
import '../../../dominio/entidades/procedencia.dart';
import '../../../dominio/entidades/respuesta.dart';
import '../../../dominio/objetos_valor/idioma.dart';
import '../../../dominio/puertos/asistente_port.dart';
import '../../configuracion.dart';

/// Adaptador del puerto de consulta contra el servicio de escritorio.
///
/// Es la pieza que el incremento offline sustituira. Nada fuera de este archivo
/// sabe que hoy existe una red.
class AsistenteHttp implements AsistentePort {
  AsistenteHttp({String? urlBase, http.Client? cliente})
      : _url = (urlBase ?? Configuracion.urlApi).replaceAll(RegExp(r'/$'), ''),
        _cliente = cliente ?? http.Client();

  final String _url;
  final http.Client _cliente;

  @override
  Future<Respuesta> consultar(String texto) async {
    final respuesta = await _cliente
        .post(
          Uri.parse('$_url/api/consultas'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'texto': texto}),
        )
        .timeout(Configuracion.tiempoEspera);
    return _aRespuesta(_cuerpo(respuesta) as Map<String, dynamic>);
  }

  @override
  Future<List<EntradaHistorial>> historial({int limite = 20}) async {
    final respuesta = await _cliente
        .get(Uri.parse('$_url/api/historial?limite=$limite'))
        .timeout(Configuracion.tiempoEspera);
    final lista = _cuerpo(respuesta) as List<dynamic>;
    return lista
        .cast<Map<String, dynamic>>()
        .map(
          (e) => EntradaHistorial(
            consulta: e['consulta'] as String,
            respuesta: e['respuesta'] as String,
            abstenida: e['abstenida'] as bool,
            similitudMaxima: (e['similitud_maxima'] as num).toDouble(),
            momento: DateTime.parse(e['momento'] as String),
          ),
        )
        .toList();
  }

  @override
  Future<EstadoSistema> estado() async {
    final respuesta = await _cliente
        .get(Uri.parse('$_url/api/estado'))
        .timeout(const Duration(seconds: 10));
    final datos = _cuerpo(respuesta) as Map<String, dynamic>;
    return EstadoSistema(
      fragmentosIndexados: datos['fragmentos_indexados'] as int,
      umbralAbstencion: (datos['umbral_abstencion'] as num).toDouble(),
      disponible: datos['generador_disponible'] as bool? ?? true,
    );
  }

  Object _cuerpo(http.Response respuesta) {
    final texto = utf8.decode(respuesta.bodyBytes);
    if (respuesta.statusCode >= 400) {
      final detalle = texto.isEmpty ? null : jsonDecode(texto);
      throw ErrorConsulta(
        detalle is Map && detalle['detail'] != null
            ? detalle['detail'].toString()
            : 'El servicio respondio ${respuesta.statusCode}',
      );
    }
    return jsonDecode(texto) as Object;
  }

  Respuesta _aRespuesta(Map<String, dynamic> datos) => Respuesta(
        consultaId: datos['consulta_id'] as String,
        texto: datos['texto'] as String,
        abstenida: datos['abstenida'] as bool,
        idioma: Idioma.desdeCodigo(datos['idioma'] as String?),
        similitudMaxima: (datos['similitud_maxima'] as num?)?.toDouble() ?? 0.0,
        consultaTraducida: datos['consulta_traducida'] as String?,
        aviso: datos['aviso'] as String?,
        respaldo: ((datos['respaldo'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(
              (f) => FragmentoRespaldo(
                id: f['fragmento_id'] as String,
                texto: f['texto'] as String,
                procedencia: Procedencia(
                  documento: f['documento'] as String,
                  pagina: f['pagina'] as int,
                ),
                puntuacion: (f['puntuacion'] as num).toDouble(),
                coincidenciaLema: f['coincidencia_lema'] as bool? ?? false,
              ),
            )
            .toList(),
      );
}

/// Fallo que la interfaz puede mostrar al usuario tal cual.
class ErrorConsulta implements Exception {
  const ErrorConsulta(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
