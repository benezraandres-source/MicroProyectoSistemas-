// lib/utils/matematicas_puzzle.dart

class MatematicasPuzzle {
  // Función estática para validar si el tablero tiene solución
  static bool esResoluble(List<int> matriz, int gridSize, int posicionVacia) {
    int inversiones = 0;
    int n = matriz.length;

    for (int i = 0; i < n - 1; i++) {
      for (int j = i + 1; j < n; j++) {
        if (matriz[i] != 0 && matriz[j] != 0 && matriz[i] > matriz[j]) {
          inversiones++;
        }
      }
    }

    if (gridSize % 2 != 0) {
      return inversiones % 2 == 0;
    } else {
      int filaDesdeAbajo = gridSize - (posicionVacia ~/ gridSize);
      if (filaDesdeAbajo % 2 == 0) {
        return inversiones % 2 != 0;
      } else {
        return inversiones % 2 == 0;
      }
    }
  }
}