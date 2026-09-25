import 'package:flutter/material.dart';

import '../../screens/admin/admin_inicio_sesion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminPantallaAcceso extends StatelessWidget {
  const AdminPantallaAcceso({super.key});

  void _abrirInicioSesion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminInicioSesion(),
      ),
    );
  }

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
                      AppDimensions.spacingXxl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          size: 70,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingLg,
                        ),
                        const Text(
                          'Acceso de administrador',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        const Text(
                          'Esta sección está destinada únicamente '
                          'a administradores autorizados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingSection,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightLarge,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _abrirInicioSesion(context),
                            icon: const Icon(Icons.login),
                            label: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Volver'),
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