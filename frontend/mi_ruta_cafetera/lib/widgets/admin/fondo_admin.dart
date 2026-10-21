
import 'package:flutter/material.dart';

class FondoAdmin extends StatelessWidget {
  final Widget child;

  const FondoAdmin({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Fondo base beige
            const ColoredBox(
              color: Color(0xFFFAF3E7),
            ),

            // Imagen completa como fondo de la pantalla
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  'assets/img/fondo_admin.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),

            // Contenido del administrador por encima del fondo
            Positioned.fill(
              child: child,
            ),
          ],
        );
      },
    );
  }
}
