// lib/datos/preferencias_usuario.dart
// Nota para Diego: Aquí debes usar shared_preferences o get_storage
// para guardar y leer los datos locales del dispositivo.

class PreferenciasUsuario {
  
  // Función de ejemplo para guardar el mejor tiempo
  static Future<void> guardarMejorTiempo(int segundos, int dificultad) async {
    // Diego: Implementar la lógica con shared_preferences aquí
  }

  // Función de ejemplo para leer el mejor tiempo
  static Future<int> obtenerMejorTiempo(int dificultad) async {
    // Diego: Leer el valor guardado, por ahora retorna 0
    return 0; 
  }

  // Diego: Agrega aquí también las funciones para guardar Tema (Claro/Oscuro) 
  // y guardar los movimientos.
}