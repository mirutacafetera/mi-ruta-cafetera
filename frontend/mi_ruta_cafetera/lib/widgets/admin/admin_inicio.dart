import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminInicio extends StatelessWidget {
  final String nombre;
  final String email;
  final VoidCallback onAbrirMapa;
  final VoidCallback onGestionarSitios;

  const AdminInicio({
    super.key,
    required this.nombre,
    required this.email,
    required this.onAbrirMapa,
    required this.onGestionarSitios,
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
            height: AppDimensions.spacingXl + AppDimensions.spacingXs,
          ),

          // ==================================================
          // ICONO DE ADMINISTRADOR
          // ==================================================

          const Icon(
            Icons.admin_panel_settings,
            size: 70,
            color: AppColors.primary,
          ),

          const SizedBox(
            height: AppDimensions.spacingLg + AppDimensions.spacingXs / 2,
          ),

          // ==================================================
          // BIENVENIDA
          // ==================================================

          Text(
            'Bienvenido, $nombre',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingSm + 2,
          ),

          Text(
            'Panel de administración\nMi Ruta Mágica del Café',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.textLight,
              height: 1.4,
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingSection,
          ),

          // ==================================================
          // MAPA TURÍSTICO
          // ==================================================

          Card(
            color: AppColors.primary,
            elevation: AppDimensions.elevationFloating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: InkWell(
              onTap: onAbrirMapa,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingXl,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.map,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(
                      width: AppDimensions.spacingLg + AppDimensions.spacingXs / 2,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mapa turístico',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: AppDimensions.spacingXs + 1,
                          ),

                          Text(
                            'Visualiza los sitios turísticos, '
                            'categorías y rutas por carretera.',
                            style: TextStyle(
                              color: AppColors.white.withValues(
                                alpha: 0.75,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingXl + AppDimensions.spacingSm,
          ),

          // ==================================================
          // GESTIONAR SITIOS
          // ==================================================

          Card(
            color: AppColors.surface,
            elevation: AppDimensions.elevationButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
              side: const BorderSide(
                color: AppColors.divider,
              ),
            ),
            child: InkWell(
              onTap: onGestionarSitios,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(
                      width: AppDimensions.spacingLg,
                    ),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestionar sitios turísticos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(
                            height: AppDimensions.spacingXs + 1,
                          ),

                          Text(
                            'Crear, editar y administrar sitios turísticos.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingXl + AppDimensions.spacingSm,
          ),

          // ==================================================
          // INFORMACIÓN DEL ADMINISTRADOR
          // ==================================================

          Card(
            color: AppColors.surface,
            elevation: AppDimensions.elevationButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
              side: const BorderSide(
                color: AppColors.divider,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                AppDimensions.spacingLg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    width: AppDimensions.spacingLg,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingXs + 1,
                        ),

                        Text(
                          email,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingSection - AppDimensions.spacingXs / 2,
          ),
        ],
      ),
    );
  }
}