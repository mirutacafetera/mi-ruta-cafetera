import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AdminEncabezadoMenu extends StatelessWidget {
  final String nombre;
  final String email;

  const AdminEncabezadoMenu({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: AppColors.primary),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: AppColors.white,
        child: Icon(
          Icons.admin_panel_settings,
          size: 35,
          color: AppColors.primary,
        ),
      ),
      accountName: Text(
        nombre,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(email, style: const TextStyle(color: AppColors.white)),
    );
  }
}
