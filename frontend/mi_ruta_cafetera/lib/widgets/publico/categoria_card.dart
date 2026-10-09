import 'package:flutter/material.dart';

import '../../models/categoria_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/text_utils.dart';

class CategoriaCard extends StatefulWidget {
  final CategoriaModel categoria;
  final String? categoriaSeleccionada;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.categoriaSeleccionada,
    required this.onTap,
  });

  @override
  State<CategoriaCard> createState() =>
      _CategoriaCardState();
}

class _CategoriaCardState
    extends State<CategoriaCard> {
  bool _presionando = false;

  bool get _seleccionada {
    final seleccionada =
        widget.categoriaSeleccionada;

    if (seleccionada == null) {
      return false;
    }

    return TextUtils.normalizar(
          seleccionada,
        ) ==
        TextUtils.normalizar(
          widget.categoria.nombre,
        );
  }

  Color get _colorCategoria {
    return AppColors.getColorForCategory(
      widget.categoria.nombre,
    );
  }

  IconData get _iconoCategoria {
    return AppColors.getIconForCategory(
      widget.categoria.nombre,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _colorCategoria;

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
        scale:
            _presionando ? 0.96 : 1.0,
        duration: const Duration(
          milliseconds:
              AppDimensions.animationFast,
        ),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds:
                AppDimensions.animationFast,
          ),
          width:
              AppDimensions.categoryCardWidth,
          height:
              AppDimensions.categoryCardHeight,
          padding:
              const EdgeInsets.all(
            AppDimensions.spacingSm,
          ),
          decoration:
              BoxDecoration(
            color: _seleccionada
                ? color
                : AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.categoryRadius,
            ),
            border: Border.all(
              color: _seleccionada
                  ? color
                  : AppColors.border,
              width: _seleccionada
                  ? 1.4
                  : 1,
            ),
            boxShadow:
                _seleccionada
                    ? [
                        BoxShadow(
                          color: color
                              .withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 12,
                          offset:
                              const Offset(
                            0,
                            5,
                          ),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.black
                              .withValues(
                            alpha: 0.025,
                          ),
                          blurRadius: 8,
                          offset:
                              const Offset(
                            0,
                            3,
                          ),
                        ),
                      ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // ==================================================
              // ICONO
              // ==================================================

              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds:
                      AppDimensions
                          .animationFast,
                ),
                width:
                    AppDimensions
                        .categoryIconContainer,
                height:
                    AppDimensions
                        .categoryIconContainer,
                decoration:
                    BoxDecoration(
                  color: _seleccionada
                      ? AppColors.white
                          .withValues(
                          alpha: 0.16,
                        )
                      : AppColors
                          .getSoftColorForCategory(
                          widget
                              .categoria
                              .nombre,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                ),
                child: Icon(
                  _iconoCategoria,
                  size:
                      AppDimensions.categoryIcon,
                  color: _seleccionada
                      ? AppColors.textOnDark
                      : color,
                ),
              ),

              const SizedBox(
                height:
                    AppDimensions
                        .categoryContentGap,
              ),

              // ==================================================
              // NOMBRE
              // ==================================================

              Text(
                widget.categoria.nombre,
                maxLines: 2,
                textAlign:
                    TextAlign.center,
                overflow:
                    TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                  color: _seleccionada
                      ? AppColors
                          .textOnDark
                      : AppColors
                          .textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}