
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

  static const double _anchoTarjeta = 175;
  static const double _altoTarjeta = 215;

  @override
  Widget build(BuildContext context) {
    final visibles = contenidos.where((item) => item.activo).toList();

    if (visibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _altoTarjeta,
      child: ListView.separated(
        // SEPARACIÓN LATERAL DE LAS TARJETAS
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontal,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: visibles.length,
        separatorBuilder: (_, _) => const SizedBox(
          width: AppDimensions.spacingMd,
        ),
        itemBuilder: (context, index) {
          return SizedBox(
            width: _anchoTarjeta,
            child: _ContenidoCard(
              contenido: visibles[index],
              onReproducirAudioguia: onReproducirAudioguia,
            ),
          );
        },
      ),
    );
  }
}

bool _contenidoTieneAudio(ContenidoModel contenido) {
  return contenido.audioGuias.any(
    (audio) => audio.url.trim().isNotEmpty,
  );
}

// =====================================================
// TARJETA DE HISTORIA
// =====================================================

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
    final descripcion = contenido.descripcion.trim();

    return Container(
      decoration: decoracionTarjetaDetalle().copyWith(
        border: Border.all(
          color: AppColors.adminBorder.withValues(alpha: 0.60),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius - 1,
        ),
        child: Material(
          color: AppColors.sitioSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGEN DE LA HISTORIA
              InkWell(
                onTap: () => _abrirDetalle(context, imagenes),
                child: SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: imagenes.isEmpty
                      ? const PlaceholderImagenDetalle(
                          icono: Icons.auto_stories_rounded,
                          compacto: true,
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
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withValues(
                                      alpha: 0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.photo_library_outlined,
                                        color: AppColors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${imagenes.length}',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 10,
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
              ),

              // INFORMACIÓN DE LA HISTORIA
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 7, 9, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contenido.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.sitioTextPrimary,
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Expanded(
                        child: Text(
                          descripcion.isEmpty
                              ? Textos.t(
                                  'Descubre esta historia del lugar.',
                                )
                              : descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.sitioTextSecondary,
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ),

                      // LEER HISTORIA Y ESCUCHAR AUDIO
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _abrirDetalle(
                                context,
                                imagenes,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Tr(
                                      'Leer historia',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.sitioPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.sitioPrimary,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_contenidoTieneAudio(contenido))
                            Material(
                              color: AppColors.sitioPrimary,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: onReproducirAudioguia == null
                                    ? null
                                    : () => onReproducirAudioguia!(
                                          contenido,
                                        ),
                                customBorder: const CircleBorder(),
                                child: const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: Icon(
                                    Icons.headphones_rounded,
                                    color: AppColors.sitioTextOnPrimary,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                Navigator.of(panelContext).pop();
                onReproducirAudioguia!(contenido);
              },
      ),
    );
  }
}

// =====================================================
// CONTENIDO COMPLETO DE LA HISTORIA
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
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLg,
            ),
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
          _BotonEscucharHistoria(
            onPressed: onEscuchar,
          ),
        ],
      ],
    );
  }
}

// =====================================================
// BOTÓN PARA ESCUCHAR LA HISTORIA
// =====================================================

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
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
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
