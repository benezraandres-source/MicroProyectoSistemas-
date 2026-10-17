// lib/widgets/ficha_puzzle.dart
import 'package:flutter/material.dart';

class FichaPuzzle extends StatelessWidget {
  final int numero;
  final VoidCallback alTocar;

  const FichaPuzzle({
    Key? key,
    required this.numero,
    required this.alTocar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (numero == 0) {
      return const SizedBox.shrink(); // El espacio vacío no dibuja nada
    }

    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigoAccent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2))
          ],
        ),
        child: Center(
          child: Text(
            '$numero',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}