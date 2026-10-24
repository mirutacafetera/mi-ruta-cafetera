
import 'package:flutter/material.dart';

import '../../../models/admin/resena_admin.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../sitio/sitio_avatar_perfil.dart';

class TarjetaResena extends StatelessWidget {
  final ResenaAdmin resena;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;

  const TarjetaResena({
    super.key,
    required this.resena,
    required this.onCambiarEstado,
    required this.onEliminar,
  });

  static const Color _bordeCafe = Color(0xFFB58A70);
  static const Color _fondoMenu = Color(0xFFE9EFE9);

  @override
  Widget build(BuildContext context) {
    final activa = resena.activo;

    return InkWell(
      onTap: () => _mostrarHistorial(context),
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontalSmall,
          vertical: AppDimensions.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.creamLight,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          border: Border.all(
            color: _bordeCafe,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coffeeDark.withValues(alpha: 0.06),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SitioAvatarPerfil(
                      fotoPerfil: resena.fotoPerfil,
                      nombre: resena.usuario,
                      radio: 22,
                      colorFondo: AppColors.primary,
                      colorIcono: Colors.white,
                      avatar: resena.avatar,
                    ),
                    const SizedBox(
                      width: AppDimensions.spacingMd,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resena.usuario,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingXs,
                          ),
                          Text(
                            resena.sitio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    _menu(context, activa),
                  ],
                ),
                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E5D3),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < resena.calificacion
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.secondary,
                          size: AppDimensions.iconMd,
                        ),
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingSm,
                      ),
                      Text(
                        '${resena.calificacion}/5',
                        style: const TextStyle(
                          color: AppColors.coffeeDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),
                Text(
                  resena.comentario,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),
                Container(
                  height: 1,
                  color: _bordeCafe.withValues(alpha: 0.45),
                ),
                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),
                Row(
                  children: [
                    _estado(activa),
                    const Spacer(),
                    if (resena.fecha != null)
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(
                              width: AppDimensions.spacingXs,
                            ),
                            Flexible(
                              child: Text(
                                _fecha(resena.fecha!),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, bool activa) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones de reseña',
      padding: EdgeInsets.zero,
      color: _fondoMenu,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _bordeCafe),
      ),
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: AppColors.secondary,
        size: 27,
      ),
      onSelected: (opcion) {
        if (opcion == 'estado') onCambiarEstado();
        if (opcion == 'eliminar') onEliminar();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'estado',
          child: _opcion(
            activa
                ? Icons.pause_circle_outline_rounded
                : Icons.check_circle_outline_rounded,
            activa ? 'Desactivar reseña' : 'Activar reseña',
            AppColors.secondary,
          ),
        ),
        PopupMenuItem(
          value: 'eliminar',
          child: _opcion(
            Icons.delete_outline_rounded,
            'Eliminar reseña',
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _opcion(
    IconData icono,
    String texto,
    Color color,
  ) {
    return Row(
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
  }

  Widget _estado(bool activa) {
    final color = activa ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(
          AppDimensions.chipRadius,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activa
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            activa ? 'Activa' : 'Inactiva',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarHistorial(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _bordeCafe),
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
                'Historial de la reseña',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _datoHistorial('Usuario', resena.usuario),
              _datoHistorial(
                'Sitio turístico',
                resena.sitio,
              ),
              _datoHistorial(
                'Calificación',
                '${resena.calificacion}/5',
              ),
              _datoHistorial(
                'Comentario',
                resena.comentario,
              ),
              _datoHistorial(
                'Estado actual',
                resena.activo ? 'Activa' : 'Inactiva',
              ),
              _datoHistorial(
                'Fecha de la reseña',
                resena.fecha == null
                    ? null
                    : _fecha(resena.fecha!),
              ),
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

  Widget _datoHistorial(String titulo, String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _fecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}
