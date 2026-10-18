import 'package:flutter/material.dart';

import '../estado/app_controller.dart';
import '../modelos/configuracion.dart';
import '../widgets/ficha_puzzle.dart';
import '../widgets/pagina.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _saving = false;
  Future<void> _save(Configuracion value) async {
    setState(() => _saving = true);
    try {
      await widget.controller.configurar(value);
    } catch (_) {
      if (mounted) avisarError(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.configuracion;
    return Pagina(
      titulo: 'Configuración',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu juego, a tu manera.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Los cambios se guardan automáticamente en este dispositivo.',
          ),
          const SizedBox(height: 28),
          DropdownButtonFormField<int>(
            key: ValueKey('difficulty-${settings.dificultad}'),
            initialValue: settings.dificultad,
            decoration: const InputDecoration(
              labelText: 'Dificultad predeterminada',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Elegir dificultad'),
            items: [
              for (final n in [3, 4, 5])
                DropdownMenuItem(
                  value: n,
                  child: Text('${nombreDificultad(n)} · $n × $n'),
                ),
            ],
            onChanged: _saving
                ? null
                : (v) {
                    if (v != null) _save(settings.copyWith(dificultad: v));
                  },
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<ThemeMode>(
            key: ValueKey(settings.tema),
            initialValue: settings.tema,
            decoration: const InputDecoration(
              labelText: 'Tema',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('Automático (sistema)'),
              ),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
            ],
            onChanged: _saving
                ? null
                : (v) {
                    if (v != null) _save(settings.copyWith(tema: v));
                  },
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<EstiloFicha>(
            key: ValueKey(settings.estilo),
            initialValue: settings.estilo,
            decoration: const InputDecoration(
              labelText: 'Estilo de las piezas',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: EstiloFicha.clasico,
                child: Text('Numérico clásico'),
              ),
              DropdownMenuItem(
                value: EstiloFicha.colorido,
                child: Text('Colorido'),
              ),
              DropdownMenuItem(value: EstiloFicha.retro, child: Text('Retro')),
              DropdownMenuItem(
                value: EstiloFicha.minimalista,
                child: Text('Minimalista'),
              ),
            ],
            onChanged: _saving
                ? null
                : (v) {
                    if (v != null) _save(settings.copyWith(estilo: v));
                  },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Animaciones'),
            subtitle: const Text('Transiciones y efectos visuales del juego.'),
            value: settings.animaciones,
            onChanged: _saving
                ? null
                : (v) => _save(settings.copyWith(animaciones: v)),
          ),
          const SizedBox(height: 24),
          Text('VISTA PREVIA', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: Row(
              children: [
                for (final n in [1, 2, 3])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FichaPuzzle(
                        numero: n,
                        estilo: settings.estilo,
                        animaciones: settings.animaciones,
                        alTocar: () {},
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_saving) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
