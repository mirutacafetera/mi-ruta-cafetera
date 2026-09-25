import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

import 'admin_encabezado_menu.dart';
import 'admin_iconos_menu.dart';
import 'admin_cerrar_sesion.dart';

class AdminMenuLateral extends StatelessWidget {
  final String nombre;
  final String email;
  final Function(String) onOpcionSeleccionada;

  const AdminMenuLateral({
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
          AdminEncabezadoMenu(nombre: nombre, email: email),

          // ==================================================
          // MENÚ PRINCIPAL
          // ==================================================
          AdminIconoMenu(
            icon: Icons.dashboard,
            titulo: 'Inicio',
            opcion: 'inicio',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.bar_chart,
            titulo: 'Estadísticas',
            opcion: 'estadisticas',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.location_on,
            titulo: 'Sitios turísticos',
            opcion: 'sitios',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.category,
            titulo: 'Categorías',
            opcion: 'categorias',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.article,
            titulo: 'Contenido',
            opcion: 'contenido',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.star,
            titulo: 'Reseñas',
            opcion: 'resenas',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.calendar_month,
            titulo: 'Reservas',
            opcion: 'reservas',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.report,
            titulo: 'Reportes',
            opcion: 'reportes',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          AdminIconoMenu(
            icon: Icons.people,
            titulo: 'Usuarios',
            opcion: 'usuarios',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          Divider(color: AppColors.divider),

          // ==================================================
          // MI CUENTA
          // ==================================================
          AdminIconoMenu(
            icon: Icons.person,
            titulo: 'Mi cuenta',
            opcion: 'perfil',
            onOpcionSeleccionada: onOpcionSeleccionada,
          ),

          const Spacer(),

          // ==================================================
          // CERRAR SESIÓN
          // ==================================================
          AdminCerrarSesion(onOpcionSeleccionada: onOpcionSeleccionada),

          const SizedBox(height: AppDimensions.spacingMd),
        ],
      ),
    );
  }
}
