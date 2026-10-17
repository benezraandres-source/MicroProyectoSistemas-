import 'package:flutter/material.dart';
import 'screens/puzzle_board.dart';

void main() {
  runApp(const MiJuegoPuzzle());
}

class MiJuegoPuzzle extends StatelessWidget {
  const MiJuegoPuzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '15-Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      // Ahora la aplicación inicia en nuestro Mini Menú de Dificultades
      home: const MenuDificultad(),
    );
  }
}

// Pantalla provisional para que pruebes tus 3 niveles
class MenuDificultad extends StatelessWidget {
  const MenuDificultad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal - 15 Puzzle'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selecciona tu nivel:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Botón Nivel Fácil (3x3)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const PuzzleBoard(gridSize: 3)
                ));
              },
              child: const Text('Fácil (3x3)', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Botón Nivel Medio (4x4)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const PuzzleBoard(gridSize: 4)
                ));
              },
              child: const Text('Medio Clásico (4x4)', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Botón Nivel Difícil (5x5)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const PuzzleBoard(gridSize: 5)
                ));
              },
              child: const Text('Difícil (5x5)', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}