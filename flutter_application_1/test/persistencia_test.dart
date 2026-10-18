import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/datos/preferencias_usuario.dart';
import 'package:flutter_application_1/estado/app_controller.dart';
import 'package:flutter_application_1/modelos/configuracion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<AppController> load() async =>
      AppController(await PreferenciasUsuario.abrir());
  test(
    'Las preferencias sobreviven a la recreación de la aplicación',
    () async {
      final app = await load();
      await app.configurar(
        const Configuracion(
          dificultad: 5,
          tema: ThemeMode.dark,
          estilo: EstiloFicha.retro,
          animaciones: false,
        ),
      );
      final restored = await load();
      expect(restored.configuracion.dificultad, 5);
      expect(restored.configuracion.tema, ThemeMode.dark);
      expect(restored.configuracion.estilo, EstiloFicha.retro);
      expect(restored.configuracion.animaciones, isFalse);
    },
  );
  test('Récords independientes por dificultad, valor y fecha', () async {
    final app = await load();
    final first = DateTime(2026, 10, 17), second = DateTime(2026, 10, 18);
    expect(await app.registrarVictoria(3, 60, 40, fecha: first), isTrue);
    expect(await app.registrarVictoria(3, 70, 30, fecha: second), isTrue);
    expect(await app.registrarVictoria(3, 80, 50), isFalse);
    expect(await app.registrarVictoria(3, 60, 30), isFalse);
    await app.registrarVictoria(4, 100, 80, fecha: first);
    final restored = await load();
    expect(restored.marcador(3)!.segundos, 60);
    expect(restored.marcador(3)!.movimientos, 30);
    expect(restored.marcador(3)!.fechaTiempo, first);
    expect(restored.marcador(3)!.fechaMovimientos, second);
    expect(restored.marcador(4)!.segundos, 100);
    expect(restored.marcador(5), isNull);
  });
  test('Borrar marcadores conserva todas las preferencias', () async {
    final app = await load();
    await app.configurar(
      const Configuracion(dificultad: 4, tema: ThemeMode.dark),
    );
    await app.registrarVictoria(4, 30, 15);
    await app.borrarMarcadores();
    final restored = await load();
    expect(restored.marcador(4), isNull);
    expect(restored.configuracion.tema, ThemeMode.dark);
    expect(restored.configuracion.dificultad, 4);
  });
  test('Datos dañados no bloquean el inicio', () async {
    SharedPreferences.setMockInitialValues({
      'puzzle.configuracion': '{invalid',
      'puzzle.marcadores': '{"3":{"segundos":-1,"movimientos":3}}',
    });
    final app = await load();
    expect(app.configuracion.tema, ThemeMode.system);
    expect(app.marcador(3), isNull);
  });
  test(
    'Un fallo de escritura no anuncia un récord ni modifica el estado',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final app = AppController(_StorageFallido(prefs));
      await expectLater(app.registrarVictoria(3, 10, 1), throwsStateError);
      expect(app.marcador(3), isNull);
      await expectLater(
        app.configurar(const Configuracion(dificultad: 5)),
        throwsStateError,
      );
      expect(app.configuracion.dificultad, isNull);
    },
  );
}

class _StorageFallido extends PreferenciasUsuario {
  _StorageFallido(super.preferences);
  @override
  Future<void> guardar(String key, Map<String, dynamic> value) async =>
      throw StateError('Sin espacio');
}
