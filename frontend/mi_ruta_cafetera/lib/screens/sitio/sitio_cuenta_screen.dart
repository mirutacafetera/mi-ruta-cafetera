import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'sitio_recuperar_password_screen.dart';
import 'sitio_reportes_screen.dart';

class SitioCuentaScreen extends StatelessWidget {
  const SitioCuentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.sitioPagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: const Icon(
                  Icons.manage_accounts_rounded,
                  color: AppColors.sitioPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cuenta',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.sitioTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Administra el acceso a tu cuenta y comunícate con nuestro equipo.',
                style: TextStyle(
                  color: AppColors.sitioTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Recuperación de contraseña: se conserva.
              Card(
                color: AppColors.sitioSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioPanelCardRadius,
                  ),
                  side: const BorderSide(color: AppColors.sitioBorder),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.sitioPrimary,
                    size: 30,
                  ),
                  title: const Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.sitioTextPrimary,
                    ),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Actualiza la contraseña de tu cuenta.',
                      style: TextStyle(color: AppColors.sitioTextSecondary),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.sitioPrimary,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SitioRecuperarPasswordScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Nueva sección de reportes y sugerencias.
              Card(
                color: AppColors.sitioSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioPanelCardRadius,
                  ),
                  side: const BorderSide(color: AppColors.sitioBorder),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(
                    Icons.forum_outlined,
                    color: AppColors.sitioPrimary,
                    size: 30,
                  ),
                  title: const Text(
                    'Reportes y sugerencias',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.sitioTextPrimary,
                    ),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Comunica problemas, comparte ideas y consulta las respuestas.',
                      style: TextStyle(
                        color: AppColors.sitioTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.sitioPrimary,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SitioReportesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
