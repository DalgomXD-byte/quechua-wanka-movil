import 'package:flutter/material.dart';

import 'infraestructura/contenedor.dart';
import 'presentacion/pantalla_consulta.dart';
import 'presentacion/tema.dart';

void main() {
  runApp(AplicacionQuechuaWanka(contenedor: Contenedor()));
}

class AplicacionQuechuaWanka extends StatelessWidget {
  const AplicacionQuechuaWanka({super.key, required this.contenedor});

  final Contenedor contenedor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quechua wanka',
      debugShowCheckedModeBanner: false,
      theme: Tema.claro(),
      darkTheme: Tema.oscuro(),
      home: PantallaConsulta(asistente: contenedor.asistente),
    );
  }
}
