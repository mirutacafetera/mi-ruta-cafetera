import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';

class MapaMarcador extends StatelessWidget {
  final SitioTuristicoModel sitio;
  final bool seleccionado;
  final int numero;
  final VoidCallback onTap;

  const MapaMarcador({
    super.key,
    required this.sitio,
    required this.seleccionado,
    required this.numero,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorCategoria = _obtenerColorCategoria();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: seleccionado ? 44 : 38,
            height: seleccionado ? 44 : 38,
            decoration: BoxDecoration(
              color: seleccionado
                  ? Colors.orange.shade700
                  : colorCategoria,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: seleccionado ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: seleccionado
                      ? Colors.orange.withValues(alpha: 0.45)
                      : Colors.black38,
                  blurRadius: seleccionado ? 10 : 6,
                  spreadRadius: seleccionado ? 2 : 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: seleccionado
                ? Text(
                    '$numero',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    _obtenerIconoCategoria(),
                    color: Colors.white,
                    size: 20,
                  ),
          ),

          Container(
            width: 3,
            height: 12,
            color: seleccionado
                ? Colors.orange.shade700
                : colorCategoria,
          ),
        ],
      ),
    );
  }

  Color _obtenerColorCategoria() {
    final categoria =
        sitio.categoriaNombre.toLowerCase();

    if (categoria.contains('café') ||
        categoria.contains('cafe')) {
      return Colors.brown;
    }

    if (categoria.contains('naturaleza') ||
        categoria.contains('aventura')) {
      return Colors.green.shade700;
    }

    if (categoria.contains('mirador')) {
      return Colors.teal.shade700;
    }

    if (categoria.contains('cultura') ||
        categoria.contains('historia')) {
      return Colors.deepPurple;
    }

    if (categoria.contains('artesanía') ||
        categoria.contains('artesania')) {
      return Colors.orange.shade700;
    }

    if (categoria.contains('familiar') ||
        categoria.contains('familia')) {
      return Colors.amber.shade800;
    }

    if (categoria.contains('alojamiento') ||
        categoria.contains('hotel') ||
        categoria.contains('hospedaje')) {
      return Colors.blue;
    }

    if (categoria.contains('gastronom')) {
      return Colors.red.shade700;
    }

    if (categoria.contains('relig')) {
      return Colors.deepPurple.shade700;
    }

    return Colors.teal;
  }

  IconData _obtenerIconoCategoria() {
    final categoria =
        sitio.categoriaNombre.toLowerCase();

    if (categoria.contains('café') ||
        categoria.contains('cafe')) {
      return Icons.coffee;
    }

    if (categoria.contains('naturaleza') ||
        categoria.contains('aventura')) {
      return Icons.park;
    }

    if (categoria.contains('mirador')) {
      return Icons.landscape;
    }

    if (categoria.contains('cultura') ||
        categoria.contains('historia')) {
      return Icons.account_balance;
    }

    if (categoria.contains('artesanía') ||
        categoria.contains('artesania')) {
      return Icons.storefront;
    }

    if (categoria.contains('familiar') ||
        categoria.contains('familia')) {
      return Icons.family_restroom;
    }

    if (categoria.contains('alojamiento') ||
        categoria.contains('hotel') ||
        categoria.contains('hospedaje')) {
      return Icons.hotel;
    }

    if (categoria.contains('gastronom')) {
      return Icons.restaurant;
    }

    if (categoria.contains('relig')) {
      return Icons.church;
    }

    return Icons.location_on;
  }
}