import 'package:flutter/material.dart';

enum EstiloFicha { clasico, colorido, retro, minimalista }

String nombreDificultad(int size) => switch (size) {
  3 => 'Fácil',
  4 => 'Medio',
  _ => 'Difícil',
};

String formatearTiempo(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

class Configuracion {
  const Configuracion({
    this.dificultad,
    this.tema = ThemeMode.system,
    this.estilo = EstiloFicha.clasico,
    this.animaciones = true,
  });
  final int? dificultad;
  final ThemeMode tema;
  final EstiloFicha estilo;
  final bool animaciones;

  Configuracion copyWith({
    int? dificultad,
    ThemeMode? tema,
    EstiloFicha? estilo,
    bool? animaciones,
  }) => Configuracion(
    dificultad: dificultad ?? this.dificultad,
    tema: tema ?? this.tema,
    estilo: estilo ?? this.estilo,
    animaciones: animaciones ?? this.animaciones,
  );

  factory Configuracion.fromJson(Map<String, dynamic> json) {
    final dificultad = json['dificultad'];
    return Configuracion(
      dificultad: [3, 4, 5].contains(dificultad) ? dificultad as int : null,
      tema: ThemeMode.values.firstWhere(
        (v) => v.name == json['tema'],
        orElse: () => ThemeMode.system,
      ),
      estilo: EstiloFicha.values.firstWhere(
        (v) => v.name == json['estilo'],
        orElse: () => EstiloFicha.clasico,
      ),
      animaciones: json['animaciones'] is bool
          ? json['animaciones'] as bool
          : true,
    );
  }

  Map<String, dynamic> toJson() => {
    'dificultad': dificultad,
    'tema': tema.name,
    'estilo': estilo.name,
    'animaciones': animaciones,
  };
}
