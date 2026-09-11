import 'package:flutter/material.dart';

import '../../widgets/admin/admin_drawer.dart';
import '../../widgets/admin/admin_inicio.dart';
import '../../widgets/admin/admin_perfil.dart';
import '../../widgets/admin/admin_proximamente.dart';

import '../mapa_screen_2.dart';
import 'admin_sitio_list_screen.dart';

class AdminScreen extends StatefulWidget {
  final String nombre;
  final String email;

  const AdminScreen({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _opcionSeleccionada = 'inicio';

  // =====================================================
  // CAMBIAR OPCIÓN
  // =====================================================

  void _cambiarOpcion(String opcion) {
    setState(() {
      _opcionSeleccionada = opcion;
    });
  }

  // =====================================================
  // ABRIR MAPA
  // =====================================================

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaScreen2(),
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tituloPantalla(),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      drawer: AdminDrawer(
        nombre: widget.nombre,
        email: widget.email,
        onOpcionSeleccionada: _cambiarOpcion,
      ),
      body: _crearContenido(),
    );
  }

  // =====================================================
  // TÍTULO
  // =====================================================

  String _tituloPantalla() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return 'Panel de administración';

      case 'estadisticas':
        return 'Estadísticas';

      case 'sitios':
        return 'Sitios turísticos';

      case 'contenido':
        return 'Contenido';

      case 'resenas':
        return 'Reseñas';

      case 'usuarios':
        return 'Usuarios';

      case 'perfil':
        return 'Mi cuenta';

      default:
        return 'Panel de administración';
    }
  }

  // =====================================================
  // CONTENIDO
  // =====================================================

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
        return const AdminProximamente(
          nombre: 'Estadísticas',
        );

      case 'sitios':
        return _sitios();

      case 'contenido':
        return const AdminProximamente(
          nombre: 'Contenido',
        );

      case 'resenas':
        return const AdminProximamente(
          nombre: 'Reseñas',
        );

      case 'usuarios':
        return const AdminProximamente(
          nombre: 'Usuarios',
        );

      case 'perfil':
        return AdminPerfil(
          nombre: widget.nombre,
          email: widget.email,
        );

      case 'logout':
        return AdminInicio(
          nombre: widget.nombre,
          email: widget.email,
          onAbrirMapa: _abrirMapa,
          onGestionarSitios: () {
            _cambiarOpcion('sitios');
          },
        );

      default:
        return AdminInicio(
          nombre: widget.nombre,
          email: widget.email,
          onAbrirMapa: _abrirMapa,
          onGestionarSitios: () {
            _cambiarOpcion('sitios');
          },
        );
    }
  }

  // =====================================================
  // SITIOS TURÍSTICOS
  // =====================================================

  Widget _sitios() {
    return const AdminSitioListScreen();
  }
}