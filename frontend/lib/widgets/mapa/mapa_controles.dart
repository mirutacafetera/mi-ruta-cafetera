import 'package:flutter/material.dart';

class MapaControles extends StatelessWidget {
  final VoidCallback onCentrar;
  final VoidCallback onMostrarTodos;

  const MapaControles({
    super.key,
    required this.onCentrar,
    required this.onMostrarTodos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _boton(
          icono: Icons.my_location,
          tooltip: 'Centrar mapa',
          onPressed: onCentrar,
        ),
        const SizedBox(height: 8),
        _boton(
          icono: Icons.map_outlined,
          tooltip: 'Mostrar todos los sitios',
          onPressed: onMostrarTodos,
        ),
      ],
    );
  }

  Widget _boton({
    required IconData icono,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(
          icono,
          color: Colors.brown,
        ),
      ),
    );
  }
}