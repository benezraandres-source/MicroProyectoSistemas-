import 'dart:async';

import 'package:flutter/material.dart';

import '../estado/app_controller.dart';
import 'menu_principal.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _navigated = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _continue);
  }

  void _continue() {
    if (!mounted || _navigated) return;
    _navigated = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MenuPrincipal(controller: widget.controller),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration:
                    widget.controller.configuracion.animaciones &&
                        !MediaQuery.disableAnimationsOf(context)
                    ? const Duration(milliseconds: 800)
                    : Duration.zero,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.85 + value * 0.15,
                    child: child,
                  ),
                ),
                child: const Icon(Icons.grid_view_rounded, size: 100),
              ),
              const SizedBox(height: 24),
              Text(
                '15-Puzzle Flutter',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Rompecabezas deslizante',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(onPressed: _continue, child: const Text('Saltar')),
            ],
          ),
        ),
      ),
    ),
  );
}
