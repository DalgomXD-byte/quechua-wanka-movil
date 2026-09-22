import 'package:flutter/material.dart';

import '../../dominio/entidades/respuesta.dart';

/// Muestra la respuesta y, plegado debajo, el respaldo documental que la sostiene.
///
/// La abstencion se presenta con el mismo peso visual que una respuesta, no como un
/// error: que el sistema diga "no hay respaldo" es el comportamiento correcto.
class TarjetaRespuesta extends StatefulWidget {
  const TarjetaRespuesta({super.key, required this.respuesta});

  final Respuesta respuesta;

  @override
  State<TarjetaRespuesta> createState() => _TarjetaRespuestaState();
}

class _TarjetaRespuestaState extends State<TarjetaRespuesta> {
  bool _abierto = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final r = widget.respuesta;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: tema.brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1D1D1B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: esquema.onSurface.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r.abstenida)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 15, color: esquema.onSurface.withValues(alpha: 0.45)),
                  const SizedBox(width: 6),
                  Text('sin respaldo documental',
                      style: tema.textTheme.titleSmall),
                ],
              ),
            ),
          Text(r.texto, style: tema.textTheme.bodyLarge),
          if (r.consultaTraducida != null) ...[
            const SizedBox(height: 12),
            Text('buscado en espanol como "${r.consultaTraducida}"',
                style: tema.textTheme.bodySmall),
          ],
          if (r.respaldo.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            InkWell(
              onTap: () => setState(() => _abierto = !_abierto),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Text('RESPALDO  ${r.respaldo.length}',
                        style: tema.textTheme.titleSmall),
                    const Spacer(),
                    Icon(
                      _abierto ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: esquema.onSurface.withValues(alpha: 0.45),
                    ),
                  ],
                ),
              ),
            ),
            if (_abierto)
              ...r.respaldo.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.texto, style: tema.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(f.procedencia.citar(),
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: esquema.primary.withValues(alpha: 0.85),
                          )),
                    ],
                  ),
                ),
              ),
          ],
          if (r.aviso != null) ...[
            const SizedBox(height: 4),
            Text(r.aviso!, style: tema.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
