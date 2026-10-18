import 'package:flutter/material.dart';

import '../estado/app_controller.dart';
import '../modelos/configuracion.dart';
import '../widgets/pagina.dart';

class MarcadoresScreen extends StatefulWidget {
  const MarcadoresScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<MarcadoresScreen> createState() => _MarcadoresScreenState();
}

class _MarcadoresScreenState extends State<MarcadoresScreen> {
  bool _deleting = false;
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todos los marcadores?'),
        content: const Text(
          'Se eliminarán tus récords de las tres dificultades. Tus preferencias se conservarán. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await widget.controller.borrarMarcadores();
    } catch (_) {
      if (mounted) avisarError(context);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final empty = [
        3,
        4,
        5,
      ].every((n) => widget.controller.marcador(n) == null);
      return Pagina(
        titulo: 'Marcadores',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Récords por dificultad',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu mejor tiempo y tu menor número de movimientos, por dificultad.',
            ),
            const SizedBox(height: 24),
            if (empty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 48),
                      SizedBox(height: 12),
                      Text('Tu primera victoria te espera.'),
                      Text(
                        'Completa una partida para guardar tu primer récord.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            for (final size in [3, 4, 5]) _record(size),
            const SizedBox(height: 12),
            const Text(
              'Cada récord conserva la fecha de la partida que lo consiguió. Tiempo y movimientos pueden pertenecer a partidas diferentes.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: empty || _deleting ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Borrar todos los marcadores'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Los datos se guardan solo en este navegador o dispositivo. No se sincronizan entre dispositivos.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    },
  );
  Widget _record(int size) {
    final record = widget.controller.marcador(size);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${nombreDificultad(size)} · $size × $size',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (record == null)
              const Text('Aún no hay partidas completadas.')
            else
              Wrap(
                spacing: 36,
                runSpacing: 16,
                children: [
                  _metric(
                    Icons.timer_outlined,
                    'Mejor tiempo',
                    formatearTiempo(record.segundos),
                    _date(record.fechaTiempo),
                  ),
                  _metric(
                    Icons.touch_app_outlined,
                    'Menos movimientos',
                    '${record.movimientos}',
                    _date(record.fechaMovimientos),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String label, String value, String date) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(date),
        ],
      );
}
