import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class BannerCuenta extends StatefulWidget {
  final VoidCallback onLogin;

  const BannerCuenta({
    super.key,
    required this.onLogin,
  });

  @override
  State<BannerCuenta> createState() =>
      _BannerCuentaState();
}

class _BannerCuentaState
    extends State<BannerCuenta> {
  bool _presionando = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap:
          widget.onLogin,
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
      },
      child:
          AnimatedScale(
        scale:
            _presionando
                ? 0.985
                : 1.0,
        duration:
            const Duration(
          milliseconds: 160,
        ),
        curve:
            Curves.easeOut,
        child:
            Container(
          padding:
              const EdgeInsets.all(
            AppDimensions.spacingXl + 2,
          ),
          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                AppColors.secondary,
                AppColors.coffeeLight,
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusXxl,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.secondary.withValues(
                  alpha: 0.20,
                ),
                blurRadius:
                    18,
                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),
          child:
              Row(
            children: [
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vive la experiencia completa',
                      style:
                          TextStyle(
                        color:
                            AppColors.white,
                        fontSize:
                            20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.spacingSm,
                    ),

                    Text(
                      'Inicia sesión para guardar '
                      'tus lugares favoritos, '
                      'organizar tus rutas y '
                      'disfrutar una experiencia '
                      'más personalizada.',
                      style:
                          TextStyle(
                        color:
                            AppColors.white.withValues(
                          alpha: 0.82,
                        ),
                        fontSize:
                            13,
                        height:
                            1.45,
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.spacingMd + 4,
                    ),

                    AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds:
                            160,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.white.withValues(
                          alpha:
                              _presionando
                                  ? 0.20
                                  : 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        border:
                            Border.all(
                          color:
                              AppColors.white.withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ),
                      child:
                          TextButton.icon(
                        onPressed:
                            widget.onLogin,
                        style:
                            TextButton.styleFrom(
                          foregroundColor:
                              AppColors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                AppDimensions.spacingMd + 2,
                            vertical:
                                AppDimensions.spacingSm + 2,
                          ),
                        ),
                        icon:
                            const Icon(
                          Icons.login_rounded,
                          size:
                              19,
                        ),
                        label:
                            const Text(
                          'Iniciar sesión',
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
              ),

              const SizedBox(
                width:
                    AppDimensions.spacingMd,
              ),

              _construirMarcaDifuminada(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MARCA DIFUMINADA
  // ============================================================

  Widget _construirMarcaDifuminada() {
    return SizedBox(
      width: 92,
      height: 105,
      child:
          Stack(
        alignment:
            Alignment.center,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              30,
            ),
            child:
                BackdropFilter(
              filter:
                  ImageFilter.blur(
                sigmaX:
                    5,
                sigmaY:
                    5,
              ),
              child:
                  Container(
                width:
                    84,
                height:
                    84,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.white.withValues(
                    alpha: 0.08,
                  ),
                  shape:
                      BoxShape.circle,
                ),
              ),
            ),
          ),

          Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.route_rounded,
                size:
                    42,
                color:
                    AppColors.white.withValues(
                  alpha: 0.20,
                ),
              ),
              const SizedBox(
                height:
                    2,
              ),
              Text(
                'MI RUTA',
                style:
                    TextStyle(
                  color:
                      AppColors.white.withValues(
                    alpha: 0.20,
                  ),
                  fontSize:
                      9,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing:
                      1.2,
                ),
              ),
              Text(
                'CAFETERA',
                style:
                    TextStyle(
                  color:
                      AppColors.white.withValues(
                    alpha: 0.20,
                  ),
                  fontSize:
                      8,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing:
                      0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}