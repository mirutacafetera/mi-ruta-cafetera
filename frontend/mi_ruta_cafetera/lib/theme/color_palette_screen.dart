import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class ColorPaletteScreen extends StatelessWidget {
  const ColorPaletteScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sistema visual',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppDimensions.pageHorizontal,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // ENCABEZADO
                // ==================================================

                const Text(
                  'Mi Ruta Mágica del Café',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingSm,
                ),

                const Text(
                  'Sistema visual oficial de la aplicación',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(
                  height: AppDimensions.spacingSection,
                ),

                // ==================================================
                // IDENTIDAD PRINCIPAL
                // ==================================================

                const _SectionTitle(
                  title: 'Identidad principal',
                  subtitle:
                      'Colores que construyen la identidad de la aplicación.',
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                const Wrap(
                  spacing: AppDimensions.spacingMd,
                  runSpacing: AppDimensions.spacingMd,
                  children: [
                    _ColorCard(
                      nombre: 'VERDE BOSQUE',
                      descripcion:
                          'Color principal de la aplicación',
                      color: AppColors.primary,
                    ),
                    _ColorCard(
                      nombre: 'VERDE PROFUNDO',
                      descripcion:
                          'Contraste y superficies oscuras',
                      color: AppColors.primaryDark,
                    ),
                    _ColorCard(
                      nombre: 'NARANJA CAFÉ',
                      descripcion:
                          'Acciones y elementos destacados',
                      color: AppColors.secondary,
                    ),
                    _ColorCard(
                      nombre: 'TERRACOTA',
                      descripcion:
                          'Acento cafetero complementario',
                      color: AppColors.tertiary,
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppDimensions.spacingSection,
                ),

                // ==================================================
                // FONDOS
                // ==================================================

                const _SectionTitle(
                  title: 'Fondos y superficies',
                  subtitle:
                      'Base visual para pantallas, tarjetas y secciones.',
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                const Wrap(
                  spacing: AppDimensions.spacingMd,
                  runSpacing: AppDimensions.spacingMd,
                  children: [
                    _SmallColorCard(
                      nombre: 'Background',
                      color: AppColors.background,
                    ),
                    _SmallColorCard(
                      nombre: 'Surface',
                      color: AppColors.surface,
                    ),
                    _SmallColorCard(
                      nombre: 'Surface Variant',
                      color: AppColors.surfaceVariant,
                    ),
                    _SmallColorCard(
                      nombre: 'Cream',
                      color: AppColors.cream,
                    ),
                    _SmallColorCard(
                      nombre: 'Cream Light',
                      color: AppColors.creamLight,
                    ),
                    _SmallColorCard(
                      nombre: 'Surface Dark',
                      color: AppColors.surfaceDark,
                    ),
                    _SmallColorCard(
                      nombre: 'Surface Green',
                      color: AppColors.surfaceGreen,
                    ),
                    _SmallColorCard(
                      nombre: 'Orange Soft',
                      color: AppColors.orangeSoft,
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppDimensions.spacingSection,
                ),

                // ==================================================
                // CAFÉ Y NATURALEZA
                // ==================================================

                const _SectionTitle(
                  title: 'Café y naturaleza',
                  subtitle:
                      'Tonos complementarios de la identidad turística.',
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                const Wrap(
                  spacing: AppDimensions.spacingMd,
                  runSpacing: AppDimensions.spacingMd,
                  children: [
                    _SmallColorCard(
                      nombre: 'Coffee Dark',
                      color: AppColors.coffeeDark,
                    ),
                    _SmallColorCard(
                      nombre: 'Coffee',
                      color: AppColors.coffee,
                    ),
                    _SmallColorCard(
                      nombre: 'Coffee Light',
                      color: AppColors.coffeeLight,
                    ),
                    _SmallColorCard(
                      nombre: 'Nature Dark',
                      color: AppColors.natureDark,
                    ),
                    _SmallColorCard(
                      nombre: 'Nature',
                      color: AppColors.nature,
                    ),
                    _SmallColorCard(
                      nombre: 'Nature Light',
                      color: AppColors.natureLight,
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppDimensions.spacingSection,
                ),

                // ==================================================
                // CATEGORÍAS
                // ==================================================

                const _SectionTitle(
                  title: 'Identidad de categorías',
                  subtitle:
                      'Cada categoría conserva su color e icono '
                      'en toda la aplicación.',
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                const Wrap(
                  spacing: AppDimensions.spacingMd,
                  runSpacing: AppDimensions.spacingMd,
                  children: [
                    _CategoryColorCard(
                      nombre:
                          'Café y Experiencias Cafeteras',
                      color:
                          AppColors.categoryCafe,
                      icon:
                          Icons.coffee_rounded,
                    ),
                    _CategoryColorCard(
                      nombre:
                          'Artesanías y Productos Locales',
                      color:
                          AppColors.categoryArtesanias,
                      icon:
                          Icons.palette_rounded,
                    ),
                    _CategoryColorCard(
                      nombre: 'Aventuras',
                      color:
                          AppColors.categoryAventuras,
                      icon:
                          Icons.directions_run_rounded,
                    ),
                    _CategoryColorCard(
                      nombre: 'Cultura e Historia',
                      color:
                          AppColors.categoryCultura,
                      icon:
                          Icons.account_balance_rounded,
                    ),
                    _CategoryColorCard(
                      nombre:
                          'Experiencias Familiares',
                      color:
                          AppColors.categoryFamilia,
                      icon:
                          Icons.family_restroom_rounded,
                    ),
                    _CategoryColorCard(
                      nombre: 'Gastronomía',
                      color:
                          AppColors.categoryGastronomia,
                      icon:
                          Icons.restaurant_rounded,
                    ),
                    _CategoryColorCard(
                      nombre: 'Alojamiento',
                      color:
                          AppColors.categoryAlojamiento,
                      icon:
                          Icons.hotel_rounded,
                    ),
                    _CategoryColorCard(
                      nombre:
                          'Miradores y Paisajes',
                      color:
                          AppColors.categoryMiradores,
                      icon:
                          Icons.landscape_rounded,
                    ),
                    _CategoryColorCard(
                      nombre:
                          'Naturaleza y Ecoturismo',
                      color:
                          AppColors.categoryNaturaleza,
                      icon:
                          Icons.park_rounded,
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppDimensions.spacingSection,
                ),

                // ==================================================
                // ESTADOS
                // ==================================================

                const _SectionTitle(
                  title: 'Estados',
                  subtitle:
                      'Colores utilizados para mensajes y estados.',
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                const Wrap(
                  spacing: AppDimensions.spacingMd,
                  runSpacing: AppDimensions.spacingMd,
                  children: [
                    _SmallColorCard(
                      nombre: 'Success',
                      color: AppColors.success,
                    ),
                    _SmallColorCard(
                      nombre: 'Warning',
                      color: AppColors.warning,
                    ),
                    _SmallColorCard(
                      nombre: 'Error',
                      color: AppColors.error,
                    ),
                    _SmallColorCard(
                      nombre: 'Info',
                      color: AppColors.info,
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppDimensions.spacingSection,
                ),

                // ==================================================
                // TEXTO
                // ==================================================

                const _SectionTitle(
                  title: 'Tipografía y contraste',
                  subtitle:
                      'Jerarquía utilizada sobre fondos claros y oscuros.',
                ),

                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),

                const _TextPreviewCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TÍTULO DE SECCIÓN
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingXs,
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TARJETA PRINCIPAL DE COLOR
// ============================================================

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
      width: 300,
      height: 138,
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            nombre,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            descripcion,
            style: TextStyle(
              color: AppColors.white.withValues(
                alpha: 0.90,
              ),
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Text(
            _hexColor(color),
            style: TextStyle(
              color: AppColors.white.withValues(
                alpha: 0.72,
              ),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETA PEQUEÑA DE COLOR
// ============================================================

class _SmallColorCard extends StatelessWidget {
  final String nombre;
  final Color color;

  const _SmallColorCard({
    required this.nombre,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = color.computeLuminance() > 0.55;

    final textColor = isLight
        ? AppColors.textPrimary
        : AppColors.white;

    return Container(
      width: 180,
      height: 100,
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: isLight
              ? AppColors.border
              : AppColors.white.withValues(
                  alpha: 0.08,
                ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.end,
        children: [
          Text(
            nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            _hexColor(color),
            style: TextStyle(
              color: textColor.withValues(
                alpha: 0.72,
              ),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETA DE CATEGORÍA
// ============================================================

class _CategoryColorCard extends StatelessWidget {
  final String nombre;
  final Color color;
  final IconData icon;

  const _CategoryColorCard({
    required this.nombre,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.categoryRadius,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: AppDimensions.categoryIconContainer,
            height: AppDimensions.categoryIconContainer,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.14,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppDimensions.categoryIcon,
              color: color,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Text(
              nombre,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VISTA PREVIA DE TIPOGRAFÍA
// ============================================================

class _TextPreviewCard extends StatelessWidget {
  const _TextPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Descubre el Huila',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          const Text(
            'Café, naturaleza, cultura y experiencias '
            'para descubrir a tu manera.',
            style: TextStyle(
              color: AppColors.textOnDarkSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          Container(
            height: 1,
            color: AppColors.borderDark,
          ),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  color: AppColors.white,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              const Expanded(
                child: Text(
                  'Café y Experiencias Cafeteras',
                  style: TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONVERSIÓN A HEX
// ============================================================

String _hexColor(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}