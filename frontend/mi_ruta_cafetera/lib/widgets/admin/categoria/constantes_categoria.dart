import 'package:flutter/material.dart';

import '../../../models/categoria_model.dart';
import '../../../theme/app_colors.dart';

const verdeEncabezado = Color(0xFF174B38);
const naranjaAccion = Color(0xFFFF781F);
const verdeEstado = Color(0xFF248342);
const blancoTarjeta = Color(0xFFF4EBDD);
const cafeTarjeta = Color(0xFF966F52);
const colorTextoSuave = Color(0xFF7D867E);
const fondoContador = Color(0xFFECE4D6);
const colorContador = Color(0xFF76583A);

const iconosCategoria = <String, IconData>{
  'coffee_rounded': Icons.coffee_rounded,
  'palette_rounded': Icons.palette_rounded,
  'restaurant_rounded': Icons.restaurant_rounded,
  'hotel_rounded': Icons.hotel_rounded,
  'family_restroom_rounded': Icons.family_restroom_rounded,
  'park_rounded': Icons.park_rounded,
  'account_balance_rounded': Icons.account_balance_rounded,
  'hiking_rounded': Icons.hiking_rounded,
  'landscape_rounded': Icons.landscape_rounded,
  'flutter_dash_rounded': Icons.flutter_dash,
  'filter_vintage_rounded': Icons.filter_vintage_rounded,
  'pets_rounded': Icons.pets_rounded,
  'directions_walk_rounded': Icons.directions_walk,
  'directions_bike_rounded': Icons.directions_bike,
  'yard_rounded': Icons.yard,
  'waves_rounded': Icons.waves,
  'nature_people_rounded': Icons.nature_people,
  'location_on': Icons.location_on,
  'visibility_rounded': Icons.visibility_rounded,
  'eco_rounded': Icons.eco_rounded,
};

const coloresIconosCategoria = <String, Color>{
  'coffee_rounded': Color(0xFFB86B2C),
  'palette_rounded': Color(0xFF9B5C8F),
  'restaurant_rounded': Color(0xFFD65C45),
  'hotel_rounded': Color(0xFF4D7FA3),
  'family_restroom_rounded': Color(0xFFD39A35),
  'park_rounded': Color(0xFF4E9568),
  'account_balance_rounded': Color(0xFF8B6547),
  'hiking_rounded': Color(0xFF2E7D68),
  'landscape_rounded': Color(0xFF527FA6),
  'flutter_dash_rounded': Color(0xFF247BA0),
  'filter_vintage_rounded': Color(0xFFB76E9B),
  'pets_rounded': Color(0xFFA66A45),
  'directions_walk_rounded': Color(0xFF53856A),
  'directions_bike_rounded': Color(0xFFC47732),
  'yard_rounded': Color(0xFF829447),
  'waves_rounded': Color(0xFF368A9B),
  'nature_people_rounded': Color(0xFF8C6D4F),
  'location_on': Color(0xFF4E9568),
  'visibility_rounded': Color(0xFF247BA0),
  'eco_rounded': Color(0xFF4E9568),
};

IconData obtenerIconoCategoria(CategoriaModel categoria) {
  final icono = categoria.icono.trim().toLowerCase();

  if (iconosCategoria.containsKey(icono) &&
      !['location_on', 'location', 'place'].contains(icono)) {
    return iconosCategoria[icono]!;
  }

  return AppColors.getIconForCategory(
    categoria.nombre.trim().toLowerCase(),
  );
}

Color obtenerColorCategoria(CategoriaModel categoria) {
  final icono = categoria.icono.trim().toLowerCase();

  if (coloresIconosCategoria.containsKey(icono) &&
      !['location_on', 'location', 'place'].contains(icono)) {
    return coloresIconosCategoria[icono]!;
  }

  return AppColors.getIconColorForCategory(categoria.nombre);
}