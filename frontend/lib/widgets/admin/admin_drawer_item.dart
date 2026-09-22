import 'package:flutter/material.dart';

class AdminDrawerItem extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String opcion;
  final Function(String) onOpcionSeleccionada;

  const AdminDrawerItem({
    super.key,
    required this.icon,
    required this.titulo,
    required this.opcion,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(titulo),
      onTap: () {
        onOpcionSeleccionada(opcion);
        Navigator.pop(context);
      },
    );
  }
}