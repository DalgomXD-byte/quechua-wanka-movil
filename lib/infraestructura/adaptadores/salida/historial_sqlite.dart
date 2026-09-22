import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../dominio/entidades/entrada_historial.dart';

/// Historial de consultas en SQLite, dentro del dispositivo.
///
/// Es la contrapartida movil del PostgreSQL del escritorio, y la misma entidad de dominio
/// sirve para las dos: lo unico que cambia es este adaptador. La base no sale del
/// telefono, de modo que el historial de lo que alguien consulta sobre su propia lengua
/// tampoco, que es lo que sostiene el marco de soberania de datos del proyecto.
class HistorialSqlite {
  HistorialSqlite._(this._base);

  final Database _base;

  static const _tabla = 'consultas';

  static Future<HistorialSqlite> abrir({String? rutaBase}) async {
    final ruta = rutaBase ?? p.join(await getDatabasesPath(), 'quechua_wanka.db');
    final base = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tabla (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            consulta TEXT NOT NULL,
            respuesta TEXT NOT NULL,
            abstenida INTEGER NOT NULL,
            similitud REAL NOT NULL,
            momento TEXT NOT NULL
          )
        ''');
      },
    );
    return HistorialSqlite._(base);
  }

  Future<void> registrar(EntradaHistorial entrada) async {
    await _base.insert(_tabla, {
      'consulta': entrada.consulta,
      'respuesta': entrada.respuesta,
      'abstenida': entrada.abstenida ? 1 : 0,
      'similitud': entrada.similitudMaxima,
      'momento': entrada.momento.toIso8601String(),
    });
  }

  Future<List<EntradaHistorial>> recientes({int limite = 20}) async {
    final filas = await _base.query(
      _tabla,
      orderBy: 'id DESC',
      limit: limite,
    );
    return filas
        .map(
          (f) => EntradaHistorial(
            consulta: f['consulta'] as String,
            respuesta: f['respuesta'] as String,
            abstenida: (f['abstenida'] as int) == 1,
            similitudMaxima: (f['similitud'] as num).toDouble(),
            momento: DateTime.parse(f['momento'] as String),
          ),
        )
        .toList();
  }

  Future<void> cerrar() => _base.close();
}
