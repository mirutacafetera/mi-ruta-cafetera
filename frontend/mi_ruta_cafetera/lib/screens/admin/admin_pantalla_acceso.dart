import 'package:flutter/material.dart';

import '../../screens/admin/admin_inicio_sesion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/auth/escenario_login.dart';

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
    return EscenarioLogin(
      titulo: 'Acceso de administrador',
      descripcion:
          'Esta sección está destinada únicamente a administradores autorizados.',
      children: [
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLarge,
          child: ElevatedButton.icon(
            onPressed: () => _abrirInicioSesion(context),
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
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
