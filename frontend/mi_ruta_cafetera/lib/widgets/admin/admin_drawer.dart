import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'admin_drawer_header.dart';
import 'admin_drawer_item.dart';
import 'admin_drawer_logout.dart';

class AdminDrawer extends StatelessWidget {
  final String nombre;
  final String email;
  final Function(String) onOpcionSeleccionada;

  const AdminDrawer({
    super.key,
    required this.nombre,
    required this.email,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ==================================================
          // INFORMACIÓN DEL ADMINISTRADOR
          // ==================================================

          AdminDrawerHeader(
            nombre: nombre,
            email: email,
          ),

          // ==================================================
          // MENÚ PRINCIPAL
          // ==================================================

          AdminDrawerItem(
            icon: Icons.dashboard,
            titulo: 'Inicio',
            opcion: 'inicio',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminDrawerItem(
            icon: Icons.bar_chart,
            titulo: 'Estadísticas',
            opcion: 'estadisticas',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminDrawerItem(
            icon: Icons.location_on,
            titulo: 'Sitios turísticos',
            opcion: 'sitios',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminDrawerItem(
            icon: Icons.category,
            titulo: 'Categorías',
            opcion: 'categorias',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminDrawerItem(
            icon: Icons.article,
            titulo: 'Contenido',
            opcion: 'contenido',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminDrawerItem(
            icon: Icons.star,
            titulo: 'Reseñas',
            opcion: 'resenas',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminDrawerItem(
            icon: Icons.people,
            titulo: 'Usuarios',
            opcion: 'usuarios',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          Divider(
            color: AppColors.divider,
          ),

          // ==================================================
          // MI CUENTA
          // ==================================================

          AdminDrawerItem(
            icon: Icons.person,
            titulo: 'Mi cuenta',
            opcion: 'perfil',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          const Spacer(),

          // ==================================================
          // CERRAR SESIÓN
          // ==================================================

          AdminDrawerLogout(
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
        ],
      ),
    );
  }
}