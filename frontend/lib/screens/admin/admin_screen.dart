import 'package:flutter/material.dart';

import '../../widgets/admin_drawer.dart';
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

  void _cambiarOpcion(String opcion) {
    setState(() {
      _opcionSeleccionada = opcion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloPantalla()),
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
        return _inicio();

      case 'estadisticas':
        return _proximamente('Estadísticas');

      case 'sitios':
        return _sitios();

      case 'contenido':
        return _proximamente('Contenido');

      case 'resenas':
        return _proximamente('Reseñas');

      case 'usuarios':
        return _proximamente('Usuarios');

      case 'perfil':
        return _perfil();

      case 'logout':
        return _inicio();

      default:
        return _inicio();
    }
  }

  // =====================================================
  // INICIO
  // =====================================================

  Widget _inicio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Bienvenido al panel de administración\n'
          'Mi Ruta Cafetera',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // SITIOS TURÍSTICOS
  // =====================================================

  Widget _sitios() {
    return const AdminSitioListScreen();
  }

  // =====================================================
  // OPCIONES QUE TODAVÍA NO DESARROLLAMOS
  // =====================================================

  Widget _proximamente(String nombre) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 60,
            color: Colors.grey,
          ),

          const SizedBox(height: 15),

          Text(
            '$nombre\nPróximamente',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PERFIL
  // =====================================================

  Widget _perfil() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 70,
            color: Color(0xFF1B5E20),
          ),

          const SizedBox(height: 15),

          Text(
            widget.nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(widget.email),
        ],
      ),
    );
  }
}