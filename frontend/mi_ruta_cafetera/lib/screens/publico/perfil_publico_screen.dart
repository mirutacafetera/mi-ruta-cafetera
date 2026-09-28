import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class PerfilPublicoScreen extends StatelessWidget {
  const PerfilPublicoScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Mi perfil',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppDimensions.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingXxl,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGreen,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.heroRadius,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: AppDimensions.profileAvatarSize,
                      height: AppDimensions.profileAvatarSize,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),
                    const Text(
                      'Tu perfil de viajero',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    const Text(
                      'Inicia sesión para disfrutar '
                      'una experiencia personalizada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textOnDarkSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: AppDimensions.sectionGap,
              ),
              const Text(
                'Accede a tu cuenta',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              const Text(
                'Guarda tus experiencias y disfruta '
                'tu recorrido por el Huila.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              SizedBox(
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/login-usuario',
                    );
                  },
                  icon: const Icon(
                    Icons.login_rounded,
                  ),
                  label: const Text(
                    'Iniciar sesión',
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              SizedBox(
                height: AppDimensions.buttonHeightLarge,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/registro-usuario',
                    );
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                  ),
                  label: const Text(
                    'Crear una cuenta',
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.sectionGap,
              ),
              Container(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingXl,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.explore_rounded,
                      color: AppColors.secondary,
                      size: AppDimensions.iconLg,
                    ),
                    SizedBox(
                      width: AppDimensions.spacingMd,
                    ),
                    Expanded(
                      child: Text(
                        'Explora lugares, descubre nuevas '
                        'experiencias y construye tu propia '
                        'ruta por el Huila.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}