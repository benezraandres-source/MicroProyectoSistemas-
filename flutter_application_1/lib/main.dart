import 'package:flutter/material.dart';

import 'datos/preferencias_usuario.dart';
import 'estado/app_controller.dart';
import 'screens/menu_principal.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Arranque());
}

class Arranque extends StatefulWidget {
  const Arranque({super.key});
  @override
  State<Arranque> createState() => _ArranqueState();
}

class _ArranqueState extends State<Arranque> {
  late Future<AppController> _loading;
  AppController? _controller;
  @override
  void initState() {
    super.initState();
    _loading = _load();
  }

  Future<AppController> _load() async {
    final controller = AppController(await PreferenciasUsuario.abrir());
    _controller = controller;
    return controller;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppController>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.hasData) return MiJuegoPuzzle(controller: snapshot.data!);
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: snapshot.hasError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storage_rounded, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'No pudimos abrir el almacenamiento local.',
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'Comprueba que el navegador permita guardar datos para este sitio.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => setState(() => _loading = _load()),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    },
  );
}

class _TransicionPuzzle extends PageTransitionsBuilder {
  const _TransicionPuzzle();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return FadeTransition(opacity: animation, child: child);
  }
}

class MiJuegoPuzzle extends StatelessWidget {
  const MiJuegoPuzzle({
    super.key,
    required this.controller,
    this.showSplash = true,
  });
  final AppController controller;
  final bool showSplash;

  ThemeData _theme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xff5264df),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: 'PuzzleSans',
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const _TransicionPuzzle(),
        },
      ),
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xfff5f6fc)
          : const Color(0xff10131f),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => MaterialApp(
      title: '15-Puzzle Flutter',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: controller.configuracion.tema,
      themeAnimationDuration: controller.configuracion.animaciones
          ? const Duration(milliseconds: 250)
          : Duration.zero,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              !controller.configuracion.animaciones ||
              MediaQuery.of(context).disableAnimations,
        ),
        child: child!,
      ),
      home: showSplash
          ? SplashScreen(controller: controller)
          : MenuPrincipal(controller: controller),
    ),
  );
}
