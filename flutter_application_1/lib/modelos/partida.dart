import 'dart:math';

import '../utils/matematicas_puzzle.dart';

class Partida {
  Partida(this.size, {Random? random, List<int>? tablero}) {
    if (![3, 4, 5].contains(size)) throw ArgumentError('Dificultad inválida');
    if (tablero != null) {
      if (tablero.length != size * size ||
          tablero.toSet().length != size * size ||
          tablero.any((n) => n < 0 || n >= size * size)) {
        throw ArgumentError('Tablero inválido');
      }
      fichas = List.of(tablero);
    } else {
      fichas = List.generate(size * size, (i) => (i + 1) % (size * size));
      final rng = random ?? Random();
      do {
        fichas.shuffle(rng);
      } while (ganada || !MatematicasPuzzle.esResoluble(fichas, size, vacia));
    }
  }
  final int size;
  late final List<int> fichas;
  int movimientos = 0;
  int get vacia => fichas.indexOf(0);
  bool get ganada {
    for (var i = 0; i < fichas.length; i++) {
      if (fichas[i] != (i + 1) % fichas.length) return false;
    }
    return true;
  }

  bool mover(int index) {
    if (ganada || index < 0 || index >= fichas.length) return false;
    final empty = vacia;
    final distance =
        (index ~/ size - empty ~/ size).abs() +
        (index % size - empty % size).abs();
    if (distance != 1) return false;
    fichas[empty] = fichas[index];
    fichas[index] = 0;
    movimientos++;
    return true;
  }
}
