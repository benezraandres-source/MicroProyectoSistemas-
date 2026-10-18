import 'package:flutter/material.dart';

import '../modelos/configuracion.dart';

class FichaPuzzle extends StatefulWidget {
  const FichaPuzzle({
    super.key,
    required this.numero,
    required this.alTocar,
    this.estilo = EstiloFicha.clasico,
    this.animaciones = true,
  });
  final int numero;
  final VoidCallback alTocar;
  final EstiloFicha estilo;
  final bool animaciones;
  @override
  State<FichaPuzzle> createState() => _FichaPuzzleState();
}

class _FichaPuzzleState extends State<FichaPuzzle> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (widget.numero == 0) {
      return Semantics(label: 'Espacio vacío', child: const SizedBox.expand());
    }
    final color = switch (widget.estilo) {
      EstiloFicha.clasico => colors.primary,
      EstiloFicha.colorido => HSLColor.fromAHSL(
        1,
        ((widget.numero * 39) % 360).toDouble(),
        0.65,
        0.35,
      ).toColor(),
      EstiloFicha.retro => const Color(0xff314b39),
      EstiloFicha.minimalista => colors.surfaceContainerHighest,
    };
    final text = widget.estilo == EstiloFicha.minimalista
        ? colors.onSurface
        : widget.estilo == EstiloFicha.retro
        ? const Color(0xfff7d98b)
        : Colors.white;
    final animate =
        widget.animaciones && !MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: 'Ficha ${widget.numero}',
      onTap: widget.alTocar,
      child: ExcludeSemantics(
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: animate ? const Duration(milliseconds: 120) : Duration.zero,
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(
              widget.estilo == EstiloFicha.retro ? 3 : 12,
            ),
            child: InkWell(
              onTap: widget.alTocar,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Center(
                  child: FittedBox(
                    child: Text(
                      '${widget.numero}',
                      style: TextStyle(
                        fontSize: 26,
                        letterSpacing: widget.estilo == EstiloFicha.retro
                            ? 2
                            : 0,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
