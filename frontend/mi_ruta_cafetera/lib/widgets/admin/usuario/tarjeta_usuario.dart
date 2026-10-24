
import 'package:flutter/material.dart';

import '../../../models/admin/usuario_admin.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
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

  @override
  Widget build(BuildContext context) {
    final eliminado = usuario.eliminado;

    return InkWell(
      onTap: () => _historial(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.adminBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.coffeeDark.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _avatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: AppColors.coffeeDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _dato(
                            Icons.mail_outline_rounded,
                            usuario.correoMostrado,
                            AppColors.secondary,
                          ),
                          if (!eliminado && usuario.ciudad.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _dato(
                              Icons.location_on_outlined,
                              usuario.ciudad,
                              AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                    _menu(context),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppColors.surface,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _etiqueta(
                      eliminado
                          ? 'Cuenta eliminada'
                          : usuario.activo
                              ? 'Cuenta activa'
                              : 'Cuenta inactiva',
                      eliminado
                          ? AppColors.textSecondary
                          : usuario.activo
                              ? AppColors.success
                              : AppColors.error,
                      eliminado
                          ? Icons.person_off_outlined
                          : usuario.activo
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_outline_rounded,
                    ),
                    if (!eliminado)
                      _etiqueta(
                        usuario.correoVerificado
                            ? 'Correo verificado'
                            : 'Correo pendiente',
                        usuario.correoVerificado
                            ? AppColors.success
                            : AppColors.warning,
                        usuario.correoVerificado
                            ? Icons.verified_rounded
                            : Icons.mark_email_unread_outlined,
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

  Widget _menu(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'Acciones del usuario',
        padding: EdgeInsets.zero,
        color: const Color(0xFFE9EFE9),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.adminBorder.withValues(alpha: 0.7),
          ),
        ),
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: AppColors.secondary,
          size: 27,
        ),
        onSelected: (accion) {
          if (accion == 'estado') onCambiarEstado();
          if (accion == 'eliminar') onEliminar();
        },
        itemBuilder: (_) => [
          if (!usuario.eliminado)
            PopupMenuItem(
              value: 'estado',
              child: _opcion(
                usuario.activo
                    ? Icons.pause_circle_outline_rounded
                    : Icons.check_circle_outline_rounded,
                usuario.activo ? 'Desactivar cuenta' : 'Activar cuenta',
                AppColors.secondary,
              ),
            ),
          if (!usuario.eliminado)
            PopupMenuItem(
              value: 'eliminar',
              child: _opcion(
                Icons.delete_outline_rounded,
                'Eliminar usuario',
                AppColors.error,
              ),
            ),
        ],
      );

  Widget _opcion(IconData icono, String texto, Color color) => Row(
        children: [
          Icon(icono, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );

  Widget _avatar() {
    final radio = AppDimensions.profileAvatarSmall / 2;
    final diametro = radio * 2;
    final avatar = usuario.avatar;

    Widget contenido;

    if (usuario.eliminado) {
      contenido = CircleAvatar(
        radius: radio,
        backgroundColor: AppColors.primaryDark,
        child: const Icon(
          Icons.person_off_outlined,
          color: Colors.white,
        ),
      );
    } else if (avatar?.usar == true) {
      contenido = ClipOval(
        child: SizedBox(
          width: diametro,
          height: diametro,
          child: CustomPaint(
            painter: AvatarCafeteroPainter(avatar!),
          ),
        ),
      );
    } else if (usuario.fotoPerfil.trim().isNotEmpty) {
      contenido = ClipOval(
        child: Image.network(
          usuario.fotoPerfil,
          width: diametro,
          height: diametro,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stack) => _inicial(radio),
        ),
      );
    } else {
      contenido = _inicial(radio);
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.adminBorder,
          width: 1.3,
        ),
      ),
      child: contenido,
    );
  }

  Widget _inicial(double radio) => CircleAvatar(
        radius: radio,
        backgroundColor: const Color(0xFF174B35),
        child: Text(
          usuario.nombre.trim().isEmpty
              ? '?'
              : usuario.nombre.trim()[0].toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFF9A3C),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _dato(IconData icono, String texto, Color color) => Row(
        children: [
          Icon(icono, color: color, size: 15),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      );

  Widget _etiqueta(String texto, Color color, IconData icono) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  void _historial(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.adminBorder),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.history_rounded,
              color: AppColors.secondary,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Historial del usuario',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _seccion('Información de la cuenta'),
              _historialDato('Nombre', usuario.nombreCompleto),
              _historialDato('Correo', usuario.correoMostrado),
              _historialDato('Ciudad', usuario.ciudad),
              _historialDato(
                'Fecha de creación',
                _fecha(usuario.creadoEn),
              ),
              _historialDato(
                'Estado',
                usuario.eliminado
                    ? 'Eliminada'
                    : usuario.activo
                        ? 'Activa'
                        : 'Inactiva',
              ),
              _seccion('Información de eliminación'),
              _historialDato(
                'Nombre original',
                usuario.usuarioNombreEliminado,
              ),
              _historialDato(
                'Correo original',
                usuario.usuarioCorreoEliminado,
              ),
              _historialDato(
                'Tipo',
                usuario.tipoEliminacion == 'administrador'
                    ? 'Por administrador'
                    : usuario.tipoEliminacion == 'usuario'
                        ? 'Voluntaria'
                        : null,
              ),
              _historialDato('Responsable', usuario.responsableNombre),
              _historialDato(
                'Fecha de eliminación',
                _fecha(usuario.fechaEliminacion ?? usuario.eliminadoAt),
              ),
              _historialDato('Motivo', usuario.motivoEliminacion),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion(String texto) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          texto,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _historialDato(String titulo, String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String? _fecha(DateTime? fecha) {
    if (fecha == null) return null;
    final f = fecha.toLocal();

    return '${f.day.toString().padLeft(2, '0')}/'
        '${f.month.toString().padLeft(2, '0')}/${f.year} '
        '${f.hour.toString().padLeft(2, '0')}:'
        '${f.minute.toString().padLeft(2, '0')}';
  }
}
