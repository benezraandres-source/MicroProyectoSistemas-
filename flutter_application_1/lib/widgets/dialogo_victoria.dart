import 'package:flutter/material.dart';

import '../estado/app_controller.dart';
import '../modelos/configuracion.dart';

enum AccionVictoria { menu, reiniciar }

class DialogoVictoria extends StatefulWidget {
  const DialogoVictoria({
    super.key,
    required this.controller,
    required this.dificultad,
    required this.segundos,
    required this.movimientos,
  });

  final AppController controller;
  final int dificultad;
  final int segundos;
  final int movimientos;

  @override
  State<DialogoVictoria> createState() => _DialogoVictoriaState();
}

class _DialogoVictoriaState extends State<DialogoVictoria> {
  final DateTime _fecha = DateTime.now();
  bool _guardando = true;
  bool _nuevoRecord = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _guardarResultado();
  }

  Future<void> _guardarResultado() async {
    try {
      final nuevoRecord = await widget.controller.registrarVictoria(
        widget.dificultad,
        widget.segundos,
        widget.movimientos,
        fecha: _fecha,
      );
      if (!mounted) return;
      setState(() {
        _nuevoRecord = nuevoRecord;
        _guardando = false;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = true;
      });
    }
  }

  void _reintentar() {
    setState(() => _guardando = true);
    _guardarResultado();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: AlertDialog(
      title: const Text('¡Ganaste!'),
      icon: const Icon(Icons.emoji_events_rounded, size: 48),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${nombreDificultad(widget.dificultad)} · ${widget.dificultad} × ${widget.dificultad}',
            ),
            const SizedBox(height: 16),
            Text('Tiempo: ${formatearTiempo(widget.segundos)}'),
            Text('Movimientos: ${widget.movimientos}'),
            if (_guardando)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(),
              ),
            if (_nuevoRecord)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  '¡Nuevo récord!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (_error) ...[
              const SizedBox(height: 16),
              const Text('No se pudo guardar el récord en este dispositivo.'),
              TextButton(
                onPressed: _guardando ? null : _reintentar,
                child: const Text('Reintentar guardado'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando
              ? null
              : () => Navigator.pop(context, AccionVictoria.menu),
          child: const Text('Menú principal'),
        ),
        FilledButton(
          onPressed: _guardando
              ? null
              : () => Navigator.pop(context, AccionVictoria.reiniciar),
          child: const Text('Volver a jugar'),
        ),
      ],
    ),
  );
}
