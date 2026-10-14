
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../models/admin/usuario_admin.dart';

class TarjetaUsuario extends StatelessWidget {
  final UsuarioAdmin usuario;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;

  const TarjetaUsuario({
    super.key,
    required this.usuario,
    required this.onCambiarEstado,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirAvatar(),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombreCompleto.isEmpty
                          ? 'Usuario sin nombre'
                          : usuario.nombreCompleto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingXs,
                    ),
                    Text(
                      usuario.correo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (usuario.ciudad.isNotEmpty) ...[
                      const SizedBox(
                        height: AppDimensions.spacingXs,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: AppDimensions.iconSm,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(
                            width: AppDimensions.spacingXs,
                          ),
                          Expanded(
                            child: Text(
                              usuario.ciudad,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Acciones del usuario',
                onSelected: (accion) {
                  if (accion == 'estado') {
                    onCambiarEstado();
                  } else if (accion == 'eliminar') {
                    onEliminar();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'estado',
                    child: Row(
                      children: [
                        Icon(
                          usuario.activo
                              ? Icons.pause_circle_outline
                              : Icons.check_circle_outline,
                          color: usuario.activo
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        const SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Text(
                          usuario.activo ? 'Desactivar' : 'Activar',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Text('Eliminar usuario'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          const Divider(
            color: AppColors.divider,
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Row(
            children: [
              Expanded(
                child: _construirEtiquetaEstado(),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Icon(
                usuario.correoVerificado
                    ? Icons.verified_rounded
                    : Icons.mark_email_unread_outlined,
                color: usuario.correoVerificado
                    ? AppColors.success
                    : AppColors.warning,
                size: AppDimensions.iconSm,
              ),
              const SizedBox(
                width: AppDimensions.spacingXs,
              ),
              Flexible(
                child: Text(
                  usuario.correoVerificado
                      ? 'Correo verificado'
                      : 'Correo pendiente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirAvatar() {
    return CircleAvatar(
      radius: AppDimensions.profileAvatarSmall / 2,
      backgroundColor: AppColors.orangeSoft,
      backgroundImage: usuario.fotoPerfil.isNotEmpty
          ? NetworkImage(usuario.fotoPerfil)
          : null,
      child: usuario.fotoPerfil.isEmpty
          ? Text(
              usuario.nombre.isNotEmpty
                  ? usuario.nombre[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          : null,
    );
  }

  Widget _construirEtiquetaEstado() {
    final color = usuario.activo
        ? AppColors.success
        : AppColors.error;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.badgeHorizontalPadding,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(
            AppDimensions.chipRadius,
          ),
        ),
        child: Text(
          usuario.activo ? 'Cuenta activa' : 'Cuenta inactiva',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
