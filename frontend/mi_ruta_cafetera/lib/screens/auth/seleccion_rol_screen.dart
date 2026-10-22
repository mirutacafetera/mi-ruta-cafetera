import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/auth/escenario_login.dart';
import '../admin/admin_pantalla_acceso.dart';
import '../sitio/sitio_login_screen.dart';
import '../usuario/login_usuario_screen.dart';
import '../../l10n/textos.dart';

class SeleccionRolScreen extends StatelessWidget {
  const SeleccionRolScreen({
    super.key,
  });

  // ============================================================
  // CONSTRUCCIÓN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return EscenarioLogin(
      titulo: Textos.t('Bienvenido'),
      descripcion: Textos.t('Selecciona cómo deseas ingresar'),
      children: [
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
                  builder: (context) => const LoginUsuarioScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.person_rounded,
            ),
            label: const Tr(
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
                  builder: (context) => const AdminPantallaAcceso(),
                ),
              );
            },
            icon: const Icon(
              Icons.admin_panel_settings_rounded,
            ),
            label: const Tr(
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SitioLoginScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.storefront_rounded,
            ),
            label: const Tr(
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
          height: AppDimensions.spacingMd,
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
          label: const Tr(
            'Volver',
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
