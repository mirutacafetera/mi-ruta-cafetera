import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(titulo),
      onTap: () {
        onOpcionSeleccionada(opcion);
        Navigator.pop(context);
      },
    );
  }
}