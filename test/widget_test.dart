import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quechua_wanka/dominio/entidades/entrada_historial.dart';
import 'package:quechua_wanka/dominio/entidades/fragmento_respaldo.dart';
import 'package:quechua_wanka/dominio/entidades/procedencia.dart';
import 'package:quechua_wanka/dominio/entidades/respuesta.dart';
import 'package:quechua_wanka/dominio/objetos_valor/idioma.dart';
import 'package:quechua_wanka/dominio/puertos/asistente_port.dart';
import 'package:quechua_wanka/presentacion/pantalla_consulta.dart';
import 'package:quechua_wanka/presentacion/tema.dart';

/// Doble del puerto: la pantalla se prueba sin red, que es precisamente lo que
/// la arquitectura hexagonal permite.
class AsistenteFalso implements AsistentePort {
  AsistenteFalso({required this.respuesta});

  final Respuesta respuesta;
  final List<String> consultadas = [];

  @override
  Future<Respuesta> consultar(String texto) async {
    consultadas.add(texto);
    return respuesta;
  }

  @override
  Future<List<EntradaHistorial>> historial({int limite = 20}) async => [
        EntradaHistorial(
          consulta: 'como se dice agua',
          respuesta: 'yaku',
          abstenida: false,
          similitudMaxima: 0.62,
          momento: DateTime(2026, 9, 22),
        ),
      ];

  @override
  Future<EstadoSistema> estado() async => const EstadoSistema(
        fragmentosIndexados: 3605,
        umbralAbstencion: 0.48,
        disponible: true,
      );
}

Respuesta _respaldada() => const Respuesta(
      consultaId: 'x',
      texto: 'Se registran las formas Allqu y ashuti.',
      abstenida: false,
      idioma: Idioma.espanol,
      similitudMaxima: 0.27,
      respaldo: [
        FragmentoRespaldo(
          id: 'f1',
          texto: 'PERRO: Allqu, ashuti.',
          procedencia: Procedencia(
            documento: '293274822-diccionario-quechua-Wanka-docx.pdf',
            pagina: 27,
          ),
          puntuacion: 0.27,
          coincidenciaLema: true,
        ),
      ],
    );

Future<void> _montar(WidgetTester tester, AsistentePort asistente) async {
  await tester.pumpWidget(MaterialApp(
    theme: Tema.claro(),
    home: PantallaConsulta(asistente: asistente),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el numero de fragmentos indexados al arrancar',
      (tester) async {
    await _montar(tester, AsistenteFalso(respuesta: _respaldada()));
    expect(find.textContaining('3605 fragmentos'), findsOneWidget);
  });

  testWidgets('una consulta muestra la respuesta y su respaldo con pagina',
      (tester) async {
    final asistente = AsistenteFalso(respuesta: _respaldada());
    await _montar(tester, asistente);

    await tester.enterText(find.byType(TextField), 'como se dice perro');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(asistente.consultadas, ['como se dice perro']);
    expect(find.text('Se registran las formas Allqu y ashuti.'), findsOneWidget);

    // El respaldo llega plegado: la cita aparece solo al desplegarlo.
    expect(find.textContaining('p. 27'), findsNothing);
    await tester.tap(find.textContaining('RESPALDO'));
    await tester.pumpAndSettle();
    expect(find.textContaining('p. 27'), findsOneWidget);
  });

  testWidgets('la abstencion se muestra como resultado, no como error',
      (tester) async {
    await _montar(
      tester,
      AsistenteFalso(
        respuesta: const Respuesta(
          consultaId: 'y',
          texto: 'No dispongo de respaldo documental para esa consulta.',
          abstenida: true,
          idioma: Idioma.espanol,
          similitudMaxima: 0.19,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'capital de francia');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('sin respaldo documental'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsNothing);
  });

  testWidgets('tocar una consulta reciente la repite', (tester) async {
    final asistente = AsistenteFalso(respuesta: _respaldada());
    await _montar(tester, asistente);

    await tester.tap(find.text('como se dice agua'));
    await tester.pumpAndSettle();

    expect(asistente.consultadas, ['como se dice agua']);
  });
}
