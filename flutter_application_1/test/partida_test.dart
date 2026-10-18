import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/modelos/partida.dart';
import 'package:flutter_application_1/utils/matematicas_puzzle.dart';

void main() {
  for (final n in [3, 4, 5]) {
    test('Genera tableros $n × $n resolubles y sin resolver', () {
      final rng = Random(2026);
      for (var i = 0; i < 100; i++) {
        final game = Partida(n, random: rng);
        expect(game.fichas.toSet().length, n * n);
        expect(game.ganada, isFalse);
        expect(
          MatematicasPuzzle.esResoluble(game.fichas, n, game.vacia),
          isTrue,
        );
      }
    });
    test('Rechaza una permutación imposible de $n × $n', () {
      final tiles = List.generate(n * n, (i) => (i + 1) % (n * n));
      tiles[0] = 2;
      tiles[1] = 1;
      expect(
        MatematicasPuzzle.esResoluble(tiles, n, tiles.indexOf(0)),
        isFalse,
      );
    });
  }
  test(
    'No permite saltar de una fila a otra ni contar movimientos inválidos',
    () {
      final game = Partida(3, tablero: [1, 2, 0, 4, 5, 3, 7, 8, 6]);
      expect(game.mover(3), isFalse);
      expect(game.mover(6), isFalse);
      expect(game.mover(2), isFalse);
      expect(game.movimientos, 0);
      expect(game.mover(5), isTrue);
      expect(game.movimientos, 1);
      expect(game.fichas, [1, 2, 3, 4, 5, 0, 7, 8, 6]);
      expect(game.mover(8), isTrue);
      expect(game.ganada, isTrue);
      expect(game.mover(7), isFalse);
      expect(game.movimientos, 2);
    },
  );
}
