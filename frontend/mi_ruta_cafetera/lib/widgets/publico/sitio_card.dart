import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

class SitioCard extends StatefulWidget {
  final SitioTuristicoModel sitio;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final String imagen;

  /// Indica si el sitio ya está en los favoritos del usuario.
  final bool esFavorito;

  /// Ancho de la tarjeta. Por omisión usa el ancho del carrusel
  /// (AppDimensions.sitioCardWidth); en la cuadrícula se pasa
  /// double.infinity para ocupar la celda.
  final double? ancho;

  const SitioCard({
    super.key,
    required this.sitio,
    required this.onFavorite,
    required this.onTap,
    required this.imagen,
    this.esFavorito = false,
    this.ancho,
  });

  @override
  State<SitioCard> createState() => _SitioCardState();
}

class _SitioCardState extends State<SitioCard> {
  bool _presionando = false;

  Color get _colorCategoria =>
      AppColors.getColorForCategory(widget.sitio.categoriaNombre);

  IconData get _iconoCategoria =>
      AppColors.getIconForCategory(widget.sitio.categoriaNombre);

  @override
  Widget build(BuildContext context) {
    final colorCategoria = _colorCategoria;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _presionando = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _presionando = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _presionando = false;
        });

        widget.onTap();
      },
      child: AnimatedScale(
        scale: _presionando ? 0.975 : 1.0,
        duration: const Duration(milliseconds: AppDimensions.animationFast),
        curve: Curves.easeOut,
        child: Container(
          width: widget.ancho ?? AppDimensions.sitioCardWidth,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.sitioCardRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirImagen(colorCategoria),
              _construirContenido(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGEN
  // ============================================================

  Widget _construirImagen(Color colorCategoria) {
    return SizedBox(
      height: AppDimensions.sitioImageHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.sitio.imagen.trim().isNotEmpty
              ? Image.network(
                  widget.sitio.imagen.trim(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      widget.imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _construirImagenRespaldo(colorCategoria);
                      },
                    );
                  },
                )
              : Image.asset(
                  widget.imagen,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _construirImagenRespaldo(colorCategoria);
                  },
                ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================
          // CATEGORÍA
          // ==================================================
          // La etiqueta ocupa como máximo el ancho de la tarjeta y recorta
          // el texto con puntos suspensivos, así no se desborda en
          // pantallas estrechas.
          Positioned(
            left: AppDimensions.spacingMd,
            right: AppDimensions.spacingMd,
            bottom: AppDimensions.spacingMd,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm + 2,
                  vertical: AppDimensions.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: colorCategoria,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconoCategoria,
                      size: AppDimensions.iconSm,
                      color: AppColors.textOnDark,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Flexible(
                      child: Text(
                        widget.sitio.categoriaNombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================
          // FAVORITO
          // ==================================================
          Positioned(
            top: AppDimensions.spacingMd,
            right: AppDimensions.spacingMd,
            child: Material(
              color: Colors.black.withValues(alpha: 0.28),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onFavorite,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: AppDimensions.circularButtonSmall,
                  height: AppDimensions.circularButtonSmall,
                  child: Icon(
                    widget.esFavorito
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: AppDimensions.iconMd,
                    color: widget.esFavorito
                        ? AppColors.secondary
                        : AppColors.textOnDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGEN DE RESPALDO
  // ============================================================

  Widget _construirImagenRespaldo(Color colorCategoria) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorCategoria, AppColors.coffeeDark],
        ),
      ),
      child: Center(
        child: Icon(
          _iconoCategoria,
          size: AppDimensions.iconLg + 12,
          color: AppColors.textOnDark.withValues(alpha: 0.90),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _construirContenido() {
    final tema = Theme.of(context).textTheme;
    final escala = MediaQuery.textScalerOf(context);

    final estiloNombre = tema.titleMedium?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w800,
      height: 1.15,
    );

    final estiloDescripcion = tema.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      height: 1.25,
    );

    // Botón e icono de ubicación en el color principal de la app, iguales
    // en todas las tarjetas. Solo la etiqueta de categoría conserva el
    // color de su categoría.
    //
    // Altura fija equivalente a 2 líneas de texto. Así el nombre y la
    // descripción ocupan siempre el mismo espacio y el botón queda a la
    // misma altura en todas las tarjetas, aunque el texto sea corto.
    // Se calcula con el tamaño de letra del dispositivo para que el
    // texto no se corte si el usuario lo agranda.
    final altoNombre =
        (escala.scale(estiloNombre?.fontSize ?? 16) * 1.15 * 2).ceilToDouble();

    final altoDescripcion =
        (escala.scale(estiloDescripcion?.fontSize ?? 12) * 1.25 * 2)
            .ceilToDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sitioContentPadding,
        AppDimensions.sitioContentPadding,
        AppDimensions.sitioContentPadding,
        AppDimensions.spacingSm + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: altoNombre,
            width: double.infinity,
            child: Text(
              widget.sitio.nombre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: estiloNombre,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXs + 2),

          SizedBox(
            height: altoDescripcion,
            width: double.infinity,
            child: Text(
              widget.sitio.descripcion.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: estiloDescripcion,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: AppDimensions.iconSm,
                color: AppColors.primary,
              ),

              const SizedBox(width: AppDimensions.spacingXs),

              Expanded(
                child: Text(
                  _textoUbicacion(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: widget.onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              icon: const Icon(Icons.explore_outlined, size: 17),
              label: const Tr(
                'Ver lugar',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UBICACIÓN
  // ============================================================

  String _textoUbicacion() {
    final ciudad = widget.sitio.ciudad.trim();

    final departamento = widget.sitio.departamento.trim();

    if (ciudad.isNotEmpty && departamento.isNotEmpty) {
      return '$ciudad, $departamento';
    }

    if (ciudad.isNotEmpty) {
      return ciudad;
    }

    if (departamento.isNotEmpty) {
      return departamento;
    }

    return Textos.t('Huila, Colombia');
  }
}