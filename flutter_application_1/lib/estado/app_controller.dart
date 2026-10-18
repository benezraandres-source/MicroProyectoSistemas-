import 'package:flutter/foundation.dart';

import '../datos/preferencias_usuario.dart';
import '../modelos/configuracion.dart';
import '../modelos/marcador.dart';

class AppController extends ChangeNotifier {
  AppController(this._storage) {
    configuracion = Configuracion.fromJson(_storage.leer('configuracion'));
    final saved = _storage.leer('marcadores');
    for (final size in [3, 4, 5]) {
      final item = saved['$size'];
      if (item is Map<String, dynamic>) {
        final record = Marcador.fromJson(item);
        if (record != null) _marcadores[size] = record;
      }
    }
  }
  final PreferenciasUsuario _storage;
  late Configuracion configuracion;
  final Map<int, Marcador> _marcadores = {};
  Marcador? marcador(int size) => _marcadores[size];

  Future<void> configurar(Configuracion next) async {
    await _storage.guardar('configuracion', next.toJson());
    configuracion = next;
    notifyListeners();
  }

  Future<bool> registrarVictoria(
    int size,
    int seconds,
    int moves, {
    DateTime? fecha,
  }) async {
    if (![3, 4, 5].contains(size) || seconds < 0 || moves < 1) {
      throw ArgumentError('Resultado de partida inválido');
    }
    final previous = _marcadores[size];
    final isRecord =
        previous == null ||
        seconds < previous.segundos ||
        moves < previous.movimientos;
    if (!isRecord) return false;
    final date = fecha ?? DateTime.now();
    final next = Map<int, Marcador>.of(_marcadores);
    next[size] =
        previous?.mejorar(seconds, moves, date) ??
        Marcador(
          segundos: seconds,
          movimientos: moves,
          fechaTiempo: date,
          fechaMovimientos: date,
        );
    await _storage.guardar('marcadores', {
      for (final entry in next.entries) '${entry.key}': entry.value.toJson(),
    });
    _marcadores
      ..clear()
      ..addAll(next);
    notifyListeners();
    return true;
  }

  Future<void> borrarMarcadores() async {
    await _storage.guardar('marcadores', {});
    _marcadores.clear();
    notifyListeners();
  }
}
