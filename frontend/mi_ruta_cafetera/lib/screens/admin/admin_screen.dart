import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

import '../../widgets/admin/admin_menu_lateral.dart';
import '../../screens/admin/admin_inicio.dart';
import '../../screens/admin/admin_perfil.dart';
import '../../widgets/admin/admin_proximamente.dart';
import '../../screens/mapa_screen_2.dart';
import '../../screens/admin/admin_sitio_list_screen.dart';

class AdminScreen extends StatefulWidget {
  final String nombre;
  final String email;

  const AdminScreen({super.key, required this.nombre, required this.email});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _opcionSeleccionada = 'inicio';

  // ============================================================
  // CAMBIAR OPCIÓN
  // ============================================================

  void _cambiarOpcion(String opcion) {
    setState(() {
      _opcionSeleccionada = opcion;
    });
  }

  // ============================================================
  // ABRIR MAPA
  // ============================================================

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapaScreen2()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloPantalla()),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppDimensions.elevationNone,
      ),

      drawer: AdminMenuLateral(
        nombre: widget.nombre,
        email: widget.email,
        onOpcionSeleccionada: _cambiarOpcion,
      ),

      body: _crearContenido(),
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  String _tituloPantalla() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return 'Panel de administración';

      case 'estadisticas':
        return 'Estadísticas';

      case 'sitios':
        return 'Sitios turísticos';

      case 'categorias':
        return 'Categorías';

      case 'contenido':
        return 'Contenido';

      case 'resenas':
        return 'Reseñas';

      case 'reservas':
        return 'Reservas';

      case 'reportes':
        return 'Reportes';

      case 'usuarios':
        return 'Usuarios';

      case 'perfil':
        return 'Mi cuenta';

      default:
        return 'Panel de administración';
    }
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _crearContenido() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return AdminInicio(
          nombre: widget.nombre,
          email: widget.email,
          onAbrirMapa: _abrirMapa,
          onGestionarSitios: () {
            _cambiarOpcion('sitios');
          },
        );

      case 'estadisticas':
        return const AdminProximamente(nombre: 'Estadísticas');

      case 'sitios':
        return _sitios();

      case 'categorias':
        return const AdminProximamente(nombre: 'Categorías');

      case 'contenido':
        return const AdminProximamente(nombre: 'Contenido');

      case 'resenas':
        return const AdminProximamente(nombre: 'Reseñas');

      case 'reservas':
        return const AdminProximamente(nombre: 'Reservas');

      case 'reportes':
        return const AdminProximamente(nombre: 'Reportes');

      case 'usuarios':
        return const AdminProximamente(nombre: 'Usuarios');

      case 'perfil':
        return AdminPerfil(nombre: widget.nombre, email: widget.email);

      case 'logout':
        return _inicio();

      default:
        return _inicio();
    }
  }

  // ============================================================
  // INICIO
  // ============================================================

  Widget _inicio() {
    return AdminInicio(
      nombre: widget.nombre,
      email: widget.email,
      onAbrirMapa: _abrirMapa,
      onGestionarSitios: () {
        _cambiarOpcion('sitios');
      },
    );
  }

  // ============================================================
  // SITIOS TURÍSTICOS
  // ============================================================

  Widget _sitios() {
    return const AdminSitioListScreen();
  }
}
