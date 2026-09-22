import 'package:flutter/material.dart';

/// Campo de consulta. Acepta espanol o ingles sin que el usuario elija idioma:
/// el idioma se detecta y, si hace falta, el termino se traduce antes de buscar.
class CajaConsulta extends StatelessWidget {
  const CajaConsulta({
    super.key,
    required this.controlador,
    required this.cargando,
    required this.onEnviar,
  });

  final TextEditingController controlador;
  final bool cargando;
  final ValueChanged<String> onEnviar;

  void _enviar() {
    final texto = controlador.text.trim();
    if (texto.isNotEmpty && !cargando) onEnviar(texto);
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controlador,
            enabled: !cargando,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _enviar(),
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'una palabra en espanol o ingles',
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          width: 52,
          child: Material(
            color: esquema.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: cargando ? null : _enviar,
              child: Center(
                child: cargando
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: esquema.onPrimary,
                        ),
                      )
                    : Icon(Icons.arrow_forward, size: 20, color: esquema.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
