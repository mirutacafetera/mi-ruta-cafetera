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
            height: AppDimensions.spacingXl + AppDimensions.spacingSm / 2,
          ),

          // ==================================================
          // ICONO
          // ==================================================

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

          // ==================================================
          // NOMBRE
          // ==================================================

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

          // ==================================================
          // CORREO
          // ==================================================

          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingSection + AppDimensions.spacingXs,
          ),

          // ==================================================
          // INFORMACIÓN
          // ==================================================

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
                  // ------------------------------------------------
                  // NOMBRE
                  // ------------------------------------------------

                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),

                      const SizedBox(
                        width: AppDimensions.spacingMd + 2,
                      ),

                      const Text(
                        'Nombre',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Flexible(
                        child: Text(
                          nombre,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    height: AppDimensions.spacingSection - 2,
                    color: AppColors.divider,
                  ),

                  // ------------------------------------------------
                  // CORREO
                  // ------------------------------------------------

                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),

                      const SizedBox(
                        width: AppDimensions.spacingMd + 2,
                      ),

                      const Text(
                        'Correo',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Flexible(
                        child: Text(
                          email,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    height: AppDimensions.spacingSection - 2,
                    color: AppColors.divider,
                  ),

                  // ------------------------------------------------
                  // ROL
                  // ------------------------------------------------

                  Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings_outlined,
                        color: AppColors.primary,
                      ),

                      const SizedBox(
                        width: AppDimensions.spacingMd + 2,
                      ),

                      const Text(
                        'Rol',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        'Administrador',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}