class Marcador {
  const Marcador({
    required this.segundos,
    required this.movimientos,
    required this.fechaTiempo,
    required this.fechaMovimientos,
  });
  final int segundos;
  final int movimientos;
  final DateTime fechaTiempo;
  final DateTime fechaMovimientos;

  /// Tiempo y movimientos pueden corresponder a partidas diferentes.
  Marcador mejorar(int tiempo, int pasos, DateTime fecha) => Marcador(
    segundos: tiempo < segundos ? tiempo : segundos,
    movimientos: pasos < movimientos ? pasos : movimientos,
    fechaTiempo: tiempo < segundos ? fecha : fechaTiempo,
    fechaMovimientos: pasos < movimientos ? fecha : fechaMovimientos,
  );

  static Marcador? fromJson(Map<String, dynamic> json) {
    final seconds = json['segundos'];
    final moves = json['movimientos'];
    final timeDate = DateTime.tryParse('${json['fechaTiempo']}');
    final movesDate = DateTime.tryParse('${json['fechaMovimientos']}');
    if (seconds is! int ||
        moves is! int ||
        seconds < 0 ||
        moves < 1 ||
        timeDate == null ||
        movesDate == null) {
      return null;
    }
    return Marcador(
      segundos: seconds,
      movimientos: moves,
      fechaTiempo: timeDate,
      fechaMovimientos: movesDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'segundos': segundos,
    'movimientos': movimientos,
    'fechaTiempo': fechaTiempo.toIso8601String(),
    'fechaMovimientos': fechaMovimientos.toIso8601String(),
  };
}
