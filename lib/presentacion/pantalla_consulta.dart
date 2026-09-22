import 'package:flutter/material.dart';

import '../dominio/entidades/entrada_historial.dart';
import '../dominio/entidades/respuesta.dart';
import '../dominio/puertos/asistente_port.dart';
import 'widgets/caja_consulta.dart';
import 'widgets/lista_historial.dart';
import 'widgets/tarjeta_respuesta.dart';

class PantallaConsulta extends StatefulWidget {
  const PantallaConsulta({super.key, required this.asistente});

  final AsistentePort asistente;

  @override
  State<PantallaConsulta> createState() => _PantallaConsultaState();
}

class _PantallaConsultaState extends State<PantallaConsulta> {
  final _controlador = TextEditingController();
  bool _cargando = false;
  Respuesta? _respuesta;
  String? _error;
  List<EntradaHistorial> _historial = const [];
  EstadoSistema? _estado;

  @override
  void initState() {
    super.initState();
    _cargarEstado();
    _cargarHistorial();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _cargarEstado() async {
    try {
      final estado = await widget.asistente.estado();
      if (mounted) setState(() => _estado = estado);
    } catch (_) {
      if (mounted) setState(() => _estado = null);
    }
  }

  Future<void> _cargarHistorial() async {
    try {
      final entradas = await widget.asistente.historial(limite: 8);
      if (mounted) setState(() => _historial = entradas);
    } catch (_) {
      // El historial es accesorio: su ausencia no debe impedir consultar.
    }
  }

  Future<void> _consultar(String texto) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final respuesta = await widget.asistente.consultar(texto);
      if (!mounted) return;
      setState(() {
        _respuesta = respuesta;
        _cargando = false;
      });
      _cargarHistorial();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _repetir(String consulta) {
    _controlador.text = consulta;
    _consultar(consulta);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
              children: [
                Text('Quechua wanka', style: tema.textTheme.titleLarge),
                const SizedBox(height: 3),
                Text(
                  _estado == null
                      ? 'consulta documental'
                      : 'consulta documental · ${_estado!.fragmentosIndexados} fragmentos',
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(height: 26),
                CajaConsulta(
                  controlador: _controlador,
                  cargando: _cargando,
                  onEnviar: _consultar,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 18),
                  _Aviso(mensaje: _error!),
                ],
                if (_respuesta != null) ...[
                  const SizedBox(height: 20),
                  TarjetaRespuesta(respuesta: _respuesta!),
                ],
                if (_respuesta == null && _error == null) ...[
                  const SizedBox(height: 22),
                  Text(
                    'Las respuestas se componen únicamente a partir de fuentes '
                    'publicadas, y se citan con documento y página. Si no hay '
                    'respaldo, el sistema lo dice en lugar de proponer una forma.',
                    style: tema.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 34),
                ListaHistorial(entradas: _historial, onRepetir: _repetir),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esquema.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: esquema.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: esquema.error),
            ),
          ),
        ],
      ),
    );
  }
}
