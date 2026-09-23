import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../usuario/login_usuario_screen.dart';

class HomePublicoScreen extends StatefulWidget {
  const HomePublicoScreen({
    super.key,
  });

  @override
  State<HomePublicoScreen> createState() => _HomePublicoScreenState();
}

class _HomePublicoScreenState extends State<HomePublicoScreen> {
  final List<Map<String, dynamic>> categorias = [
    {
      'nombre': 'Café',
      'icono': Icons.local_cafe_rounded,
    },
    {
      'nombre': 'Naturaleza',
      'icono': Icons.park_rounded,
    },
    {
      'nombre': 'Cultura',
      'icono': Icons.account_balance_rounded,
    },
    {
      'nombre': 'Gastronomía',
      'icono': Icons.restaurant_rounded,
    },
    {
      'nombre': 'Experiencias',
      'icono': Icons.explore_rounded,
    },
  ];

  // ============================================================
  // IR AL LOGIN
  // ============================================================

  void _irLoginUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginUsuarioScreen(),
      ),
    );
  }

  // ============================================================
  // REQUIERE CUENTA
  // ============================================================

  void _requiereCuenta() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingXxl,
            AppDimensions.spacingMd + 6,
            AppDimensions.spacingXxl,
            AppDimensions.spacingSection - 2,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                AppDimensions.radiusXxl + 6,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSm,
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXl,
              ),

              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.secondary,
                  size: 35,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd + 6,
              ),

              const Text(
                'Guarda tus lugares favoritos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingSm + 2,
              ),

              const Text(
                'Crea una cuenta gratuita para guardar '
                'lugares, organizar tus rutas y disfrutar '
                'de una experiencia personalizada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingLg + 6,
              ),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _irLoginUsuario();
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingSm,
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _irLoginUsuario();
                },
                child: const Text(
                  'Crear mi cuenta',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CONSTRUCCIÓN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ==========================================================
          // CABECERA
          // ==========================================================

          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: AppColors.coffeeDark,
            foregroundColor: AppColors.white,
            elevation: AppDimensions.elevationNone,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.coffeeDark,
                          AppColors.secondary,
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    right: -30,
                    top: 45,
                    child: Icon(
                      Icons.local_cafe_rounded,
                      size: 170,
                      color: AppColors.white.withValues(
                        alpha: 0.06,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spacingXxl,
                      75,
                      AppDimensions.spacingXxl,
                      AppDimensions.spacingXl + 5,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Text(
                          'Hola, explorador 👋',
                          style: TextStyle(
                            color: AppColors.white.withValues(
                              alpha: 0.78,
                            ),
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),

                        const Text(
                          'Descubre la magia\ndel café.',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 34,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingSm + 2,
                        ),

                        Text(
                          'Paisajes, sabores, cultura y '
                          'experiencias del Huila.',
                          style: TextStyle(
                            color: AppColors.white.withValues(
                              alpha: 0.82,
                            ),
                            fontSize: 14,
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
                padding: const EdgeInsets.only(
                  right: AppDimensions.spacingSm + 4,
                ),
                child: IconButton(
                  tooltip: 'Iniciar sesión',
                  onPressed: _irLoginUsuario,
                  icon: const Icon(
                    Icons.person_outline_rounded,
                  ),
                ),
              ),
            ],
          ),

          // ==========================================================
          // CONTENIDO
          // ==========================================================

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingLg + 4,
                AppDimensions.spacingLg + 6,
                AppDimensions.spacingLg + 4,
                AppDimensions.spacingSection + 3,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ======================================================
                  // BUSCADOR
                  // ======================================================

                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg + 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: AppDimensions.spacingMd + 6,
                        ),

                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.textLight,
                        ),

                        const SizedBox(
                          width: AppDimensions.spacingMd,
                        ),

                        const Expanded(
                          child: Text(
                            '¿Qué te gustaría descubrir?',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.all(7),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius:
                                BorderRadius.circular(
                              AppDimensions.radiusMd + 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.white,
                            size: AppDimensions.iconMd,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSection - 4,
                  ),

                  // ======================================================
                  // CATEGORÍAS
                  // ======================================================

                  const Text(
                    'Explora por experiencia',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingMd + 3,
                  ),

                  SizedBox(
                    height: 112,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categorias.length,
                      separatorBuilder: (
                        context,
                        index,
                      ) {
                        return const SizedBox(
                          width: AppDimensions.spacingMd,
                        );
                      },
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final categoria =
                            categorias[index];

                        return _CategoriaCard(
                          nombre:
                              categoria['nombre'] as String,
                          icono:
                              categoria['icono'] as IconData,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSection - 2,
                  ),

                  // ======================================================
                  // DESTINOS DESTACADOS
                  // ======================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Destinos destacados',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver todos',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),

                  SizedBox(
                    height: 245,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _DestinoCard(
                          titulo:
                              'Descubre el café del Huila',
                          descripcion:
                              'Paisajes y experiencias cafeteras',
                          icono:
                              Icons.landscape_rounded,
                          onFavorite:
                              _requiereCuenta,
                        ),

                        const SizedBox(
                          width: AppDimensions.spacingMd + 3,
                        ),

                        _DestinoCard(
                          titulo:
                              'Naturaleza por descubrir',
                          descripcion:
                              'Conecta con nuestros paisajes',
                          icono:
                              Icons.forest_rounded,
                          onFavorite:
                              _requiereCuenta,
                        ),

                        const SizedBox(
                          width: AppDimensions.spacingMd + 3,
                        ),

                        _DestinoCard(
                          titulo:
                              'Sabores de nuestra tierra',
                          descripcion:
                              'Gastronomía y tradición',
                          icono:
                              Icons.restaurant_rounded,
                          onFavorite:
                              _requiereCuenta,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSection,
                  ),

                  // ======================================================
                  // BANNER PARA INICIAR SESIÓN
                  // ======================================================

                  Container(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingXl + 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.coffeeLight,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radiusXxl,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vive la experiencia completa',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height:
                                    AppDimensions.spacingSm,
                              ),

                              Text(
                                'Inicia sesión para guardar '
                                'favoritos y crear tus rutas.',
                                style: TextStyle(
                                  color:
                                      AppColors.white
                                          .withValues(
                                    alpha: 0.78,
                                  ),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(
                                height:
                                    AppDimensions.spacingMd +
                                        4,
                              ),

                              OutlinedButton(
                                onPressed:
                                    _irLoginUsuario,
                                style:
                                    OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AppColors.white,
                                  side:
                                      const BorderSide(
                                    color:
                                        AppColors.white,
                                  ),
                                ),
                                child: const Text(
                                  'Iniciar sesión',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: AppDimensions.spacingMd,
                        ),

                        Icon(
                          Icons.local_cafe_rounded,
                          size: 75,
                          color:
                              AppColors.white.withValues(
                            alpha: 0.16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSection,
                  ),

                  // ======================================================
                  // RUTAS
                  // ======================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rutas para inspirarte',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver todas',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),

                  _RutaCard(
                    titulo:
                        'Una aventura por el café',
                    subtitulo:
                        'Café · Naturaleza · Cultura',
                    icono:
                        Icons.route_rounded,
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),

                  _RutaCard(
                    titulo:
                        'Sabores y tradición',
                    subtitulo:
                        'Gastronomía · Café · Cultura',
                    icono:
                        Icons.restaurant_menu_rounded,
                  ),

                  const SizedBox(
                    height:
                        AppDimensions.spacingSection + 3,
                  ),

                  // ======================================================
                  // MENSAJE FINAL
                  // ======================================================

                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          color:
                              AppColors.coffeeLight,
                          size:
                              AppDimensions.iconLg + 6,
                        ),

                        const SizedBox(
                          height:
                              AppDimensions.spacingSm + 2,
                        ),

                        const Text(
                          'En cada taza hay una historia, '
                          'un paisaje y un corazón que late.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color:
                                AppColors.secondary,
                            fontSize: 15,
                            fontStyle:
                                FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// CATEGORÍA
// ======================================================================

class _CategoriaCard extends StatelessWidget {
  final String nombre;
  final IconData icono;

  const _CategoriaCard({
    required this.nombre,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusXl + 2,
      ),
      onTap: () {},
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMd + 1,
          horizontal: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXl + 2,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: AppColors.secondary,
                size: 25,
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacingSm,
            ),

            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// DESTINO
// ======================================================================

class _DestinoCard extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback onFavorite;

  const _DestinoCard({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.onFavorite,
  });

  @override
  State<_DestinoCard> createState() =>
      _DestinoCardState();
}

class _DestinoCardState
    extends State<_DestinoCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _presionado = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _presionado = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _presionado = false;
        });
      },
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1,
        duration: const Duration(
          milliseconds: 130,
        ),
        child: Container(
          width: 245,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusXxl - 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.black.withValues(
                  alpha: 0.07,
                ),
                blurRadius: 14,
                offset:
                    const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration:
                      const BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.coffeeLight,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(
                        AppDimensions.radiusXxl - 2,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          widget.icono,
                          size: 70,
                          color: AppColors
                              .white
                              .withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),

                      Positioned(
                        top:
                            AppDimensions
                                    .spacingSm +
                                4,
                        right:
                            AppDimensions
                                    .spacingSm +
                                4,
                        child: Material(
                          color:
                              AppColors.white,
                          shape:
                              const CircleBorder(),
                          child:
                              IconButton(
                            onPressed:
                                widget
                                    .onFavorite,
                            icon:
                                const Icon(
                              Icons
                                  .favorite_border_rounded,
                            ),
                            color:
                                AppColors.secondary,
                            iconSize:
                                AppDimensions
                                        .iconSm +
                                    3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.all(
                  AppDimensions.spacingMd +
                      2,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titulo,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors
                                .textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height:
                          AppDimensions
                                  .spacingXs +
                              1,
                    ),

                    Text(
                      widget.descripcion,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            AppColors
                                .textSecondary,
                      ),
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
}

// ======================================================================
// RUTA
// ======================================================================

class _RutaCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;

  const _RutaCard({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd + 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl + 1,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusMd + 4,
              ),
            ),
            child: Icon(
              icono,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(
            width: AppDimensions.spacingMd + 2,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height:
                      AppDimensions
                              .spacingXs +
                          1,
                ),

                Text(
                  subtitulo,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppDimensions.iconSm,
            color: AppColors.coffeeLight,
          ),
        ],
      ),
    );
  }
}