import 'package:flutter/material.dart';

import '../../models/sitio/sitio_multimedia_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaMultimediaSitio extends StatelessWidget {
  final SitioMultimediaModel imagen;

  const TarjetaMultimediaSitio({
    super.key,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLg,
      ),
      child: Container(
        color: AppColors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imagen.url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textSecondary,
                    size: AppDimensions.iconLg,
                  ),
                );
              },
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingMd,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black.withValues(
                        alpha: 0.75,
                      ),
                    ],
                  ),
                ),
                child: Text(
                  imagen.titulo.trim().isEmpty
                      ? 'Fotografía'
                      : imagen.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}