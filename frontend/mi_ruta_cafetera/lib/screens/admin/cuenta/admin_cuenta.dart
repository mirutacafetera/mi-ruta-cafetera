import 'package:flutter/material.dart';

import '../../../controllers/admin/cuenta/cuenta_admin_controlador.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/cuenta/tarjeta_cuenta.dart';
import '../../../widgets/admin/cuenta/dato_cuenta.dart';
import '../../../widgets/admin/cuenta/opcion_cuenta.dart';
import 'cambiar_password.dart';
import 'editar_cuenta.dart';

class AdminCuenta extends StatelessWidget {
  final CuentaAdminController controller;

  const AdminCuenta({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final cuenta = controller.cuenta;

        if (controller.cargando) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.secondary,
            ),
          );
        }

        if (controller.error != null || cuenta == null) {
          return Center(
            child: Text(
              controller.error ??
                  'No hay información de la cuenta.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppDimensions.spacingXl,
          ),
          child: Column(
            children: [
              TarjetaCuenta(
                nombre: '${cuenta.nombre} ${cuenta.apellido}',
                correo: cuenta.correo,
                rol: cuenta.rol == 'admin'
                    ? 'Administrador'
                    : cuenta.rol,
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
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
                    AppDimensions.spacingMd,
                  ),
                  child: Column(
                    children: [
                      DatoCuenta(
                        icono: Icons.person_outline,
                        titulo: 'Nombre',
                        valor: cuenta.nombre,
                      ),
                      DatoCuenta(
                        icono: Icons.person_outline,
                        titulo: 'Apellido',
                        valor: cuenta.apellido,
                      ),
                      DatoCuenta(
                        icono: Icons.email_outlined,
                        titulo: 'Correo',
                        valor: cuenta.correo,
                      ),
                      DatoCuenta(
                        icono: Icons.phone_outlined,
                        titulo: 'Teléfono',
                        valor: cuenta.telefono.isEmpty
                            ? 'No registrado'
                            : cuenta.telefono,
                      ),
                      DatoCuenta(
                        icono:
                            Icons.admin_panel_settings_outlined,
                        titulo: 'Rol',
                        valor: cuenta.rol == 'admin'
                            ? 'Administrador'
                            : cuenta.rol,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              OpcionCuenta(
                icono: Icons.edit_outlined,
                titulo: 'Editar información',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarCuenta(
                        controller: controller,
                      ),
                    ),
                  );
                },
              ),
              OpcionCuenta(
                icono: Icons.lock_outline,
                titulo: 'Cambiar contraseña',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CambiarPassword(
                        correo: cuenta.correo,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}