import 'package:flutter/material.dart';

import '../usuario/login_usuario_screen.dart';

class HomePublicoScreen extends StatefulWidget {
  const HomePublicoScreen({
    super.key,
  });

  @override
  State<HomePublicoScreen> createState() =>
      _HomePublicoScreenState();
}

class _HomePublicoScreenState
    extends State<HomePublicoScreen> {
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

  void _irLoginUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginUsuarioScreen(),
      ),
    );
  }

  void _requiereCuenta() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            18,
            24,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.brown.shade700,
                  size: 35,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Guarda tus lugares favoritos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Crea una cuenta gratuita para guardar '
                'lugares, organizar tus rutas y disfrutar '
                'de una experiencia personalizada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _irLoginUsuario();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.brown.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: CustomScrollView(
        slivers: [
          // ============================================================
          // CABECERA
          // ============================================================

          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: Colors.brown.shade800,
            foregroundColor: Colors.white,
            elevation: 0,
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
                          Color(0xFF17352B),
                          Color(0xFF4E342E),
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
                      color: Colors.white.withValues(alpha: 
                        0.06,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      75,
                      24,
                      25,
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
                            color: Colors.white
                                .withValues(alpha: 0.78),
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Descubre la magia\ndel café.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Paisajes, sabores, cultura y '
                          'experiencias del Huila.',
                          style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.82),
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
                  right: 12,
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

          // ============================================================
          // CONTENIDO
          // ============================================================

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                35,
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
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 
                            0.06,
                          ),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        Icon(
                          Icons.search_rounded,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¿Qué te gustaría descubrir?',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.all(7),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade700,
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ======================================================
                  // CATEGORIAS
                  // ======================================================

                  const Text(
                    'Explora por experiencia',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 112,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categorias.length,
                      separatorBuilder: (
                        context,
                        index,
                      ) {
                        return const SizedBox(width: 12);
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
                              categoria['icono']
                                  as IconData,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

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

                  const SizedBox(height: 8),

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
                        const SizedBox(width: 15),
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
                        const SizedBox(width: 15),
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

                  const SizedBox(height: 32),

                  // ======================================================
                  // BANNER PARA INICIAR SESION
                  // ======================================================

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4E342E),
                          Color(0xFF795548),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(24),
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
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Inicia sesión para guardar '
                                'favoritos y crear tus rutas.',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.78),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 16),

                              OutlinedButton(
                                onPressed:
                                    _irLoginUsuario,
                                style:
                                    OutlinedButton.styleFrom(
                                  foregroundColor:
                                      Colors.white,
                                  side: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                child: const Text(
                                  'Iniciar sesión',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Icon(
                          Icons.local_cafe_rounded,
                          size: 75,
                          color: Colors.white
                              .withValues(alpha: 0.16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

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

                  const SizedBox(height: 8),

                  _RutaCard(
                    titulo:
                        'Una aventura por el café',
                    subtitulo:
                        'Café · Naturaleza · Cultura',
                    icono:
                        Icons.route_rounded,
                  ),

                  const SizedBox(height: 12),

                  _RutaCard(
                    titulo:
                        'Sabores y tradición',
                    subtitulo:
                        'Gastronomía · Café · Cultura',
                    icono:
                        Icons.restaurant_menu_rounded,
                  ),

                  const SizedBox(height: 35),

                  // ======================================================
                  // MENSAJE FINAL
                  // ======================================================

                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          color: Colors.brown.shade400,
                          size: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'En cada taza hay una historia, '
                          'un paisaje y un corazón que late.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
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
// CATEGORIA
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
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.brown.shade100,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: Colors.brown.shade700,
                size: 25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 
                  0.07,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF315C45),
                        Color(0xFF8D6E63),
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          widget.icono,
                          size: 70,
                          color: Colors.white
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.white,
                          shape:
                              const CircleBorder(),
                          child: IconButton(
                            onPressed:
                                widget.onFavorite,
                            icon: const Icon(
                              Icons.favorite_border_rounded,
                            ),
                            color:
                                Colors.brown.shade700,
                            iconSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titulo,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.descripcion,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.brown.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Icon(
              icono,
              color: Colors.brown.shade700,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 17,
            color: Colors.brown.shade500,
          ),
        ],
      ),
    );
  }
}
