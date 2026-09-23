import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

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
    final nombre = usuario['nombre'] ?? 'Viajero';

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
          padding: const EdgeInsets.all(
            AppDimensions.spacingLg + 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // BIENVENIDA
              // ==================================================
              Container(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingXxl,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusXxl,
                  ),
                  color: AppColors.cream,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.coffee,
                      size: 65,
                      color: AppColors.secondary,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingLg - 1,
                    ),

                    Text(
                      '¡Hola, $nombre! 👋',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),

                    const Text(
                      'Bienvenido a Mi Ruta '
                      'Mágica del Café',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXxl + 1,
              ),

              // ==================================================
              // BUSCADOR
              // ==================================================
              TextField(
                decoration: InputDecoration(
                  hintText: '¿Qué quieres descubrir?',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXxl + 1,
              ),

              // ==================================================
              // OPCIONES PRINCIPALES
              // ==================================================
              const Text(
                'Explora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd + 3,
              ),

              Row(
                children: [
                  Expanded(
                    child: _opcionExplorar(
                      icon: Icons.map_outlined,
                      titulo: 'Mapa',
                    ),
                  ),

                  const SizedBox(
                    width: AppDimensions.spacingMd,
                  ),

                  Expanded(
                    child: _opcionExplorar(
                      icon: Icons.route_outlined,
                      titulo: 'Rutas',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppDimensions.spacingMd,
              ),

              Row(
                children: [
                  Expanded(
                    child: _opcionExplorar(
                      icon: Icons.place_outlined,
                      titulo: 'Sitios',
                    ),
                  ),

                  const SizedBox(
                    width: AppDimensions.spacingMd,
                  ),

                  Expanded(
                    child: _opcionExplorar(
                      icon: Icons.favorite_border,
                      titulo: 'Favoritos',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppDimensions.spacingSection - 2,
              ),

              // ==================================================
              // MENSAJE
              // ==================================================
              Container(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg + 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusXl,
                  ),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 45,
                      color: AppColors.secondary,
                    ),

                    SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    Text(
                      'Descubre el Huila',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(
                      height: AppDimensions.spacingSm,
                    ),

                    Text(
                      'Muy pronto podrás explorar '
                      'sitios turísticos, categorías '
                      'y rutas mágicas del café.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingSection - 2,
              ),

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
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXl - 2,
        horizontal: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        color: AppColors.cream,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: AppColors.secondary,
          ),

          const SizedBox(
            height: AppDimensions.spacingSm,
          ),

          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}