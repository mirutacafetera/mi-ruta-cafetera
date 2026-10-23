
import 'package:flutter/material.dart';

import '../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../theme/app_dimensions.dart';
import 'admin_encabezado_menu.dart';
import 'admin_iconos_menu.dart';
import 'admin_cerrar_sesion.dart';

class AdminMenuLateral extends StatelessWidget {
  final String nombre;
  final String email;
  final FotoPerfilAdminControlador fotoPerfilControlador;
  final Function(String) onOpcionSeleccionada;
  final String opcionSeleccionada;

  const AdminMenuLateral({
    super.key,
    required this.nombre,
    required this.email,
    required this.fotoPerfilControlador,
    required this.onOpcionSeleccionada,
    required this.opcionSeleccionada,
  });

  static const Color background = Color(0xFFF4F0E8);
  static const Color coffeeLight = Color(0xFFA86F48);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.84,
      backgroundColor: background,
      elevation: 8,
      child: Column(
        children: [
          AdminEncabezadoMenu(
            nombre: nombre,
            email: email,
            fotoPerfilControlador: fotoPerfilControlador,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: AppDimensions.spacingSm,
                left: AppDimensions.spacingSm,
                right: AppDimensions.spacingSm,
                bottom: AppDimensions.spacingSm,
              ),
              children: [
                _opcion(
                  Icons.dashboard_rounded,
                  'Inicio',
                  'inicio',
                ),
                _opcion(
                  Icons.bar_chart_rounded,
                  'Estadísticas',
                  'estadisticas',
                ),
                _opcion(
                  Icons.location_on_rounded,
                  'Sitios turísticos',
                  'sitios',
                ),
                _opcion(
                  Icons.manage_accounts_rounded,
                  'Cuentas de sitios',
                  'cuentasitio',
                ),
                _opcion(
                  Icons.category_rounded,
                  'Categorías',
                  'categorias',
                ),
                _opcion(
                  Icons.event_available_rounded,
                  'Actividades',
                  'actividades',
                ),
                _opcion(
                  Icons.inventory_2_rounded,
                  'Productos',
                  'productos',
                ),
                _opcion(
                  Icons.article_rounded,
                  'Contenido',
                  'contenido',
                ),
                
                _opcion(
                  Icons.star_rounded,
                  'Reseñas',
                  'resenas',
                ),
                _opcion(
                  Icons.calendar_month_rounded,
                  'Reservas',
                  'reservas',
                ),
                _opcion(
                  Icons.campaign_rounded,
                  'Reportes',
                  'reportes',
                ),
                _opcion(
                  Icons.report_problem_rounded,
                  'Reportes de sitios',
                  'reportes_sitios',
                ),
                _opcion(
                  Icons.people_alt_rounded,
                  'Usuarios',
                  'usuarios',
                ),
                const Divider(
                  color: coffeeLight,
                  thickness: 1,
                  height: AppDimensions.spacingLg,
                ),
                _opcion(
                  Icons.person_rounded,
                  'Mi cuenta',
                  'perfil',
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: const BoxDecoration(
                color: background,
                border: Border(
                  top: BorderSide(
                    color: coffeeLight,
                    width: 1,
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

  Widget _opcion(
    IconData icono,
    String titulo,
    String opcion,
  ) {
    return AdminIconoMenu(
      icon: icono,
      titulo: titulo,
      opcion: opcion,
      opcionSeleccionada: opcionSeleccionada,
      onOpcionSeleccionada: onOpcionSeleccionada,
    );
  }
}
