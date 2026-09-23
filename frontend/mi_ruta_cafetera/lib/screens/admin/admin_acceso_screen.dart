import 'package:flutter/material.dart';

import '../../services/admin/admin_login_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminAccesoScreen extends StatelessWidget {
  const AdminAccesoScreen({
    super.key,
  });

  // ============================================================
  // ABRIR LOGIN
  // ============================================================

  void _abrirLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
    );
  }

  // ============================================================
  // VOLVER
  // ============================================================

  void _volver(BuildContext context) {
    Navigator.pop(context);
  }

  // ============================================================
  // BUILD
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
                            Icons.admin_panel_settings,
                            size: 52,
                            color: AppColors.secondary,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingLg + 6,
                        ),

                        // ==================================================
                        // TÍTULO
                        // ==================================================

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
                          height: AppDimensions.spacingSm + 2,
                        ),

                        const Text(
                          'Esta sección está destinada únicamente '
                          'a administradores autorizados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingSection - 2,
                        ),

                        // ==================================================
                        // INICIAR SESIÓN
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightLarge,
                          child: ElevatedButton.icon(
                            onPressed: () => _abrirLogin(context),
                            icon: const Icon(
                              Icons.login,
                            ),
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
                          height: AppDimensions.spacingMd + 2,
                        ),

                        // ==================================================
                        // VOLVER
                        // ==================================================

                        TextButton.icon(
                          onPressed: () => _volver(context),
                          icon: const Icon(
                            Icons.arrow_back,
                          ),
                          label: const Text(
                            'Volver',
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