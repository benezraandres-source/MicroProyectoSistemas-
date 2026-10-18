import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/datos/preferencias_usuario.dart';
import 'package:flutter_application_1/estado/app_controller.dart';
import 'package:flutter_application_1/modelos/configuracion.dart';
import 'package:flutter_application_1/screens/puzzle_board.dart';
import 'package:flutter_application_1/widgets/ficha_puzzle.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<AppController> load() async =>
      AppController(await PreferenciasUsuario.abrir());

  testWidgets('Splash permite saltar y abre el menú', (tester) async {
    await tester.pumpWidget(MiJuegoPuzzle(controller: await load()));
    expect(find.text('15-Puzzle Flutter'), findsOneWidget);
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);
  });
  testWidgets('La primera partida guarda la dificultad elegida', (
    tester,
  ) async {
    final app = await load();
    await tester.pumpWidget(MiJuegoPuzzle(controller: app, showSplash: false));
    await tester.ensureVisible(find.text('Jugar'));
    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fácil · 3 × 3'));
    await tester.pumpAndSettle();
    expect(app.configuracion.dificultad, 3);
    expect(find.byType(FichaPuzzle), findsNWidgets(9));
    expect(find.text('00:00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Cambiar tema se refleja de inmediato', (tester) async {
    final app = await load();
    await tester.pumpWidget(MiJuegoPuzzle(controller: app, showSplash: false));
    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<ThemeMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscuro').last);
    await tester.pumpAndSettle();
    expect(app.configuracion.tema, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Tu juego, a tu manera.'))).brightness,
      Brightness.dark,
    );
  });
  testWidgets('Cancelar borrado conserva récords; confirmar los borra', (
    tester,
  ) async {
    final app = await load();
    await app.registrarVictoria(3, 10, 4);
    await tester.pumpWidget(MiJuegoPuzzle(controller: app, showSplash: false));
    await tester.tap(find.text('Marcadores'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Borrar todos los marcadores'));
    await tester.tap(find.text('Borrar todos los marcadores'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(app.marcador(3), isNotNull);
    await tester.tap(find.text('Borrar todos los marcadores'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar').last);
    await tester.pumpAndSettle();
    expect(app.marcador(3), isNull);
    expect(find.text('Tu primera victoria te espera.'), findsOneWidget);
  });
  testWidgets(
    'Clic inválido no inicia cronómetro; victoria guarda y permite reiniciar',
    (tester) async {
      final app = await load();
      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleBoard(
            gridSize: 3,
            controller: app,
            initialBoard: const [1, 2, 3, 4, 5, 6, 7, 0, 8],
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('tile-0')));
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.text('Toca una pieza junto al espacio vacío para empezar.'),
        findsOneWidget,
      );
      expect(find.text('00:00'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tile-8')));
      await tester.pumpAndSettle();
      expect(find.text('¡Ganaste!'), findsOneWidget);
      expect(find.text('¡Nuevo récord!'), findsOneWidget);
      expect(app.marcador(3)!.movimientos, 1);
      await tester.tap(find.text('Volver a jugar'));
      await tester.pumpAndSettle();
      expect(find.text('¡Ganaste!'), findsNothing);
      expect(find.text('00:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Permite reintentar el guardado después de ganar', (
    tester,
  ) async {
    final preferencias = await SharedPreferences.getInstance();
    final almacenamiento = _AlmacenamientoConFallo(preferencias);
    final app = AppController(almacenamiento);
    await tester.pumpWidget(
      MaterialApp(
        home: PuzzleBoard(
          gridSize: 3,
          controller: app,
          initialBoard: const [1, 2, 3, 4, 5, 6, 7, 0, 8],
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('tile-8')));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo guardar el récord en este dispositivo.'),
      findsOneWidget,
    );
    expect(app.marcador(3), isNull);
    almacenamiento.fallar = false;
    await tester.tap(find.text('Reintentar guardado'));
    await tester.pumpAndSettle();
    expect(find.text('¡Nuevo récord!'), findsOneWidget);
    expect(app.marcador(3)!.movimientos, 1);
    await tester.tap(find.text('Volver a jugar'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Salir de una partida requiere confirmar y libera el cronómetro',
    (tester) async {
      final app = await load();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => PuzzleBoard(
                      gridSize: 3,
                      controller: app,
                      initialBoard: const [1, 2, 3, 4, 5, 6, 0, 7, 8],
                    ),
                  ),
                ),
                child: const Text('Abrir partida'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir partida'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tile-7')));
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('¿Salir al menú?'), findsOneWidget);
      await tester.tap(find.text('Seguir jugando'));
      await tester.pumpAndSettle();
      expect(find.byType(PuzzleBoard), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salir'));
      await tester.pumpAndSettle();
      expect(find.text('Abrir partida'), findsOneWidget);
      expect(find.byType(PuzzleBoard), findsNothing);
      expect(app.marcador(3), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('Menú y tablero caben en $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final app = await load();
      await app.configurar(
        const Configuracion(dificultad: 5, animaciones: false),
      );
      await tester.pumpWidget(
        MiJuegoPuzzle(controller: app, showSplash: false),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Jugar'));
      await tester.tap(find.text('Jugar'));
      await tester.pumpAndSettle();
      expect(find.byType(FichaPuzzle), findsNWidgets(25));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class _AlmacenamientoConFallo extends PreferenciasUsuario {
  _AlmacenamientoConFallo(super.preferences);
  bool fallar = true;
  @override
  Future<void> guardar(String key, Map<String, dynamic> value) async {
    if (fallar) throw StateError('Fallo de escritura');
    await super.guardar(key, value);
  }
}
