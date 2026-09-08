import 'package:flutter/material.dart';

class HomeUsuarioScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String token;

  const HomeUsuarioScreen({
    super.key,
    required this.usuario,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final nombre =
        usuario['nombre'] ?? 'Viajero';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Ruta Mágica del Café',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // BIENVENIDA
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),
                  color: Colors.brown.shade50,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.coffee,
                      size: 65,
                      color: Colors.brown,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      '¡Hola, $nombre! 👋',
                      textAlign:
                          TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Bienvenido a Mi Ruta '
                      'Mágica del Café',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // BUSCADOR
              // ==================================================

              TextField(
                decoration:
                    InputDecoration(
                  hintText:
                      '¿Qué quieres descubrir?',
                  prefixIcon:
                      const Icon(Icons.search),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // OPCIONES PRINCIPALES
              // ==================================================

              const Text(
                'Explora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _opcionExplorar(
                      icon: Icons.map_outlined,
                      titulo: 'Mapa',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _opcionExplorar(
                      icon:
                          Icons.route_outlined,
                      titulo: 'Rutas',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _opcionExplorar(
                      icon:
                          Icons.place_outlined,
                      titulo: 'Sitios',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _opcionExplorar(
                      icon:
                          Icons.favorite_border,
                      titulo: 'Favoritos',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================================================
              // MENSAJE
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        Colors.brown.shade200,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 45,
                      color: Colors.brown,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Descubre el Huila',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Muy pronto podrás explorar '
                      'sitios turísticos, categorías '
                      'y rutas mágicas del café.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // CERRAR SESIÓN
              // ==================================================

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.logout,
                ),
                label: const Text(
                  'Cerrar sesión',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPCIÓN EXPLORAR
  // ============================================================

  Widget _opcionExplorar({
    required IconData icon,
    required String titulo,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 22,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),
        color: Colors.brown.shade50,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: Colors.brown,
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}