import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // ==========================================================
  // IDENTIDAD PRINCIPAL
  // ==========================================================

  /// Verde bosque principal de Mi Ruta Mágica del Café.
  static const Color primary = Color(0xFF174B35);

  /// Verde bosque profundo.
  static const Color primaryDark = Color(0xFF0B2F21);

  /// Naranja cálido utilizado para acciones y elementos activos.
  static const Color secondary = Color(0xFFF47721);

  /// Terracota cafetero.
  static const Color tertiary = Color(0xFF9A5A3A);

  // ==========================================================
  // IDENTIDAD CAFETERA Y NATURAL
  // ==========================================================

  /// Café oscuro.
  static const Color coffeeDark = Color(0xFF2B1A12);

  /// Café tostado.
  static const Color coffeeLight = Color(0xFFA86F48);

  /// Café medio.
  static const Color coffee = Color(0xFF6F4328);

  /// Verde natural.
  static const Color nature = Color(0xFF397A55);

  /// Verde natural claro.
  static const Color natureLight = Color(0xFF8EB89A);

  /// Verde profundo alternativo.
  static const Color natureDark = Color(0xFF123D2A);

  // ==========================================================
  // FONDOS Y SUPERFICIES
  // ==========================================================

  /// Fondo claro general.
  static const Color background = Color(0xFFF4F0E8);

  /// Superficie clara.
  static const Color surface = Color(0xFFFFFFFF);

  /// Superficie crema.
  static const Color surfaceVariant = Color(0xFFE9E3D7);

  /// Crema de identidad.
  static const Color cream = Color(0xFFF5EBDD);

  /// Crema muy clara.
  static const Color creamLight = Color(0xFFFBF7F0);

  /// Superficie verde oscura.
  static const Color surfaceDark = Color(0xFF103B29);

  /// Superficie verde secundaria.
  static const Color surfaceGreen = Color(0xFF1B4A34);

  /// Fondo naranja suave.
  static const Color orangeSoft = Color(0xFFFFE4D0);

  // ==========================================================
  // TEXTOS
  // ==========================================================

  /// Texto principal sobre fondos claros.
  static const Color textPrimary = Color(0xFF172019);

  /// Texto secundario sobre fondos claros.
  static const Color textSecondary = Color(0xFF657069);

  /// Texto de baja prioridad.
  static const Color textLight = Color(0xFF929B95);

  /// Texto principal sobre fondos oscuros.
  static const Color textOnDark = Color(0xFFF8F4EC);

  /// Texto secundario sobre fondos oscuros.
  static const Color textOnDarkSecondary = Color(0xFFC7D1CA);

  // ==========================================================
  // BORDES Y DIVISORES
  // ==========================================================

  static const Color divider = Color(0xFFE2DED5);

  static const Color border = Color(0xFFD9D4C9);

  /// Borde utilizado sobre superficies verdes.
  static const Color borderDark = Color(0xFF315745);

  // ==========================================================
  // SOMBRAS
  // ==========================================================

  static const Color cardShadow = Color(0x18000000);

  static const Color strongShadow = Color(0x26000000);

  // ==========================================================
  // ESTADOS
  // ==========================================================

  static const Color success = Color(0xFF3E8E5B);

  static const Color info = Color(0xFF4C8DA8);

  static const Color warning = Color(0xFFE09A2D);

  static const Color error = Color(0xFFC94A3D);

  // ==========================================================
  // COLORES BÁSICOS
  // ==========================================================

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  // ==========================================================
  // COLORES OFICIALES DE LAS CATEGORÍAS
  // ==========================================================
  //
  // Estas son las categorías actuales del proyecto:
  //
  // 1. Alojamiento
  // 2. Artesanías y Productos Locales
  // 3. Aventuras
  // 4. Café y Experiencias Cafeteras
  // 5. Cultura e Historia
  // 6. Experiencias Familiares
  // 7. Gastronomía
  // 8. Miradores y Paisajes
  // 9. Naturaleza y Ecoturismo
  //
  // Cada categoría conserva su identidad visual en toda
  // la aplicación.
  // ==========================================================

  /// Café y Experiencias Cafeteras.
  static const Color categoryCafe = Color(0xFFB86B2C);

  /// Artesanías y Productos Locales.
  static const Color categoryArtesanias = Color(0xFF9B5C8F);

  /// Gastronomía.
  static const Color categoryGastronomia = Color(0xFFD65C45);

  /// Alojamiento.
  static const Color categoryAlojamiento = Color(0xFF4D7FA3);

  /// Experiencias Familiares.
  static const Color categoryFamilia = Color(0xFFD39A35);

  /// Naturaleza y Ecoturismo.
  static const Color categoryNaturaleza = Color(0xFF4E9568);

  /// Cultura e Historia.
  static const Color categoryCultura = Color(0xFF8B6547);

  /// Aventuras.
  static const Color categoryAventuras = Color(0xFF2E7D68);

  /// Miradores y Paisajes.
  static const Color categoryMiradores = Color(0xFF527FA6);

  /// Categoría desconocida.
  static const Color catDefault = Color(0xFF6F7A73);

  // ==========================================================
  // COMPATIBILIDAD CON LOS NOMBRES ANTERIORES
  // ==========================================================
  //
  // Estos nombres ya existen en diferentes partes del proyecto.
  // Los mantenemos para evitar errores de compilación.
  // ==========================================================

  static const Color catFincaCafetera = categoryCafe;

  static const Color catTiendaEspecial = categoryCafe;

  static const Color catEcoturismo = categoryNaturaleza;

  static const Color catGastronomia = categoryGastronomia;

  static const Color catAlojamiento = categoryAlojamiento;

  static const Color catArtesanias = categoryArtesanias;

  // ==========================================================
  // MAPA CENTRAL DE COLORES POR CATEGORÍA
  // ==========================================================

  static const Map<String, Color> categoryColors = {
    // --------------------------------------------------------
    // CAFÉ Y EXPERIENCIAS CAFETERAS
    // --------------------------------------------------------

    'café y experiencias cafeteras': categoryCafe,
    'cafe y experiencias cafeteras': categoryCafe,
    'café': categoryCafe,
    'cafe': categoryCafe,
    'finca cafetera': categoryCafe,
    'finca': categoryCafe,
    'fincas': categoryCafe,
    'agroturismo': categoryCafe,
    'cafetería': categoryCafe,
    'cafeteria': categoryCafe,
    'tienda': categoryCafe,
    'café especial': categoryCafe,
    'cafe especial': categoryCafe,

    // --------------------------------------------------------
    // ARTESANÍAS Y PRODUCTOS LOCALES
    // --------------------------------------------------------

    'artesanías y productos locales': categoryArtesanias,
    'artesanias y productos locales': categoryArtesanias,
    'artesanías': categoryArtesanias,
    'artesanias': categoryArtesanias,
    'productos locales': categoryArtesanias,

    // --------------------------------------------------------
    // AVENTURAS
    // --------------------------------------------------------

    'aventuras': categoryAventuras,
    'aventura': categoryAventuras,
    'deportes de aventura': categoryAventuras,

    // --------------------------------------------------------
    // CULTURA E HISTORIA
    // --------------------------------------------------------

    'cultura e historia': categoryCultura,
    'cultura': categoryCultura,
    'historia': categoryCultura,
    'patrimonio': categoryCultura,

    // --------------------------------------------------------
    // EXPERIENCIAS FAMILIARES
    // --------------------------------------------------------

    'experiencias familiares': categoryFamilia,
    'experiencia familiar': categoryFamilia,
    'familia': categoryFamilia,
    'familiar': categoryFamilia,

    // --------------------------------------------------------
    // GASTRONOMÍA
    // --------------------------------------------------------

    'gastronomía': categoryGastronomia,
    'gastronomia': categoryGastronomia,
    'restaurante': categoryGastronomia,
    'comida': categoryGastronomia,

    // --------------------------------------------------------
    // ALOJAMIENTO
    // --------------------------------------------------------

    'alojamiento': categoryAlojamiento,
    'hotel': categoryAlojamiento,
    'hospedaje': categoryAlojamiento,

    // --------------------------------------------------------
    // MIRADORES Y PAISAJES
    // --------------------------------------------------------

    'miradores y paisajes': categoryMiradores,
    'mirador': categoryMiradores,
    'miradores': categoryMiradores,
    'paisajes': categoryMiradores,

    // --------------------------------------------------------
    // NATURALEZA Y ECOTURISMO
    // --------------------------------------------------------

    'naturaleza y ecoturismo': categoryNaturaleza,
    'naturaleza': categoryNaturaleza,
    'ecoturismo': categoryNaturaleza,
    'senderismo': categoryNaturaleza,
    'parque natural': categoryNaturaleza,
  };

  // ==========================================================
  // MAPA CENTRAL DE ICONOS POR CATEGORÍA
  // ==========================================================

  static const Map<String, IconData> categoryIcons = {
    // --------------------------------------------------------
    // CAFÉ Y EXPERIENCIAS CAFETERAS
    // --------------------------------------------------------

    'café y experiencias cafeteras':
        Icons.coffee_rounded,

    'cafe y experiencias cafeteras':
        Icons.coffee_rounded,

    'café':
        Icons.coffee_rounded,

    'cafe':
        Icons.coffee_rounded,

    'finca cafetera':
        Icons.coffee_maker_rounded,

    'finca':
        Icons.landscape_rounded,

    'fincas':
        Icons.landscape_rounded,

    'agroturismo':
        Icons.agriculture_rounded,

    'cafetería':
        Icons.local_cafe_rounded,

    'cafeteria':
        Icons.local_cafe_rounded,

    'tienda':
        Icons.storefront_rounded,

    'café especial':
        Icons.coffee_maker_rounded,

    'cafe especial':
        Icons.coffee_maker_rounded,

    // --------------------------------------------------------
    // ARTESANÍAS Y PRODUCTOS LOCALES
    // --------------------------------------------------------

    'artesanías y productos locales':
        Icons.palette_rounded,

    'artesanias y productos locales':
        Icons.palette_rounded,

    'artesanías':
        Icons.palette_rounded,

    'artesanias':
        Icons.palette_rounded,

    'productos locales':
        Icons.shopping_bag_rounded,

    // --------------------------------------------------------
    // AVENTURAS
    // --------------------------------------------------------

    'aventuras':
        Icons.directions_run_rounded,

    'aventura':
        Icons.directions_run_rounded,

    'deportes de aventura':
        Icons.sports_score_rounded,

    // --------------------------------------------------------
    // CULTURA E HISTORIA
    // --------------------------------------------------------

    'cultura e historia':
        Icons.account_balance_rounded,

    'cultura':
        Icons.museum_rounded,

    'historia':
        Icons.account_balance_rounded,

    'patrimonio':
        Icons.account_balance_rounded,

    // --------------------------------------------------------
    // EXPERIENCIAS FAMILIARES
    // --------------------------------------------------------

    'experiencias familiares':
        Icons.family_restroom_rounded,

    'experiencia familiar':
        Icons.family_restroom_rounded,

    'familia':
        Icons.family_restroom_rounded,

    'familiar':
        Icons.family_restroom_rounded,

    // --------------------------------------------------------
    // GASTRONOMÍA
    // --------------------------------------------------------

    'gastronomía':
        Icons.restaurant_rounded,

    'gastronomia':
        Icons.restaurant_rounded,

    'restaurante':
        Icons.restaurant_rounded,

    'comida':
        Icons.restaurant_menu_rounded,

    // --------------------------------------------------------
    // ALOJAMIENTO
    // --------------------------------------------------------

    'alojamiento':
        Icons.hotel_rounded,

    'hotel':
        Icons.hotel_rounded,

    'hospedaje':
        Icons.bed_rounded,

    // --------------------------------------------------------
    // MIRADORES Y PAISAJES
    // --------------------------------------------------------

    'miradores y paisajes':
        Icons.landscape_rounded,

    'mirador':
        Icons.visibility_rounded,

    'miradores':
        Icons.visibility_rounded,

    'paisajes':
        Icons.landscape_rounded,

    // --------------------------------------------------------
    // NATURALEZA Y ECOTURISMO
    // --------------------------------------------------------

    'naturaleza y ecoturismo':
        Icons.park_rounded,

    'naturaleza':
        Icons.park_rounded,

    'ecoturismo':
        Icons.eco_rounded,

    'senderismo':
        Icons.hiking_rounded,

    'parque natural':
        Icons.forest_rounded,
  };

  // ==========================================================
  // OBTENER COLOR DE CATEGORÍA
  // ==========================================================

  static Color getColorForCategory(
    String? categoryName,
  ) {
    if (categoryName == null ||
        categoryName.trim().isEmpty) {
      return catDefault;
    }

    final key = categoryName
        .toLowerCase()
        .trim();

    return categoryColors[key] ?? catDefault;
  }

  // ==========================================================
  // OBTENER ICONO DE CATEGORÍA
  // ==========================================================

  static IconData getIconForCategory(
    String? categoryName,
  ) {
    if (categoryName == null ||
        categoryName.trim().isEmpty) {
      return Icons.place_rounded;
    }

    final key = categoryName
        .toLowerCase()
        .trim();

    return categoryIcons[key] ??
        Icons.place_rounded;
  }

  // ==========================================================
  // COLOR SUAVE DE CATEGORÍA
  // ==========================================================

  /// Se utiliza para fondos suaves de chips, badges,
  /// tarjetas y estados seleccionados.
  static Color getSoftColorForCategory(
    String? categoryName,
  ) {
    return getColorForCategory(
      categoryName,
    ).withValues(
      alpha: 0.14,
    );
  }

  // ==========================================================
  // COLOR DE BORDE DE CATEGORÍA
  // ==========================================================

  /// Se utiliza para bordes y contornos relacionados
  /// con la categoría.
  static Color getBorderColorForCategory(
    String? categoryName,
  ) {
    return getColorForCategory(
      categoryName,
    ).withValues(
      alpha: 0.35,
    );
  }
}