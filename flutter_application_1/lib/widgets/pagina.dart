import 'package:flutter/material.dart';

class Pagina extends StatelessWidget {
  const Pagina({
    super.key,
    required this.titulo,
    required this.child,
    this.actions,
  });
  final String titulo;
  final Widget child;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(titulo), actions: actions),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void avisarError(BuildContext context) => ScaffoldMessenger.of(context)
    .showSnackBar(
      const SnackBar(
        content: Text(
          'No se pudo guardar. Comprueba el almacenamiento del dispositivo e inténtalo otra vez.',
        ),
      ),
    );
