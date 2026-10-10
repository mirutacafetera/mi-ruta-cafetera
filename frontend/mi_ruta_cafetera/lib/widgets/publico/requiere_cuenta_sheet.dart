import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class RequiereCuentaSheet {
  RequiereCuentaSheet._();

  static void mostrar({
    required BuildContext context,
    required VoidCallback onIniciarSesion,

    /// Acción del botón "Crear mi cuenta".
    /// Si no se envía, se usa onIniciarSesion (comportamiento anterior).
    VoidCallback? onCrearCuenta,

    /// Textos opcionales. Por defecto se conserva el mensaje de
    /// favoritos.
    String titulo = 'Guarda tus lugares favoritos',
    String mensaje =
        'Crea una cuenta gratuita para guardar '
        'lugares, organizar tus rutas y disfrutar '
        'de una experiencia personalizada.',
    IconData icono = Icons.favorite_rounded,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingXxl,
            AppDimensions.spacingMd + 6,
            AppDimensions.spacingXxl,
            AppDimensions.spacingSection - 2,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                AppDimensions.radiusXxl + 6,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSm,
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  color: AppColors.secondary,
                  size: 35,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingMd + 6,
              ),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm + 2,
              ),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingLg + 6,
              ),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onIniciarSesion();
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  (onCrearCuenta ?? onIniciarSesion)();
                },
                child: const Text(
                  'Crear mi cuenta',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}