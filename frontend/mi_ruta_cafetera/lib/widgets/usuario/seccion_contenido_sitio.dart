import 'package:flutter/material.dart';

import '../../models/contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';
import 'detalle_sitio/componentes_detalle.dart';
import 'detalle_sitio/panel_detalle_adaptable.dart';

class SeccionContenidoSitio extends StatelessWidget {
  const SeccionContenidoSitio({
    super.key,
    required this.contenidos,
    this.onReproducirAudioguia,
  });

  final List<ContenidoModel> contenidos;
  final ValueChanged<ContenidoModel>? onReproducirAudioguia;

  @override
  Widget build(BuildContext context) {
    final visibles = contenidos.where((item) => item.activo).toList();

    if (visibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visibles.map(
            (contenido) => _ContenidoCard(
              contenido: contenido,
              onReproducirAudioguia: onReproducirAudioguia,
            ),
          ),
        ],
      ),
    );
  }
}

bool _contenidoTieneAudio(ContenidoModel contenido) {
  return contenido.audioGuias.any(
    (audio) => audio.url.trim().isNotEmpty,
  );
}

class _ContenidoCard extends StatelessWidget {
  const _ContenidoCard({
    required this.contenido,
    required this.onReproducirAudioguia,
  });

  final ContenidoModel contenido;
  final ValueChanged<ContenidoModel>? onReproducirAudioguia;

  List<String> get _imagenes => unirImagenesDetalle(
        contenido.imagenPrincipal,
        contenido.imagenes,
      );

  @override
  Widget build(BuildContext context) {
    final imagenes = _imagenes;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
      decoration: decoracionTarjetaDetalle(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _abrirDetalle(context, imagenes),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imagenes.isEmpty
                      ? const PlaceholderImagenDetalle(
                          icono: Icons.auto_stories_rounded,
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imagenes.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const PlaceholderImagenDetalle(
                                icono: Icons.broken_image_outlined,
                                compacto: true,
                              ),
                            ),
                            if (imagenes.length > 1)
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withValues(
                                      alpha: 0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusXl,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.photo_library_outlined,
                                        color: AppColors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Tr(
                                        '{0} fotos',
                                        args: [imagenes.length],
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contenido.titulo,
                        style: const TextStyle(
                          color: AppColors.sitioTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (contenido.descripcion.trim().isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          contenido.descripcion.trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.sitioTextSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Tr(
                            'Leer historia completa',
                            style: TextStyle(
                              color: AppColors.sitioPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.sitioPrimary,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_contenidoTieneAudio(contenido))
            _BotonEscucharHistoria(
              onPressed: onReproducirAudioguia == null
                  ? null
                  : () => onReproducirAudioguia!(contenido),
            ),
        ],
      ),
    );
  }

  void _abrirDetalle(
    BuildContext context,
    List<String> imagenes,
  ) {
    PanelDetalleAdaptable.mostrar<void>(
      context: context,
      titulo: contenido.titulo,
      icono: Icons.auto_stories_rounded,
      maxWidth: 820,
      builder: (panelContext) => _ContenidoDetalleHistoria(
        contenido: contenido,
        imagenes: imagenes,
        onEscuchar: onReproducirAudioguia == null
            ? null
            : () {
                // Se cierra el panel para que el reproductor flotante
                // de la pantalla del sitio quede visible.
                Navigator.of(panelContext).pop();
                onReproducirAudioguia!(contenido);
              },
      ),
    );
  }
}

class _BotonEscucharHistoria extends StatelessWidget {
  const _BotonEscucharHistoria({
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.headphones_rounded,
            color: AppColors.sitioPrimary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Tr(
              'Escuchar esta historia',
              style: TextStyle(
                color: AppColors.sitioPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          IconButton.filled(
            tooltip: Textos.t('Escuchar historia'),
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CONTENIDO DEL PANEL DE UNA HISTORIA
// =====================================================

class _ContenidoDetalleHistoria extends StatelessWidget {
  const _ContenidoDetalleHistoria({
    required this.contenido,
    required this.imagenes,
    required this.onEscuchar,
  });

  final ContenidoModel contenido;
  final List<String> imagenes;
  final VoidCallback? onEscuchar;

  @override
  Widget build(BuildContext context) {
    final descripcion = contenido.descripcion.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagenes.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: CarruselImagenesDetalle(
              imagenes: imagenes,
              aspectRatio: 4 / 3,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        Text(
          descripcion.isEmpty
              ? Textos.t('No hay una descripción adicional disponible.')
              : descripcion,
          style: const TextStyle(
            color: AppColors.sitioTextSecondary,
            fontSize: 15,
            height: 1.7,
          ),
        ),
        if (_contenidoTieneAudio(contenido)) ...[
          const SizedBox(height: AppDimensions.spacingXl),
          _BotonEscucharHistoria(onPressed: onEscuchar),
        ],
      ],
    );
  }
}
