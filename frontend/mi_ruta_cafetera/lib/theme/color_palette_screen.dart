import 'package:flutter/material.dart';

import 'app_colors.dart';

class ColorPaletteScreen extends StatelessWidget {
  const ColorPaletteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paleta de colores',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi Ruta Mágica del Café',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Paleta visual oficial del proyecto',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // =================================================
                // COLORES PRINCIPALES
                // =================================================

                const Text(
                  'Colores principales',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                _ColorCard(
                  nombre: 'PRIMARY',
                  descripcion:
                      'Color principal de la aplicación',
                  color:
                      AppColors.primary,
                ),

                const SizedBox(height: 12),

                _ColorCard(
                  nombre: 'SECONDARY',
                  descripcion:
                      'Color secundario de la aplicación',
                  color:
                      AppColors.secondary,
                ),

                const SizedBox(height: 12),

                _ColorCard(
                  nombre: 'TERTIARY',
                  descripcion:
                      'Color de acento y destacados',
                  color:
                      AppColors.tertiary,
                ),

                const SizedBox(height: 32),

                // =================================================
                // FONDOS
                // =================================================

                const Text(
                  'Fondos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SmallColorCard(
                      nombre: 'Background',
                      color:
                          AppColors.background,
                    ),
                    _SmallColorCard(
                      nombre: 'Surface',
                      color:
                          AppColors.surface,
                    ),
                    _SmallColorCard(
                      nombre: 'Cream',
                      color:
                          AppColors.cream,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // =================================================
                // CAFÉ Y NATURALEZA
                // =================================================

                const Text(
                  'Café y naturaleza',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SmallColorCard(
                      nombre: 'Coffee Dark',
                      color:
                          AppColors.coffeeDark,
                    ),
                    _SmallColorCard(
                      nombre: 'Coffee Light',
                      color:
                          AppColors.coffeeLight,
                    ),
                    _SmallColorCard(
                      nombre: 'Nature Light',
                      color:
                          AppColors.natureLight,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // =================================================
                // ESTADOS
                // =================================================

                const Text(
                  'Estados',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SmallColorCard(
                      nombre: 'Success',
                      color:
                          AppColors.success,
                    ),
                    _SmallColorCard(
                      nombre: 'Warning',
                      color:
                          AppColors.warning,
                    ),
                    _SmallColorCard(
                      nombre: 'Error',
                      color:
                          AppColors.error,
                    ),
                    _SmallColorCard(
                      nombre: 'Info',
                      color:
                          AppColors.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TARJETA PRINCIPAL
// =====================================================

class _ColorCard extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final Color color;

  const _ColorCard({
    required this.nombre,
    required this.descripcion,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(18),
      ),
      padding:
          const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _hexColor(color),
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TARJETA PEQUEÑA
// =====================================================

class _SmallColorCard
    extends StatelessWidget {
  final String nombre;
  final Color color;

  const _SmallColorCard({
    required this.nombre,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(16),
      ),
      padding:
          const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.end,
        children: [
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hexColor(color),
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// HEX
// =====================================================

String _hexColor(Color color) {
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}