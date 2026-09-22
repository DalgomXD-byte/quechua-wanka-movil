import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Direccion del servicio de consulta.
///
/// Se resuelve por plataforma porque el emulador de Android no alcanza el
/// 127.0.0.1 del anfitrion: lo expone en 10.0.2.2. Para un telefono fisico hay que
/// pasar la direccion de la red local al compilar:
///   flutter run --dart-define=API_URL=http://192.168.1.50:8000
class Configuracion {
  static const String _definida = String.fromEnvironment('API_URL');

  static String get urlApi {
    if (_definida.isNotEmpty) return _definida;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  static const Duration tiempoEspera = Duration(seconds: 90);
}
