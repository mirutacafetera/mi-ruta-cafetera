import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'tarjeta_seccion_sitio.dart';

class AccionesDashboardSitio extends StatelessWidget {
  final bool esEscritorio;

  const AccionesDashboardSitio({
    super.key,
    required this.esEscritorio,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaSeccionSitio(
      titulo: 'Gestiona tu experiencia',
      subtitulo:
          'Accede rápidamente a las principales herramientas de tu sitio.',
      icono: Icons.auto_awesome_rounded,
      child: Column(
        children: [
          _accion(
            icono: Icons.storefront_rounded,
            titulo: 'Mi sitio',
            descripcion:
                'Consulta y actualiza la información principal.',
            colorIcono: AppColors.sitioPrimary,
            fondoIcono: AppColors.sitioSurfaceGreen,
          ),
          _separador(),
          _accion(
            icono: Icons.article_rounded,
            titulo: 'Contenido',
            descripcion:
                'Administra la descripción y la información turística.',
            colorIcono: AppColors.sitioInfo,
            fondoIcono: AppColors.sitioInfoSoft,
          ),
          _separador(),
          _accion(
            icono: Icons.photo_library_rounded,
            titulo: 'Multimedia',
            descripcion:
                'Gestiona fotografías y material visual.',
            colorIcono: AppColors.sitioWarning,
            fondoIcono: AppColors.sitioWarningSoft,
          ),
          _separador(),
          _accion(
            icono: Icons.local_activity_rounded,
            titulo: 'Actividades',
            descripcion:
                'Agrega y administra las actividades de tu sitio.',
            colorIcono: AppColors.sitioSuccess,
            fondoIcono: AppColors.sitioSuccessSoft,
          ),
        ],
      ),
    );
  }

  Widget _separador() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.sitioDivider,
      indent: 58,
    );
  }

  Widget _accion({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color colorIcono,
    required Color fondoIcono,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioPanelCardRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.sitioPanelCardGap,
          horizontal: 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: fondoIcono,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icono,
                color: colorIcono,
                size: AppDimensions.sitioActionIconSize + 2,
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.sitioTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.sitioSurfaceSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.sitioPrimary,
                size: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}