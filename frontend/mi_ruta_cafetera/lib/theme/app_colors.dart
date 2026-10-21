
import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  
  // =====================================================
  // IDENTIDAD VISUAL EXCLUSIVA DEL PANEL DE SITIO
  // Aplicable únicamente a las pantallas de gestión del sitio.
  // No reemplaza los colores globales de la aplicación.
  // =====================================================

  // Colores principales del panel
  static const Color sitioPrimary = Color(0xFF214F3D);
  static const Color sitioPrimaryDark = Color(0xFF163A2C);
  static const Color sitioAccent = Color(0xFFBD8B43);

  // Fondos y superficies
  static const Color sitioBackground = Color(0xFFF5F0E6);
  static const Color sitioSurface = Color(0xFFFFFFFF);
  static const Color sitioSurfaceSoft = Color(0xFFFAF7F0);
  static const Color sitioSurfaceGreen = Color(0xFFE8F0E9);

  // Textos
  static const Color sitioTextPrimary = Color(0xFF292D29);
  static const Color sitioTextSecondary = Color(0xFF6C746D);
  static const Color sitioTextOnPrimary = Color(0xFFFFFFFF);

  // Bordes y sombras
  static const Color sitioBorder = Color(0xFFDED5C8);
  static const Color sitioDivider = Color(0xFFEAE3D8);
  static const Color sitioCardShadow = Color(0x12000000);

  // Estados del panel
  static const Color sitioSuccess = Color(0xFF347653);
  static const Color sitioSuccessSoft = Color(0xFFE4F1E7);
  static const Color sitioInfo = Color(0xFF397A9B);
  static const Color sitioInfoSoft = Color(0xFFE5F0F5);
  static const Color sitioWarning = Color(0xFF98651E);
  static const Color sitioWarningSoft = Color(0xFFFFF0D8);
  static const Color sitioError = Color(0xFFB7433C);
  static const Color sitioErrorSoft = Color(0xFFF9E8E5);


  // IDENTIDAD PRINCIPAL
  static const Color primary = Color(0xFF174B35);
  static const Color primaryDark = Color(0xFF0B2F21);
  static const Color secondary = Color(0xFFF47721);
  static const Color tertiary = Color(0xFF9A5A3A);

  // IDENTIDAD CAFETERA Y NATURAL
  static const Color coffeeDark = Color(0xFF2B1A12);
  static const Color coffeeLight = Color(0xFFA86F48);
  static const Color coffee = Color(0xFF6F4328);
  static const Color nature = Color(0xFF397A55);
  static const Color natureLight = Color(0xFF8EB89A);
  static const Color natureDark = Color(0xFF123D2A);

  // BORDES DEL PANEL ADMINISTRATIVO
  static const Color adminBorder = Color(0xFFB58A70);

  // FONDOS Y SUPERFICIES
  static const Color background = Color(0xFFF4F0E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE9E3D7);
  static const Color cream = Color(0xFFF5EBDD);
  static const Color creamLight = Color(0xFFFBF7F0);
  static const Color surfaceDark = Color(0xFF103B29);
  static const Color surfaceGreen = Color(0xFF1B4A34);
  static const Color orangeSoft = Color(0xFFFFE4D0);

  // TEXTOS
  static const Color textPrimary = Color(0xFF172019);
  static const Color textSecondary = Color(0xFF657069);
  static const Color textLight = Color(0xFF929B95);
  static const Color textOnDark = Color(0xFFF8F4EC);
  static const Color textOnDarkSecondary = Color(0xFFC7D1CA);

  // BORDES Y SOMBRAS
  static const Color divider = Color(0xFFE2DED5);
  static const Color border = Color(0xFFD9D4C9);
  static const Color borderDark = Color(0xFF315745);
  static const Color cardShadow = Color(0x18000000);
  static const Color strongShadow = Color(0x26000000);

  // ESTADOS
  static const Color success = Color(0xFF3E8E5B);
  static const Color info = Color(0xFF4C8DA8);
  static const Color warning = Color(0xFFE09A2D);
  static const Color error = Color(0xFFC94A3D);

  // COLORES BÁSICOS
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // COLORES ORIGINALES DE CATEGORÍAS
  static const Color categoryCafe = Color(0xFFB86B2C);
  static const Color categoryArtesanias = Color(0xFF9B5C8F);
  static const Color categoryGastronomia = Color(0xFFD65C45);
  static const Color categoryAlojamiento = Color(0xFF4D7FA3);
  static const Color categoryFamilia = Color(0xFFD39A35);
  static const Color categoryNaturaleza = Color(0xFF4E9568);
  static const Color categoryCultura = Color(0xFF8B6547);
  static const Color categoryAventuras = Color(0xFF2E7D68);
  static const Color categoryMiradores = Color(0xFF527FA6);
  static const Color catDefault = Color(0xFF6F7A73);

  // COLORES EXCLUSIVOS DE LOS NUEVOS ICONOS
  static const Color iconAves = Color(0xFF247BA0);
  static const Color iconMariposas = Color(0xFFB76E9B);
  static const Color iconFauna = Color(0xFFA66A45);
  static const Color iconCaminatas = Color(0xFF53856A);
  static const Color iconCiclismo = Color(0xFFC47732);
  static const Color iconJardines = Color(0xFF829447);
  static const Color iconAgua = Color(0xFF368A9B);
  static const Color iconCamping = Color(0xFF8C6D4F);
  static const Color iconMontanas = Color(0xFF657DA8);

  // COMPATIBILIDAD CON NOMBRES ANTERIORES
  static const Color catFincaCafetera = categoryCafe;
  static const Color catTiendaEspecial = categoryCafe;
  static const Color catEcoturismo = categoryNaturaleza;
  static const Color catGastronomia = categoryGastronomia;
  static const Color catAlojamiento = categoryAlojamiento;
  static const Color catArtesanias = categoryArtesanias;

  // MAPA ORIGINAL DE COLORES POR CATEGORÍA
  static const Map<String, Color> categoryColors = {
    // Café
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

    // Artesanías
    'artesanías y productos locales': categoryArtesanias,
    'artesanias y productos locales': categoryArtesanias,
    'artesanías': categoryArtesanias,
    'artesanias': categoryArtesanias,
    'productos locales': categoryArtesanias,

    // Aventuras
    'aventuras': categoryAventuras,
    'aventura': categoryAventuras,
    'deportes de aventura': categoryAventuras,

    // Cultura e historia
    'cultura e historia': categoryCultura,
    'cultura': categoryCultura,
    'historia': categoryCultura,
    'patrimonio': categoryCultura,

    // Experiencias familiares
    'experiencias familiares': categoryFamilia,
    'experiencia familiar': categoryFamilia,
    'familia': categoryFamilia,
    'familiar': categoryFamilia,

    // Gastronomía
    'gastronomía': categoryGastronomia,
    'gastronomia': categoryGastronomia,
    'restaurante': categoryGastronomia,
    'comida': categoryGastronomia,

    // Alojamiento
    'alojamiento': categoryAlojamiento,
    'hotel': categoryAlojamiento,
    'hospedaje': categoryAlojamiento,

    // Miradores y paisajes
    'miradores y paisajes': categoryMiradores,
    'mirador': categoryMiradores,
    'miradores': categoryMiradores,
    'paisajes': categoryMiradores,

    // Naturaleza y ecoturismo
    'naturaleza y ecoturismo': categoryNaturaleza,
    'naturaleza': categoryNaturaleza,
    'ecoturismo': categoryNaturaleza,
    'senderismo': categoryNaturaleza,
    'parque natural': categoryNaturaleza,
  };

  // ICONOS POR CATEGORÍA
  // Fuente única de iconos de categoría de toda la aplicación
  // (Material Icons redondeados). Los colores siguen viniendo de
  // categoryColors / newIconColors.
  static const Map<String, IconData> categoryIcons = {
    'café y experiencias cafeteras': Icons.coffee_rounded,
    'cafe y experiencias cafeteras': Icons.coffee_rounded,
    'café': Icons.coffee_rounded,
    'cafe': Icons.coffee_rounded,
    'café especial': Icons.coffee_rounded,
    'cafe especial': Icons.coffee_rounded,
    'finca cafetera': Icons.agriculture_rounded,
    'finca': Icons.agriculture_rounded,
    'fincas': Icons.agriculture_rounded,
    'agroturismo': Icons.agriculture_rounded,
    'cafetería': Icons.local_cafe_rounded,
    'cafeteria': Icons.local_cafe_rounded,
    'tienda': Icons.storefront_rounded,
    'artesanías y productos locales': Icons.brush_rounded,
    'artesanias y productos locales': Icons.brush_rounded,
    'artesanías': Icons.brush_rounded,
    'artesanias': Icons.brush_rounded,
    'productos locales': Icons.shopping_bag_rounded,
    'aventuras': Icons.explore_rounded,
    'aventura': Icons.explore_rounded,
    'deportes de aventura': Icons.kayaking_rounded,
    'cultura e historia': Icons.museum_rounded,
    'cultura': Icons.theater_comedy_rounded,
    'historia': Icons.account_balance_rounded,
    'patrimonio': Icons.account_balance_rounded,
    'experiencias familiares': Icons.family_restroom_rounded,
    'experiencia familiar': Icons.family_restroom_rounded,
    'familia': Icons.family_restroom_rounded,
    'familiar': Icons.family_restroom_rounded,
    'gastronomía': Icons.local_dining_rounded,
    'gastronomia': Icons.local_dining_rounded,
    'restaurante': Icons.local_dining_rounded,
    'comida': Icons.local_dining_rounded,
    'alojamiento': Icons.cottage_rounded,
    'hospedaje': Icons.bed_rounded,
    'hotel': Icons.hotel_rounded,
    'miradores y paisajes': Icons.landscape_rounded,
    'paisajes': Icons.landscape_rounded,
    'montañas': Icons.landscape_rounded,
    'montanas': Icons.landscape_rounded,
    'mirador': Icons.panorama_rounded,
    'miradores': Icons.panorama_rounded,
    'naturaleza y ecoturismo': Icons.emoji_nature_rounded,
    'naturaleza': Icons.emoji_nature_rounded,
    'parque natural': Icons.emoji_nature_rounded,
    'ecoturismo': Icons.eco_rounded,
    'senderismo': Icons.hiking_rounded,
    'avistamiento de aves': Icons.flutter_dash_rounded,
    'avistamiento aves': Icons.flutter_dash_rounded,
    'aves': Icons.flutter_dash_rounded,
    'mariposas': Icons.eco_rounded,
    'mariposas y naturaleza': Icons.eco_rounded,
    'jardines': Icons.eco_rounded,
    'flores': Icons.eco_rounded,
    'fauna': Icons.pets_rounded,
    'animales': Icons.pets_rounded,
    'caminata': Icons.directions_walk_rounded,
    'caminatas': Icons.directions_walk_rounded,
    'ciclismo': Icons.directions_bike_rounded,
    'bicicleta': Icons.directions_bike_rounded,
    'ríos y cascadas': Icons.waves_rounded,
    'rios y cascadas': Icons.waves_rounded,
    'rio': Icons.waves_rounded,
    'río': Icons.waves_rounded,
    'ríos': Icons.waves_rounded,
    'rios': Icons.waves_rounded,
    'camping': Icons.nature_people_rounded,
  };

  // ICONO POR PALABRA CLAVE
  // Respaldo para nombres de categoría que no coinciden exactamente
  // con categoryIcons (por ejemplo "Gastronomía local"). Se compara
  // sin acentos y en el orden en que están escritas.
  static const Map<String, IconData> _iconosPorPalabra = {
    'cafe': Icons.coffee_rounded,
    'naturaleza': Icons.emoji_nature_rounded,
    'ecoturismo': Icons.eco_rounded,
    'mirador': Icons.panorama_rounded,
    'paisaje': Icons.landscape_rounded,
    'gastronom': Icons.local_dining_rounded,
    'cultura': Icons.theater_comedy_rounded,
    'historia': Icons.account_balance_rounded,
    'patrimonio': Icons.account_balance_rounded,
    'artesania': Icons.brush_rounded,
    'productos locales': Icons.shopping_bag_rounded,
    'aventura': Icons.explore_rounded,
    'alojamiento': Icons.cottage_rounded,
    'hospedaje': Icons.bed_rounded,
    'hotel': Icons.hotel_rounded,
    'famil': Icons.family_restroom_rounded,
  };

  static String _sinAcentos(String texto) {
    return texto
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  // COLORES SOLO PARA LOS NUEVOS ICONOS
  static const Map<String, Color> newIconColors = {
    'avistamiento de aves': iconAves,
    'avistamiento aves': iconAves,
    'aves': iconAves,

    'mariposas': iconMariposas,
    'mariposas y naturaleza': iconMariposas,

    'fauna': iconFauna,
    'animales': iconFauna,

    'caminata': iconCaminatas,
    'caminatas': iconCaminatas,

    'ciclismo': iconCiclismo,
    'bicicleta': iconCiclismo,

    'jardines': iconJardines,
    'flores': iconJardines,

    'ríos y cascadas': iconAgua,
    'rios y cascadas': iconAgua,
    'rio': iconAgua,
    'río': iconAgua,
    'ríos': iconAgua,
    'rios': iconAgua,

    'camping': iconCamping,

    'montañas': iconMontanas,
    'montanas': iconMontanas,
  };

  // OBTENER COLOR GENERAL DE CATEGORÍA
  static Color getColorForCategory(String? categoryName) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      return catDefault;
    }

    final key = categoryName.toLowerCase().trim();
    return categoryColors[key] ?? catDefault;
  }

  // OBTENER COLOR DEL ICONO
  // Los iconos nuevos usan su color propio.
  // Los anteriores conservan su color original.
  static Color getIconColorForCategory(String? categoryName) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      return catDefault;
    }

    final key = categoryName.toLowerCase().trim();
    return newIconColors[key] ?? getColorForCategory(key);
  }

  // OBTENER ICONO DE CATEGORÍA
  static IconData getIconForCategory(String? categoryName) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      return Icons.place_rounded;
    }

    final key = categoryName.toLowerCase().trim();

    final exacto = categoryIcons[key];

    if (exacto != null) {
      return exacto;
    }

    final nombre = _sinAcentos(key);

    for (final entrada in _iconosPorPalabra.entries) {
      if (nombre.contains(entrada.key)) {
        return entrada.value;
      }
    }

    return Icons.place_rounded;
  }

  // COLOR SUAVE DE CATEGORÍA
  static Color getSoftColorForCategory(String? categoryName) {
    return getColorForCategory(categoryName).withValues(alpha: 0.14);
  }

  // COLOR DE BORDE DE CATEGORÍA
  static Color getBorderColorForCategory(String? categoryName) {
    return getColorForCategory(categoryName).withValues(alpha: 0.35);
  }
}
