import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../models/admin/usuario_admin.dart';
import '../../usuario/avatar_cafetero_painter.dart';

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

  static const Color _bordeCafe = Color(0xFFB58A70);

  @override
  Widget build(BuildContext context) {
    final eliminado = usuario.eliminado;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: _bordeCafe, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(alpha: 0.06),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _avatar(),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          eliminado &&
                                  (usuario.usuarioNombreEliminado ?? '')
                                      .isNotEmpty
                              ? usuario.usuarioNombreEliminado!
                              : usuario.nombreCompleto.isEmpty
                                  ? 'Usuario sin nombre'
                                  : usuario.nombreCompleto,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: AppColors.secondary,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                usuario.correoMostrado,
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
                        if (!eliminado && usuario.ciudad.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.secondary,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  usuario.ciudad,
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
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                    iconSize: 21,
                    iconColor: AppColors.secondary,
                    tooltip: 'Acciones del usuario',
                    onSelected: (accion) {
                      if (accion == 'estado') onCambiarEstado();
                      if (accion == 'eliminar') onEliminar();
                      if (accion == 'historial') {
                        _mostrarHistorial(context);
                      }
                    },
                    itemBuilder: (_) => [
                      if (!eliminado)
                        PopupMenuItem(
                          value: 'estado',
                          child: Text(
                            usuario.activo ? 'Desactivar' : 'Activar',
                          ),
                        ),
                      if (!eliminado)
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar usuario'),
                        ),
                      if (eliminado)
                        const PopupMenuItem(
                          value: 'historial',
                          child: Text('Ver historial'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.55),
                border: Border(
                  top: BorderSide(
                    color: _bordeCafe.withValues(alpha: 0.45),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _etiquetaEstado()),
                  if (!eliminado) ...[
                    const SizedBox(width: 6),
                    Icon(
                      usuario.correoVerificado
                          ? Icons.verified_rounded
                          : Icons.mark_email_unread_outlined,
                      color: usuario.correoVerificado
                          ? AppColors.success
                          : AppColors.warning,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        usuario.correoVerificado
                            ? 'Correo verificado'
                            : 'Correo pendiente',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    final radio = AppDimensions.profileAvatarSmall / 2;
    final diametro = radio * 2;
    final avatar = usuario.avatar;

    if (usuario.eliminado) {
      return CircleAvatar(
        radius: radio,
        backgroundColor: AppColors.border,
        child: const Icon(
          Icons.person_off_outlined,
          color: AppColors.textSecondary,
        ),
      );
    }

    if (avatar?.usar == true) {
      return ClipOval(
        child: SizedBox(
          width: diametro,
          height: diametro,
          child: CustomPaint(
            painter: AvatarCafeteroPainter(avatar!),
          ),
        ),
      );
    }

    if (usuario.fotoPerfil.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          usuario.fotoPerfil,
          width: diametro,
          height: diametro,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _avatarInicial(radio);
          },
        ),
      );
    }

    return _avatarInicial(radio);
  }

  Widget _avatarInicial(double radio) {
    return CircleAvatar(
      radius: radio,
      backgroundColor: AppColors.orangeSoft,
      child: Text(
        usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _etiquetaEstado() {
    final eliminado = usuario.eliminado;
    final color = eliminado
        ? AppColors.textSecondary
        : usuario.activo
            ? AppColors.success
            : AppColors.error;
    final texto = eliminado
        ? 'Cuenta eliminada'
        : usuario.activo
            ? 'Cuenta activa'
            : 'Cuenta inactiva';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.badgeHorizontalPadding,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(
          texto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _mostrarHistorial(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: const BorderSide(color: _bordeCafe, width: 1.2),
        ),
        title: const Text(
          'Historial de eliminación',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dato('Usuario original', usuario.usuarioNombreEliminado),
              _dato('Correo original', usuario.usuarioCorreoEliminado),
              _dato(
                'Tipo de eliminación',
                usuario.tipoEliminacion == 'administrador'
                    ? 'Por administrador'
                    : usuario.tipoEliminacion == 'usuario'
                        ? 'Voluntaria'
                        : null,
              ),
              _dato('Responsable', usuario.responsableNombre),
              _dato('Identificador del responsable', usuario.responsableId),
              _dato(
                'Fecha',
                _formatearFecha(
                  usuario.fechaEliminacion ?? usuario.eliminadoAt,
                ),
              ),
              _dato('Motivo', usuario.motivoEliminacion),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _dato(String titulo, String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String? _formatearFecha(DateTime? fecha) {
    if (fecha == null) return null;
    final local = fecha.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}