import 'package:flutter/material.dart';

import '../../../controllers/admin/cuenta/cuenta_admin_controlador.dart';
import '../../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/cuenta/foto_perfil.dart';
import '../../../widgets/admin/cuenta/dato_cuenta.dart';
import '../../../widgets/admin/cuenta/opcion_cuenta.dart';
import 'cambiar_password.dart';
import 'editar_cuenta.dart';

class AdminCuenta extends StatelessWidget {
  final CuentaAdminController controller;
  final FotoPerfilAdminControlador fotoPerfilControlador;
  final VoidCallback onCerrarSesion;

  const AdminCuenta({
    super.key,
    required this.controller,
    required this.fotoPerfilControlador,
    required this.onCerrarSesion,
  });

  Future<void> _cambiarFoto(BuildContext context) async {
    final resultado = await fotoPerfilControlador.seleccionarFoto();

    if (!context.mounted) return;

    if (resultado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil actualizada.'),
        ),
      );
    } else if (fotoPerfilControlador.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fotoPerfilControlador.error!),
        ),
      );
    }
  }

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
            child: Padding(
              padding: const EdgeInsets.all(
                AppDimensions.spacingXl,
              ),
              child: Text(
                controller.error ?? 'No hay información de la cuenta.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.spacingLg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        AppDimensions.spacingXl,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXxl,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondary,
                                width: 3,
                              ),
                            ),
                            child: FotoPerfil(
                              controlador: fotoPerfilControlador,
                              radio: 48,
                              editable: true,
                              onTap: () => _cambiarFoto(context),
                            ),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                          Text(
                            '${cuenta.nombre} ${cuenta.apellido}'.trim(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingSm,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                              const SizedBox(
                                width: AppDimensions.spacingSm,
                              ),
                              Flexible(
                                child: Text(
                                  cuenta.correo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingLg,
                              vertical: AppDimensions.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusPill,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  color: AppColors.white,
                                  size: 17,
                                ),
                                const SizedBox(
                                  width: AppDimensions.spacingSm,
                                ),
                                Text(
                                  cuenta.rol == 'admin'
                                      ? 'Administrador'
                                      : cuenta.rol,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingXl,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingLg,
                        vertical: AppDimensions.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        border: Border.all(
                          color: AppColors.coffeeLight.withValues(
                            alpha: 0.55,
                          ),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coffeeDark.withValues(
                              alpha: 0.07,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          DatoCuenta(
                            icono: Icons.person_outline_rounded,
                            titulo: 'Nombre',
                            valor: cuenta.nombre,
                          ),
                          const Divider(
                            color: AppColors.divider,
                            height: 1,
                          ),
                          DatoCuenta(
                            icono: Icons.badge_outlined,
                            titulo: 'Apellido',
                            valor: cuenta.apellido,
                          ),
                          const Divider(
                            color: AppColors.divider,
                            height: 1,
                          ),
                          DatoCuenta(
                            icono: Icons.email_outlined,
                            titulo: 'Correo electrónico',
                            valor: cuenta.correo,
                          ),
                          const Divider(
                            color: AppColors.divider,
                            height: 1,
                          ),
                          DatoCuenta(
                            icono: Icons.phone_outlined,
                            titulo: 'Teléfono',
                            valor: cuenta.telefono.isEmpty
                                ? 'No registrado'
                                : cuenta.telefono,
                          ),
                          const Divider(
                            color: AppColors.divider,
                            height: 1,
                          ),
                          DatoCuenta(
                            icono: Icons.admin_panel_settings_outlined,
                            titulo: 'Rol de usuario',
                            valor: cuenta.rol == 'admin'
                                ? 'Administrador'
                                : cuenta.rol,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingXl,
                    ),
                    const Text(
                      'Configuración de la cuenta',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),
                    OpcionCuenta(
                      icono: Icons.edit_rounded,
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
                      icono: Icons.lock_outline_rounded,
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
                    OpcionCuenta(
                      icono: Icons.logout_rounded,
                      titulo: 'Cerrar sesión',
                      onTap: onCerrarSesion,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}