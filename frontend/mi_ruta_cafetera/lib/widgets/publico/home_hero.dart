import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class HomeHero extends StatefulWidget {
  final VoidCallback onLogin;

  const HomeHero({
    super.key,
    required this.onLogin,
  });

  @override
  State<HomeHero> createState() =>
      _HomeHeroState();
}

class _HomeHeroState
    extends State<HomeHero> {
  late final PageController
      _pageController;

  Timer? _carruselTimer;

  int _paginaActual = 0;

  static const List<_HeroImagen>
      _imagenes = [
    _HeroImagen(
      imagen:
          'assets/images/sitios/cafe.jpg',
      titulo:
          'Descubre la magia del café',
      subtitulo:
          'Sabores, fincas y experiencias que nacen en el Huila.',
    ),
    _HeroImagen(
      imagen:
          'assets/images/sitios/naturaleza.jpeg',
      titulo:
          'Naturaleza para explorar',
      subtitulo:
          'Senderos, montañas y paisajes para vivir el territorio.',
    ),
    _HeroImagen(
      imagen:
          'assets/images/sitios/cultura.jpg',
      titulo:
          'Historias que permanecen',
      subtitulo:
          'Cultura, tradición y patrimonio del Huila.',
    ),
    _HeroImagen(
      imagen:
          'assets/images/sitios/artesanias.jpg',
      titulo:
          'Hecho con identidad',
      subtitulo:
          'Artesanías y productos locales que cuentan historias.',
    ),
    _HeroImagen(
      imagen:
          'assets/images/sitios/aventuras.jpeg',
      titulo:
          'Aventuras para vivir',
      subtitulo:
          'Experiencias diferentes para descubrir nuevos lugares.',
    ),
    _HeroImagen(
      imagen:
          'assets/images/sitios/familiares.jpeg',
      titulo:
          'Experiencias para compartir',
      subtitulo:
          'Lugares para disfrutar en familia y con amigos.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController();

    _iniciarCarrusel();
  }

  void _iniciarCarrusel() {
    _carruselTimer =
        Timer.periodic(
      const Duration(
        seconds: 5,
      ),
      (_) {
        if (!mounted ||
            !_pageController
                .hasClients) {
          return;
        }

        final siguiente =
            (_paginaActual + 1) %
                _imagenes.length;

        _pageController.animateToPage(
          siguiente,
          duration:
              const Duration(
            milliseconds: 650,
          ),
          curve:
              Curves.easeInOutCubic,
        );
      },
    );
  }

  @override
  void dispose() {
    _carruselTimer?.cancel();
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SliverAppBar(
      expandedHeight: 290,
      pinned: true,
      backgroundColor:
          AppColors.coffeeDark,
      foregroundColor:
          AppColors.white,
      elevation:
          AppDimensions.elevationNone,
      flexibleSpace:
          FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ==================================================
            // CARRUSEL
            // ==================================================

            PageView.builder(
              controller:
                  _pageController,
              itemCount:
                  _imagenes.length,
              onPageChanged:
                  (pagina) {
                setState(() {
                  _paginaActual =
                      pagina;
                });
              },
              itemBuilder:
                  (
                context,
                index,
              ) {
                final item =
                    _imagenes[index];

                return Image.asset(
                  item.imagen,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      decoration:
                          const BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment
                                  .topLeft,
                          end:
                              Alignment
                                  .bottomRight,
                          colors: [
                            AppColors
                                .coffeeDark,
                            AppColors
                                .primaryDark,
                            AppColors
                                .secondary,
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // ==================================================
            // CAPA OSCURA
            // ==================================================

            Container(
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    AppColors
                        .coffeeDark
                        .withValues(
                      alpha: 0.12,
                    ),
                    AppColors
                        .primaryDark
                        .withValues(
                      alpha: 0.42,
                    ),
                    AppColors
                        .coffeeDark
                        .withValues(
                      alpha: 0.88,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // DECORACIÓN
            // ==================================================

            Positioned(
              right: -35,
              top: 40,
              child: Icon(
                Icons
                    .local_cafe_rounded,
                size: 175,
                color: AppColors
                    .white
                    .withValues(
                  alpha: 0.055,
                ),
              ),
            ),

            Positioned(
              left: -45,
              top: 105,
              child: Icon(
                Icons.eco_rounded,
                size: 145,
                color: AppColors
                    .white
                    .withValues(
                  alpha: 0.035,
                ),
              ),
            ),

            // ==================================================
            // TEXTO
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                AppDimensions
                    .spacingXxl,
                75,
                AppDimensions
                    .spacingXxl,
                AppDimensions
                        .spacingXl +
                    8,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Text(
                    'Hola, explorador 👋',
                    style:
                        TextStyle(
                      color: AppColors
                          .white
                          .withValues(
                        alpha: 0.82,
                      ),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height:
                        AppDimensions
                            .spacingSm,
                  ),
                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 350,
                    ),
                    child: Text(
                      _imagenes[
                              _paginaActual]
                          .titulo,
                      key: ValueKey(
                        _paginaActual,
                      ),
                      style:
                          const TextStyle(
                        color:
                            AppColors
                                .white,
                        fontSize: 31,
                        height: 1.05,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height:
                        AppDimensions
                            .spacingSm +
                        2,
                  ),
                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 350,
                    ),
                    child: Text(
                      _imagenes[
                              _paginaActual]
                          .subtitulo,
                      key: ValueKey(
                        'sub$_paginaActual',
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color: AppColors
                            .white
                            .withValues(
                          alpha: 0.84,
                        ),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height:
                        AppDimensions
                            .spacingMd,
                  ),

                  // ==================================================
                  // INDICADORES
                  // ==================================================

                  Row(
                    children:
                        List.generate(
                      _imagenes.length,
                      (index) {
                        final activo =
                            index ==
                                _paginaActual;

                        return AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds:
                                220,
                          ),
                          margin:
                              const EdgeInsets
                                  .only(
                            right:
                                AppDimensions
                                    .spacingXs,
                          ),
                          width:
                              activo
                                  ? 22
                                  : 7,
                          height: 6,
                          decoration:
                              BoxDecoration(
                            color: activo
                                ? AppColors
                                    .white
                                : AppColors
                                    .white
                                    .withValues(
                                    alpha:
                                        0.42,
                                  ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding:
              const EdgeInsets.only(
            right:
                AppDimensions
                        .spacingSm +
                    4,
          ),
          child: IconButton(
            tooltip:
                'Iniciar sesión',
            onPressed:
                widget.onLogin,
            icon: const Icon(
              Icons
                  .person_outline_rounded,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroImagen {
  final String imagen;
  final String titulo;
  final String subtitulo;

  const _HeroImagen({
    required this.imagen,
    required this.titulo,
    required this.subtitulo,
  });
}