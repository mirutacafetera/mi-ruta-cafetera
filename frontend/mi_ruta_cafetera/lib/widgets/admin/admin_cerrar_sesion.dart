import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminCerrarSesion extends StatelessWidget {
  final Function(String) onOpcionSeleccionada;

  const AdminCerrarSesion({
    super.key,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
      ),
      leading: const Icon(
        Icons.logout,
        color: AppColors.error,
        size: AppDimensions.iconMd,
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