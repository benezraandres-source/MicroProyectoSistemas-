import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../estado/app_controller.dart';
import '../modelos/configuracion.dart';
import '../modelos/partida.dart';
import '../widgets/ficha_puzzle.dart';
import '../widgets/dialogo_victoria.dart';

class PuzzleBoard extends StatefulWidget {
  const PuzzleBoard({
    super.key,
    required this.gridSize,
    required this.controller,
    this.initialBoard,
  });
  final int gridSize;
  final AppController controller;
  @visibleForTesting
  final List<int>? initialBoard;
  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> with WidgetsBindingObserver {
  late Partida _partida;
  final Stopwatch _reloj = Stopwatch();
  Timer? _actualizacionTiempo;
  bool _permitirSalida = false;
  bool _confirmandoSalida = false;
  bool _enPausa = false;
  bool _finalizando = false;
  int get _segundos => _reloj.elapsed.inSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _partida = Partida(widget.gridSize, tablero: widget.initialBoard);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _actualizacionTiempo?.cancel();
    _reloj.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_partida.movimientos == 0 || _partida.ganada) return;
    final pause = state != AppLifecycleState.resumed;
    if (pause) {
      _reloj.stop();
    } else {
      _reloj.start();
    }
    if (mounted) setState(() => _enPausa = pause);
  }

  void _moverFicha(int index) {
    if (_enPausa || _finalizando || !_partida.mover(index)) return;
    if (_partida.movimientos == 1) {
      _reloj.start();
      _actualizacionTiempo = Timer.periodic(const Duration(milliseconds: 200), (
        _,
      ) {
        if (mounted) setState(() {});
      });
    }
    setState(() {});
    if (_partida.ganada) _terminarPartida();
  }

  Future<void> _terminarPartida() async {
    _finalizando = true;
    _reloj.stop();
    _actualizacionTiempo?.cancel();
    final accion = await showDialog<AccionVictoria>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogoVictoria(
        controller: widget.controller,
        dificultad: widget.gridSize,
        segundos: _segundos,
        movimientos: _partida.movimientos,
      ),
    );
    if (!mounted) return;
    if (accion == AccionVictoria.reiniciar) {
      _reiniciar();
    } else if (accion == AccionVictoria.menu) {
      _salir();
    }
  }

  void _reiniciar() {
    _actualizacionTiempo?.cancel();
    _reloj.stop();
    _reloj.reset();
    setState(() {
      _partida = Partida(widget.gridSize);
      _finalizando = false;
      _enPausa = false;
    });
  }

  void _salir() {
    setState(() => _permitirSalida = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<bool> _confirmar(String title, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: const Text(
            'Se descartará la partida actual. Los récords guardados se conservan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Seguir jugando'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> _pedirSalida() async {
    if (_confirmandoSalida || _finalizando) return;
    _confirmandoSalida = true;
    final yes = await _confirmar('¿Salir al menú?', 'Salir');
    if (mounted && yes) _salir();
    _confirmandoSalida = false;
  }

  Future<void> _pedirReinicio() async {
    if (_partida.movimientos == 0 ||
        await _confirmar('¿Reiniciar la partida?', 'Reiniciar')) {
      if (mounted) _reiniciar();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _permitirSalida || (_partida.movimientos == 0 && !_finalizando),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _pedirSalida();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          '${nombreDificultad(widget.gridSize)} · ${widget.gridSize} × ${widget.gridSize}',
        ),
        actions: [
          IconButton(
            tooltip: 'Reiniciar partida',
            onPressed: _finalizando ? null : _pedirReinicio,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 8,
                children: [
                  _indicador(
                    Icons.touch_app_outlined,
                    'Movimientos',
                    '${_partida.movimientos}',
                  ),
                  _indicador(
                    Icons.timer_outlined,
                    'Tiempo',
                    formatearTiempo(_segundos),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _enPausa
                    ? 'En pausa mientras la aplicación está en segundo plano.'
                    : _partida.movimientos == 0
                    ? 'Toca una pieza junto al espacio vacío para empezar.'
                    : 'Ordena los números y deja el espacio vacío al final.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final side = min(
                      560.0,
                      min(constraints.maxWidth, constraints.maxHeight),
                    );
                    return Center(
                      child: SizedBox(
                        width: side,
                        height: side,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widget.gridSize,
                                    crossAxisSpacing: 6,
                                    mainAxisSpacing: 6,
                                  ),
                              itemCount: _partida.fichas.length,
                              itemBuilder: (context, index) => FichaPuzzle(
                                key: ValueKey('tile-$index'),
                                numero: _partida.fichas[index],
                                estilo: widget.controller.configuracion.estilo,
                                animaciones:
                                    widget.controller.configuracion.animaciones,
                                alTocar: () => _moverFicha(index),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _indicador(IconData icon, String label, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    ],
  );
}
