import 'package:flutter/material.dart';

import 'infraestructura/contenedor.dart';
import 'presentacion/pantalla_consulta.dart';
import 'presentacion/tema.dart';

void main() {
  runApp(const AplicacionQuechuaWanka());
}

class AplicacionQuechuaWanka extends StatefulWidget {
  const AplicacionQuechuaWanka({super.key});

  @override
  State<AplicacionQuechuaWanka> createState() => _AplicacionQuechuaWankaState();
}

class _AplicacionQuechuaWankaState extends State<AplicacionQuechuaWanka> {
  /// El indice son 12 MB que hay que leer y estructurar una sola vez al arrancar. Se hace
  /// aqui, y no en cada consulta, para que consultar sea inmediato.
  late final Future<Contenedor> _contenedor = Contenedor.cargar();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quechua wanka',
      debugShowCheckedModeBanner: false,
      theme: Tema.claro(),
      darkTheme: Tema.oscuro(),
      home: FutureBuilder<Contenedor>(
        future: _contenedor,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _Arranque(mensaje: 'No se pudo abrir el corpus.\n${snapshot.error}');
          }
          final contenedor = snapshot.data;
          if (contenedor == null) {
            return const _Arranque(mensaje: 'Abriendo el corpus…');
          }
          return PantallaConsulta(asistente: contenedor.asistente);
        },
      ),
    );
  }
}

/// Pantalla de los pocos instantes que tarda el indice en quedar disponible.
class _Arranque extends StatelessWidget {
  const _Arranque({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Quechua wanka', style: tema.textTheme.titleLarge),
              const SizedBox(height: 14),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
