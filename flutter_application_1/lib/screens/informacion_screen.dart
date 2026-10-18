import 'package:flutter/material.dart';

import '../widgets/pagina.dart';

class InformacionScreen extends StatelessWidget {
  const InformacionScreen({super.key, this.creditos = false});
  final bool creditos;
  @override
  Widget build(BuildContext context) => Pagina(
    titulo: creditos ? 'Créditos' : 'Cómo jugar',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          creditos ? Icons.favorite_outline : Icons.touch_app_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          creditos ? 'Un proyecto en equipo.' : 'Encuentra el orden.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        if (creditos) ...[
          const Text(
            '15-Puzzle Flutter',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Andrés Benezra · Lógica matemática y base del tablero.\nDiego Di Lima · Menús, preferencias, marcadores e integración.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Microproyecto académico · Sistemas de Información\nUniversidad Metropolitana',
          ),
          const SizedBox(height: 16),
          const Text(
            'Desarrollado con Flutter. Datos almacenados localmente en el dispositivo.',
          ),
        ] else ...[
          _step(
            context,
            '01',
            'Desliza una pieza',
            'Toca o haz clic en una pieza que esté justo arriba, abajo, a la izquierda o a la derecha del espacio vacío. No se permiten movimientos diagonales.',
          ),
          _step(
            context,
            '02',
            'Ordena el tablero',
            'Coloca los números en orden de izquierda a derecha y de arriba abajo. El espacio vacío debe quedar en la esquina inferior derecha.',
          ),
          _step(
            context,
            '03',
            'Supera tus marcas',
            'El cronómetro empieza con el primer movimiento válido. Al ganar se guardan tus mejores tiempos y movimientos por dificultad.',
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No hay derrota ni límite de tiempo: puedes resolver cada reto a tu ritmo. Reiniciar crea un tablero nuevo y descarta la partida actual.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Ejemplo de victoria · Fácil (3 × 3)'),
          const SizedBox(height: 12),
          Semantics(
            label: 'Tablero resuelto: uno, dos, tres; cuatro, cinco, seis; siete, ocho y espacio vacío.',
            child: ExcludeSemantics(
              child: SizedBox(
                width: 240,
                height: 240,
                child: GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  children: [
                    for (var i = 1; i <= 9; i++)
                      Container(
                        decoration: BoxDecoration(
                          color: i == 9
                              ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                              : Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            i == 9 ? '' : '$i',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
  Widget _step(BuildContext context, String n, String title, String detail) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Text(n)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(detail),
                ],
              ),
            ),
          ],
        ),
      );
}
