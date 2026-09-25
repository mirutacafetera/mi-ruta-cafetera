import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../admin/admin_pantalla_acceso.dart';
import '../usuario/login_usuario_screen.dart';

class SeleccionRolScreen extends StatelessWidget {
  const SeleccionRolScreen({
    super.key,
  });

  // ============================================================
  // MENSAJE
  // ============================================================

  void _mostrarMensaje(
    BuildContext context,
    String mensaje,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // CONSTRUCCIÓN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.coffeeDark,
              AppColors.secondary,
              AppColors.coffeeLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.spacingXxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Card(
                  color: AppColors.surface,
                  elevation: AppDimensions.elevationHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusXxl,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingXxl + 4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ==================================================
                        // ICONO
                        // ==================================================

                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            color: AppColors.cream,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_cafe_rounded,
                            size: 50,
                            color: AppColors.secondary,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),

                        // ==================================================
                        // TITULO
                        // ==================================================

                        const Text(
                          'Mi Ruta Mágica del Café',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingSm + 2,
                        ),

                        const Text(
                          'Bienvenido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),

                        const Text(
                          'Selecciona cómo deseas ingresar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingSection - 2,
                        ),

                        // ==================================================
                        // VISITANTE
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightLarge,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginUsuarioScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.person_rounded,
                            ),
                            label: const Text(
                              'Soy visitante',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),

                        // ==================================================
                        // ADMINISTRADOR
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightLarge,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminPantallaAcceso(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.admin_panel_settings_rounded,
                            ),
                            label: const Text(
                              'Administrador',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),

                        // ==================================================
                        // SITIO TURÍSTICO
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightLarge,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _mostrarMensaje(
                                context,
                                'Acceso de sitio turístico próximamente',
                              );
                            },
                            icon: const Icon(
                              Icons.storefront_rounded,
                            ),
                            label: const Text(
                              'Sitio turístico',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(
                                color: AppColors.secondary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),

                        // ==================================================
                        // VOLVER
                        // ==================================================

                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                          ),
                          label: const Text(
                            'Volver',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),

                        // ==================================================
                        // PIE
                        // ==================================================

                        const Text(
                          'Mi Ruta Mágica del Café',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}