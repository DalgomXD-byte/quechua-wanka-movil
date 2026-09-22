import 'package:flutter/material.dart';

/// Tema deliberadamente sobrio: la aplicacion consulta fuentes documentales, y la
/// interfaz no debe competir con el contenido que cita.
class Tema {
  static const Color _acento = Color(0xFF3F6B5E); // verde apagado
  static const Color _arena = Color(0xFFFAF8F4);
  static const Color _tinta = Color(0xFF1C1B19);

  static ThemeData claro() => _construir(Brightness.light);

  static ThemeData oscuro() => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final esClaro = brillo == Brightness.light;
    final esquema = ColorScheme.fromSeed(
      seedColor: _acento,
      brightness: brillo,
    ).copyWith(
      surface: esClaro ? _arena : const Color(0xFF121211),
      onSurface: esClaro ? _tinta : const Color(0xFFE8E6E1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _tipografia(esquema),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esClaro ? Colors.white : const Color(0xFF1D1D1B),
        hintStyle: TextStyle(color: esquema.onSurface.withValues(alpha: 0.38)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: _borde(esquema, false),
        enabledBorder: _borde(esquema, false),
        focusedBorder: _borde(esquema, true),
      ),
      dividerTheme: DividerThemeData(
        color: esquema.onSurface.withValues(alpha: 0.08),
        space: 1,
        thickness: 1,
      ),
    );
  }

  static OutlineInputBorder _borde(ColorScheme esquema, bool enfocado) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: enfocado
              ? esquema.primary.withValues(alpha: 0.55)
              : esquema.onSurface.withValues(alpha: 0.12),
          width: enfocado ? 1.4 : 1,
        ),
      );

  static TextTheme _tipografia(ColorScheme esquema) {
    final atenuado = esquema.onSurface.withValues(alpha: 0.58);
    return TextTheme(
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: esquema.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
        color: atenuado,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        height: 1.5,
        color: esquema.onSurface,
      ),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: atenuado),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: atenuado),
    );
  }
}
