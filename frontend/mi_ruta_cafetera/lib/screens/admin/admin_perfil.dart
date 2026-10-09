import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminPerfil extends StatelessWidget {
  final String nombre;
  final String email;

  const AdminPerfil({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: AppDimensions.spacingXl,
          ),

          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.cream,
            child: Icon(
              Icons.admin_panel_settings,
              size: 60,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingXl,
          ),

          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingSm,
          ),

          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingSection,
          ),

          Card(
            color: AppColors.surface,
            elevation: AppDimensions.elevationButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                AppDimensions.spacingXl,
              ),
              child: Column(
                children: [
                  _dato(
                    Icons.person_outline,
                    'Nombre',
                    nombre,
                  ),
                  const Divider(
                    color: AppColors.divider,
                  ),
                  _dato(
                    Icons.email_outlined,
                    'Correo',
                    email,
                  ),
                  const Divider(
                    color: AppColors.divider,
                  ),
                  _dato(
                    Icons.admin_panel_settings_outlined,
                    'Rol',
                    'Administrador',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Row(
      children: [
        Icon(
          icono,
          color: AppColors.primary,
        ),
        const SizedBox(
          width: AppDimensions.spacingMd,
        ),
        Text(
          titulo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}