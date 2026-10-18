import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../estado/app_controller.dart';
import '../modelos/configuracion.dart';
import '../modelos/partida.dart';
import '../widgets/ficha_puzzle.dart';

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
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;
  bool _allowExit = false;
  bool _askingExit = false;
  bool _paused = false;
  bool _finishing = false;
  bool _savingResult = false;
  int get _seconds => _watch.elapsed.inSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _partida = Partida(widget.gridSize, tablero: widget.initialBoard);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _watch.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_partida.movimientos == 0 || _partida.ganada) return;
    final pause = state != AppLifecycleState.resumed;
    if (pause) {
      _watch.stop();
    } else {
      _watch.start();
    }
    if (mounted) setState(() => _paused = pause);
  }

  void _move(int index) {
    if (_paused || _finishing || !_partida.mover(index)) return;
    if (_partida.movimientos == 1) {
      _watch.start();
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() {});
    if (_partida.ganada) _finish();
  }

  Future<void> _finish() async {
    _finishing = true;
    _savingResult = true;
    _watch.stop();
    _ticker?.cancel();
    bool record = false;
    bool failed = false;
    try {
      record = await widget.controller.registrarVictoria(
        widget.gridSize,
        _seconds,
        _partida.movimientos,
      );
    } catch (_) {
      failed = true;
    }
    if (!mounted) return;
    setState(() => _savingResult = false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('¡Ganaste!'),
              icon: const Icon(Icons.emoji_events_rounded, size: 48),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${nombreDificultad(widget.gridSize)} · ${widget.gridSize} × ${widget.gridSize}',
                    ),
                    const SizedBox(height: 16),
                    Text('Tiempo: ${formatearTiempo(_seconds)}'),
                    Text('Movimientos: ${_partida.movimientos}'),
                    if (record)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          '¡Nuevo récord!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (failed) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Ganaste, pero el récord no pudo guardarse en este dispositivo.',
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            final saved = await widget.controller
                                .registrarVictoria(
                                  widget.gridSize,
                                  _seconds,
                                  _partida.movimientos,
                                );
                            if (context.mounted) {
                              update(() {
                                failed = false;
                                record = saved;
                              });
                            }
                          } catch (_) {
                            /* El aviso permanece visible y permite reintentar. */
                          }
                        },
                        child: const Text('Reintentar guardado'),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _leave();
                  },
                  child: const Text('Menú principal'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _reset();
                  },
                  child: const Text('Volver a jugar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _reset() {
    _ticker?.cancel();
    _watch.stop();
    _watch.reset();
    setState(() {
      _partida = Partida(widget.gridSize);
      _finishing = false;
      _paused = false;
    });
  }

  void _leave() {
    setState(() => _allowExit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<bool> _confirm(String title, String action) async =>
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
  Future<void> _requestExit() async {
    if (_askingExit || _finishing) return;
    _askingExit = true;
    final yes = await _confirm('¿Salir al menú?', 'Salir');
    if (mounted && yes) _leave();
    _askingExit = false;
  }

  Future<void> _restart() async {
    if (_partida.movimientos == 0 ||
        await _confirm('¿Reiniciar la partida?', 'Reiniciar')) {
      if (mounted) _reset();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _allowExit || (_partida.movimientos == 0 && !_finishing),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _requestExit();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          '${nombreDificultad(widget.gridSize)} · ${widget.gridSize} × ${widget.gridSize}',
        ),
        actions: [
          IconButton(
            tooltip: 'Reiniciar partida',
            onPressed: _finishing ? null : _restart,
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
                  _stat(
                    Icons.touch_app_outlined,
                    'Movimientos',
                    '${_partida.movimientos}',
                  ),
                  _stat(
                    Icons.timer_outlined,
                    'Tiempo',
                    formatearTiempo(_seconds),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _paused
                    ? 'En pausa mientras la aplicación está en segundo plano.'
                    : _partida.movimientos == 0
                    ? 'Toca una pieza junto al espacio vacío para empezar.'
                    : 'Cada movimiento te acerca al orden.',
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
                                alTocar: () => _move(index),
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
              if (_savingResult) const LinearProgressIndicator(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _stat(IconData icon, String label, String value) => Row(
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
