import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AdminDrawerLogout extends StatelessWidget {
  final Function(String) onOpcionSeleccionada;

  const AdminDrawerLogout({
    super.key,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: AppColors.error,
      ),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(
          color: AppColors.error,
        ),
      ),
      onTap: () {
        onOpcionSeleccionada('logout');
        Navigator.pop(context);
      },
    );
  }
}