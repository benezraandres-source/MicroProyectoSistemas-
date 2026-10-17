// lib/pantallas/puzzle_board.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Importamos nuestros propios módulos separados
import '../utils/matematicas_puzzle.dart';
import '../widgets/ficha_puzzle.dart';

class PuzzleBoard extends StatefulWidget {
  final int gridSize;

  const PuzzleBoard({Key? key, required this.gridSize}) : super(key: key);

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  List<int> matriz = [];
  int posicionVacia = 0;
  int movimientos = 0;

  Timer? cronometro;
  int segundos = 0;
  bool juegoIniciado = false;

  @override
  void initState() {
    super.initState();
    _armarTablero();
  }

  @override
  void dispose() {
    cronometro?.cancel();
    super.dispose();
  }

  void _armarTablero() {
    int totalCasillas = widget.gridSize * widget.gridSize;
    matriz = List.generate(totalCasillas - 1, (i) => i + 1);
    matriz.add(0);

    Random rng = Random();
    do {
      matriz.shuffle(rng);
      posicionVacia = matriz.indexOf(0);
    // Usamos el validador matemático desde la carpeta utils
    } while (!MatematicasPuzzle.esResoluble(matriz, widget.gridSize, posicionVacia));

    movimientos = 0;
    segundos = 0;
    juegoIniciado = false;
    cronometro?.cancel();
    setState(() {});
  }

  void _empezarTiempo() {
    juegoIniciado = true;
    cronometro = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => segundos++);
    });
  }

  void _moverFicha(int index) {
    if (!juegoIniciado) _empezarTiempo();

    int filaTocada = index ~/ widget.gridSize;
    int colTocada = index % widget.gridSize;
    int filaVacia = posicionVacia ~/ widget.gridSize;
    int colVacia = posicionVacia % widget.gridSize;

    bool esVecina = (filaTocada == filaVacia && (colTocada - colVacia).abs() == 1) ||
                    (colTocada == colVacia && (filaTocada - filaVacia).abs() == 1);

    if (esVecina) {
      setState(() {
        matriz[posicionVacia] = matriz[index];
        matriz[index] = 0;
        posicionVacia = index;
        movimientos++;
      });
      _comprobarVictoria();
    }
  }

  void _comprobarVictoria() {
    bool gano = true;
    for (int i = 0; i < matriz.length - 1; i++) {
      if (matriz[i] != i + 1) { gano = false; break; }
    }
    if (gano && matriz.last == 0) {
      cronometro?.cancel();
      juegoIniciado = false;
      _mostrarMensajeVictoria();
    }
  }

  void _mostrarMensajeVictoria() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("¡Felicidades, Ganaste! 🎉", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Movimientos: $movimientos"),
            Text("Tiempo: ${_formatearTiempo(segundos)}"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _armarTablero(); },
            child: const Text("Volver a jugar"),
          ),
        ],
      ),
    );
  }

  String _formatearTiempo(int seg) {
    int m = seg ~/ 60;
    int s = seg % 60;
    return '${m < 10 ? '0$m' : m}:${s < 10 ? '0$s' : s}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rompecabezas ${widget.gridSize}x${widget.gridSize}'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _armarTablero),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [const Text("Movimientos", style: TextStyle(color: Colors.grey)), Text("$movimientos", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
                    Column(children: [const Text("Tiempo", style: TextStyle(color: Colors.grey)), Text(_formatearTiempo(segundos), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double tamanoTablero = min(constraints.maxWidth, constraints.maxHeight) * 0.9;
                    if (tamanoTablero > 500) tamanoTablero = 500;

                    return SizedBox(
                      width: tamanoTablero,
                      height: tamanoTablero,
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.gridSize,
                            crossAxisSpacing: 6.0,
                            mainAxisSpacing: 6.0,
                          ),
                          itemCount: matriz.length,
                          itemBuilder: (context, idx) {
                            // Usamos el widget de ficha visual separado en la carpeta widgets
                            return FichaPuzzle(
                              numero: matriz[idx],
                              alTocar: () => _moverFicha(idx),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}