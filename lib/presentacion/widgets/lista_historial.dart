import 'package:flutter/material.dart';

import '../../dominio/entidades/entrada_historial.dart';

/// Consultas anteriores. Se puede volver a cualquiera con un toque.
class ListaHistorial extends StatelessWidget {
  const ListaHistorial({
    super.key,
    required this.entradas,
    required this.onRepetir,
  });

  final List<EntradaHistorial> entradas;
  final ValueChanged<String> onRepetir;

  @override
  Widget build(BuildContext context) {
    if (entradas.isEmpty) return const SizedBox.shrink();
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECIENTES', style: tema.textTheme.titleSmall),
        const SizedBox(height: 4),
        ...entradas.map(
          (e) => InkWell(
            onTap: () => onRepetir(e.consulta),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.consulta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurface.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                  if (e.abstenida)
                    Icon(Icons.remove,
                        size: 14,
                        color: tema.colorScheme.onSurface.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
