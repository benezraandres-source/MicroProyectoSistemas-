import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Un documento por operación evita guardar resultados parcialmente.
class PreferenciasUsuario {
  PreferenciasUsuario(this._preferences);
  final SharedPreferences _preferences;

  static Future<PreferenciasUsuario> abrir() async =>
      PreferenciasUsuario(await SharedPreferences.getInstance());

  Map<String, dynamic> leer(String key) {
    final raw = _preferences.get('puzzle.$key');
    if (raw is! String) return {};
    try {
      final value = jsonDecode(raw);
      return value is Map<String, dynamic> ? value : {};
    } on FormatException {
      return {};
    }
  }

  Future<void> guardar(String key, Map<String, dynamic> value) async {
    if (!await _preferences.setString('puzzle.$key', jsonEncode(value))) {
      throw StateError('No se pudieron guardar los datos en este dispositivo.');
    }
  }
}
