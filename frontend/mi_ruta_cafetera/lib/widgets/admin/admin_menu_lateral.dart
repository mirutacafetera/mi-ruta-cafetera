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
      backgroundColor: AppColors.background,
      elevation: 8,
      child: Column(
        children: [
          AdminEncabezadoMenu(
            nombre: nombre,
            email: email,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingSm,
              ),
              children: [
                _construirOpcion(
                  icono: Icons.dashboard_rounded,
                  titulo: 'Inicio',
                  opcion: 'inicio',
                ),
                _construirOpcion(
                  icono: Icons.bar_chart_rounded,
                  titulo: 'Estadísticas',
                  opcion: 'estadisticas',
                ),
                _construirOpcion(
                  icono: Icons.location_on_rounded,
                  titulo: 'Sitios turísticos',
                  opcion: 'sitios',
                ),
                _construirOpcion(
                  icono: Icons.manage_accounts_rounded,
                  titulo: 'Cuentas de sitios',
                  opcion: 'cuentasitio',
                ),
                _construirOpcion(
                  icono: Icons.category_rounded,
                  titulo: 'Categorías',
                  opcion: 'categorias',
                ),
                _construirOpcion(
                  icono: Icons.event_available_rounded,
                  titulo: 'Actividades',
                  opcion: 'actividades',
                ),
                _construirOpcion(
                  icono: Icons.article_rounded,
                  titulo: 'Contenido',
                  opcion: 'contenido',
                ),
                _construirOpcion(
                  icono: Icons.star_rounded,
                  titulo: 'Reseñas',
                  opcion: 'resenas',
                ),
                _construirOpcion(
                  icono: Icons.calendar_month_rounded,
                  titulo: 'Reservas',
                  opcion: 'reservas',
                ),

                _construirOpcion(
                   icono: Icons.campaign_rounded,
                  titulo: 'Reportes',
                  opcion: 'reportes',
                ),

                _construirOpcion(
                  icono: Icons.people_alt_rounded,
                  titulo: 'Usuarios',
                  opcion: 'usuarios',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                  ),
                  child: Divider(
                    color: AppColors.divider,
                    thickness: 1,
                  ),
                ),
                _construirOpcion(
                  icono: Icons.person_rounded,
                  titulo: 'Mi cuenta',
                  opcion: 'perfil',
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.only(
                top: AppDimensions.spacingSm,
                bottom: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: AdminCerrarSesion(
                onOpcionSeleccionada: onOpcionSeleccionada,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirOpcion({
    required IconData icono,
    required String titulo,
    required String opcion,
  }) {
    return AdminIconoMenu(
      icon: icono,
      titulo: titulo,
      opcion: opcion,
      onOpcionSeleccionada: onOpcionSeleccionada,
    );
  }
}