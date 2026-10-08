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
          ),
          const Divider(height: 1),
          _accion(
            icono: Icons.article_rounded,
            titulo: 'Contenido',
            descripcion:
                'Administra la descripción y la información turística.',
          ),
          const Divider(height: 1),
          _accion(
            icono: Icons.photo_library_rounded,
            titulo: 'Multimedia',
            descripcion:
                'Gestiona fotografías y material visual.',
          ),
          const Divider(height: 1),
          _accion(
            icono: Icons.local_activity_rounded,
            titulo: 'Actividades',
            descripcion:
                'Agrega y administra las actividades de tu sitio.',
          ),
        ],
      ),
    );
  }

  Widget _accion({
    required IconData icono,
    required String titulo,
    required String descripcion,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMd,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
              child: Icon(
                icono,
                color: AppColors.white,
                size: AppDimensions.iconMd,
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingXs,
                  ),
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingSm,
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(
                  alpha: 0.75,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.coffeeDark,
                size: AppDimensions.iconSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}