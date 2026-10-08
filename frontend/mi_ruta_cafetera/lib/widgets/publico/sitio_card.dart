import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SitioCard extends StatefulWidget {
  final SitioTuristicoModel sitio;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final String imagen;

  const SitioCard({
    super.key,
    required this.sitio,
    required this.onFavorite,
    required this.onTap,
    required this.imagen,
  });

  @override
  State<SitioCard> createState() =>
      _SitioCardState();
}

class _SitioCardState
    extends State<SitioCard> {
  bool _presionando = false;

  Color get _colorCategoria =>
      AppColors.getColorForCategory(
        widget.sitio.categoriaNombre,
      );

  IconData get _iconoCategoria =>
      AppColors.getIconForCategory(
        widget.sitio.categoriaNombre,
      );

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorCategoria =
        _colorCategoria;

    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _presionando = true;
        });
      },
      onTapCancel:
          () {
        setState(() {
          _presionando = false;
        });
      },
      onTapUp:
          (_) {
        setState(() {
          _presionando = false;
        });

        widget.onTap();
      },
      child:
          AnimatedScale(
        scale:
            _presionando
                ? 0.975
                : 1.0,
        duration:
            const Duration(
          milliseconds:
              AppDimensions.animationFast,
        ),
        curve:
            Curves.easeOut,
        child:
            Container(
          width:
              AppDimensions.sitioCardWidth,
          decoration:
              BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.sitioCardRadius,
            ),
            border:
                Border.all(
              color:
                  AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.cardShadow,
                blurRadius:
                    14,
                offset:
                    const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          clipBehavior:
              Clip.antiAlias,
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _construirImagen(
                colorCategoria,
              ),
              _construirContenido(
                colorCategoria,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGEN
  // ============================================================

  Widget _construirImagen(
    Color colorCategoria,
  ) {
    return SizedBox(
      height:
          AppDimensions.sitioImageHeight,
      width:
          double.infinity,
      child:
          Stack(
        fit:
            StackFit.expand,
        children: [
          Image.asset(
            widget.imagen,
            fit:
                BoxFit.cover,
            errorBuilder:
                (_, _, _) {
              return _construirImagenRespaldo(
                colorCategoria,
              );
            },
          ),

          Positioned.fill(
            child:
                DecoratedBox(
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(
                      alpha: 0.48,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================
          // CATEGORÍA
          // ==================================================

          Positioned(
            left:
                AppDimensions.spacingMd,
            bottom:
                AppDimensions.spacingMd,
            child:
                Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    AppDimensions.spacingSm + 2,
                vertical:
                    AppDimensions.spacingXs + 2,
              ),
              decoration:
                  BoxDecoration(
                color:
                    colorCategoria,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child:
                  Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    _iconoCategoria,
                    size:
                        AppDimensions.iconSm,
                    color:
                        AppColors.textOnDark,
                  ),
                  const SizedBox(
                    width:
                        AppDimensions.spacingXs,
                  ),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 165,
                    ),
                    child:
                        Text(
                      widget.sitio.categoriaNombre,
                      maxLines:
                          1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                        color:
                            AppColors.textOnDark,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================================================
          // FAVORITO
          // ==================================================

          Positioned(
            top:
                AppDimensions.spacingMd,
            right:
                AppDimensions.spacingMd,
            child:
                Material(
              color:
                  Colors.black.withValues(
                alpha: 0.28,
              ),
              shape:
                  const CircleBorder(),
              child:
                  InkWell(
                onTap:
                    widget.onFavorite,
                customBorder:
                    const CircleBorder(),
                child:
                    const SizedBox(
                  width:
                      AppDimensions.circularButtonSmall,
                  height:
                      AppDimensions.circularButtonSmall,
                  child:
                      Icon(
                    Icons.favorite_border_rounded,
                    size:
                        AppDimensions.iconMd,
                    color:
                        AppColors.textOnDark,
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

  Widget _construirImagenRespaldo(
    Color colorCategoria,
  ) {
    return Container(
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            colorCategoria,
            AppColors.coffeeDark,
          ],
        ),
      ),
      child:
          Center(
        child:
            Icon(
          _iconoCategoria,
          size:
              AppDimensions.iconLg + 12,
          color:
              AppColors.textOnDark.withValues(
            alpha: 0.90,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _construirContenido(
    Color colorCategoria,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        AppDimensions.sitioContentPadding,
        AppDimensions.sitioContentPadding,
        AppDimensions.sitioContentPadding,
        AppDimensions.spacingSm + 2,
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            widget.sitio.nombre,
            maxLines:
                2,
            overflow:
                TextOverflow.ellipsis,
            style:
                Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w800,
              height:
                  1.15,
            ),
          ),

          if (widget.sitio.descripcion
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height:
                  AppDimensions.spacingXs + 2,
            ),
            Text(
              widget.sitio.descripcion,
              maxLines:
                  1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                color:
                    AppColors.textSecondary,
                height:
                    1.25,
              ),
            ),
          ],

          const SizedBox(
            height:
                AppDimensions.spacingSm,
          ),

          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size:
                    AppDimensions.iconSm,
                color:
                    colorCategoria,
              ),

              const SizedBox(
                width:
                    AppDimensions.spacingXs,
              ),

              Expanded(
                child:
                    Text(
                  _textoUbicacion(),
                  maxLines:
                      1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                    color:
                        AppColors.textSecondary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                AppDimensions.spacingSm,
          ),

          SizedBox(
            width:
                double.infinity,
            height:
                38,
            child:
                OutlinedButton.icon(
              onPressed:
                  widget.onTap,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    colorCategoria,
                side:
                    BorderSide(
                  color:
                      colorCategoria.withValues(
                    alpha: 0.45,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      AppDimensions.spacingMd,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
              ),
              icon:
                  const Icon(
                Icons.explore_outlined,
                size:
                    17,
              ),
              label:
                  const Text(
                'Ver lugar',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
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
    final ciudad =
        widget.sitio.ciudad.trim();

    final departamento =
        widget.sitio.departamento.trim();

    if (ciudad.isNotEmpty &&
        departamento.isNotEmpty) {
      return '$ciudad, $departamento';
    }

    if (ciudad.isNotEmpty) {
      return ciudad;
    }

    if (departamento.isNotEmpty) {
      return departamento;
    }

    return 'Huila, Colombia';
  }
}