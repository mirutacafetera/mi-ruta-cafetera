
import 'package:flutter/material.dart';

import '../../../models/admin/reporte_admin.dart';
import '../../../models/admin/reporte_sitio_admin.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../sitio/sitio_avatar_perfil.dart';

class TarjetaReporte extends StatelessWidget {
  final ReporteAdmin? reporte;
  final ReporteSitioAdmin? reporteSitio;
  final VoidCallback onTap;

  const TarjetaReporte({
    super.key,
    this.reporte,
    this.reporteSitio,
    required this.onTap,
  }) : assert(
          reporte != null || reporteSitio != null,
          'Debes proporcionar un reporte de usuario o de sitio.',
        ),
       assert(
          reporte == null || reporteSitio == null,
          'Solo debes proporcionar un tipo de reporte.',
        );

  static const Color _bordeCafe = Color(0xFFB58A70);

  String get _estado => reporte?.estado ?? reporteSitio!.estado;

  String get _asunto => reporte?.asunto ?? reporteSitio!.asunto;

  String get _descripcion =>
      reporte?.mensaje ?? reporteSitio!.mensaje;

  String get _nombre {
    if (reporteSitio != null) {
      return reporteSitio!.nombreSitio;
    }

    final nombre = reporte!.nombreCompleto.trim();
    return nombre.isNotEmpty ? nombre : 'Usuario sin nombre';
  }

  String get _detalle {
    if (reporteSitio != null) {
      return 'Categoría: ${reporteSitio!.nombreCategoria}';
    }

    final correo = reporte!.correoUsuario.trim();
    return correo.isNotEmpty ? correo : 'Correo no disponible';
  }

  Color get _colorEstado {
    switch (_estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_revision':
        return Colors.blue;
      case 'resuelto':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _textoEstado {
    switch (_estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_revision':
        return 'En revisión';
      case 'resuelto':
        return 'Resuelto';
      default:
        return _estado;
    }
  }

  // Los reportes de usuarios conservan su foto y avatar.
  // Los reportes de sitios muestran la foto del sitio o su categoría.
  Widget _construirAvatar() {
    if (reporte != null) {
      return SitioAvatarPerfil(
        fotoPerfil: reporte!.fotoPerfil,
        nombre: reporte!.nombreCompleto,
        radio: 27,
        colorFondo: AppColors.primary,
        colorIcono: Colors.white,
        avatar: reporte!.avatar,
      );
    }

    final sitio = reporteSitio!;
    final foto = sitio.fotoSitio;

    final colorCategoria = AppColors.getColorForCategory(
      sitio.nombreCategoria,
    );

    final iconoCategoria = AppColors.getIconForCategory(
      sitio.nombreCategoria,
    );

    Widget mostrarCategoria() {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: colorCategoria.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(
            color: colorCategoria.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        child: Icon(
          iconoCategoria,
          color: colorCategoria,
          size: 29,
        ),
      );
    }

    if (foto == null || foto.trim().isEmpty) {
      return mostrarCategoria();
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _bordeCafe,
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          foto,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return mostrarCategoria();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado;

    final fecha = reporte?.createdAt ?? reporteSitio?.createdAt;

    return Card(
      color: AppColors.creamLight,
      elevation: 2,
      shadowColor: AppColors.coffeeDark.withValues(alpha: 0.10),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        side: const BorderSide(
          color: _bordeCafe,
          width: 1.4,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.spacingMd,
          ),
          child: Row(
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
                      _asunto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Text(
                      _nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _detalle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    Text(
                      _descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),
                    Wrap(
                      spacing: AppDimensions.spacingSm,
                      runSpacing: AppDimensions.spacingSm,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorEstado.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: colorEstado.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Text(
                            _textoEstado,
                            style: TextStyle(
                              color: colorEstado,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (fecha != null)
                          Text(
                            '${fecha.day.toString().padLeft(2, '0')}/'
                            '${fecha.month.toString().padLeft(2, '0')}/'
                            '${fecha.year}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondary,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
