
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

  String get _titulo {
    return imagen.titulo.trim().isEmpty
        ? 'Fotografía'
        : imagen.titulo.trim();
  }

  String get _origen {
    return imagen.origen.trim().isEmpty
        ? 'Sitio turístico'
        : imagen.origen.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sitioSurface,
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioPanelCardRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _mostrarImagenAmpliada(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.sitioBorder,
            ),
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioPanelCardRadius,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imagen.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.sitioSurfaceGreen,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.sitioTextSecondary,
                              size: 36,
                            ),
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

                        return Container(
                          color: AppColors.sitioSurfaceSoft,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.sitioPrimary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.sitioPrimaryDark.withValues(
                            alpha: 0.88,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_outlined,
                          color: AppColors.sitioTextOnPrimary,
                          size: 17,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 78,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.68),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Text(
                        _titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.sitioAccent,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _origen,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.sitioTextSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.open_in_full_rounded,
                      color: AppColors.sitioPrimary,
                      size: 15,
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

  void _mostrarImagenAmpliada(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.sitioSurface,
          insetPadding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 850,
              maxHeight: 760,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.sitioAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.sitioTextPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar fotografía',
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.sitioTextSecondary,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      imagen.url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Padding(
                          padding: EdgeInsets.all(36),
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.sitioTextSecondary,
                            size: 48,
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

                        return const SizedBox(
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.sitioPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.sitioAccent,
                        size: 19,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _origen,
                          style: const TextStyle(
                            color: AppColors.sitioTextSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
