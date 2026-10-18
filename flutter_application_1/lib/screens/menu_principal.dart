import 'package:flutter/material.dart';

import '../estado/app_controller.dart';
import '../modelos/configuracion.dart';
import '../widgets/pagina.dart';
import 'configuracion_screen.dart';
import 'marcadores_screen.dart';
import 'informacion_screen.dart';
import 'puzzle_board.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key, required this.controller});
  final AppController controller;
  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  bool _opening = false;
  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  Future<void> _play() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      var size = widget.controller.configuracion.dificultad;
      if (size == null) {
        size = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Elige tu primer reto',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  for (final n in [3, 4, 5])
                    ListTile(
                      leading: const Icon(Icons.grid_on_rounded),
                      title: Text('${nombreDificultad(n)} · $n × $n'),
                      subtitle: Text('${n * n - 1} piezas'),
                      onTap: () => Navigator.pop(context, n),
                    ),
                ],
              ),
            ),
          ),
        );
        if (size == null) return;
        await widget.controller.configurar(
          widget.controller.configuracion.copyWith(dificultad: size),
        );
      }
      if (!mounted) return;
      _open(PuzzleBoard(gridSize: size, controller: widget.controller));
    } catch (_) {
      if (mounted) avisarError(context);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final settings = widget.controller.configuracion;
      final size = settings.dificultad;
      final record = size == null ? null : widget.controller.marcador(size);
      final colors = Theme.of(context).colorScheme;
      return _EntradaMenu(
        animaciones: settings.animaciones,
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.grid_view_rounded, color: colors.primary),
                          const SizedBox(width: 12),
                          const Text(
                            '15-PUZZLE',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Créditos',
                            icon: const Icon(Icons.info_outline),
                            onPressed: () =>
                                _open(const InformacionScreen(creditos: true)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [
                              colors.primaryContainer,
                              colors.tertiaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORDENA. DESLIZA. SUPÉRATE.',
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cada pieza\ntiene su lugar.',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colors.onPrimaryContainer,
                                    height: 1.12,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Encuentra el orden, mejora tu tiempo y conquista tu próximo reto.',
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: _opening ? null : _play,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Jugar'),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              size == null
                                  ? 'Tres dificultades. Tú eliges por dónde empezar.'
                                  : '${nombreDificultad(size)} · $size × $size · Cambia el nivel en Configuración',
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth >= 700
                              ? (constraints.maxWidth - 32) / 3
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _option(
                                width,
                                Icons.emoji_events_outlined,
                                'Marcadores',
                                'Tu mejor versión, partida a partida.',
                                () => _open(
                                  MarcadoresScreen(
                                    controller: widget.controller,
                                  ),
                                ),
                              ),
                              _option(
                                width,
                                Icons.tune_rounded,
                                'Configuración',
                                'Elige dificultad, tema y estilo.',
                                () => _open(
                                  ConfiguracionScreen(
                                    controller: widget.controller,
                                  ),
                                ),
                              ),
                              _option(
                                width,
                                Icons.touch_app_outlined,
                                'Cómo jugar',
                                'Aprende las reglas y encuentra el orden.',
                                () => _open(const InformacionScreen()),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      if (record != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.bolt_rounded),
                            title: Text(
                              'Tu récord en ${nombreDificultad(size!)}',
                            ),
                            subtitle: Text(
                              'Mejor tiempo ${formatearTiempo(record.segundos)} · Menos movimientos ${record.movimientos}',
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hecho para pensar a tu ritmo. Sin límite de tiempo.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  Widget _option(
    double width,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback tap,
  ) => SizedBox(
    width: width,
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: tap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
      ),
    ),
  );
}

class _EntradaMenu extends StatelessWidget {
  const _EntradaMenu({required this.child, required this.animaciones});
  final Widget child;
  final bool animaciones;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: animaciones && !MediaQuery.disableAnimationsOf(context)
        ? const Duration(milliseconds: 450)
        : Duration.zero,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: child,
      ),
    ),
    child: child,
  );
}
