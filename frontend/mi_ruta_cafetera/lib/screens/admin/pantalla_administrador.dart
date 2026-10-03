import 'package:flutter/material.dart';

import '../../controllers/admin/controlador_pantalla_administrador.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/admin/admin_menu_lateral.dart';
import 'admin_inicio.dart';
import 'admin_perfil.dart';
import '../../widgets/admin/admin_proximamente.dart';
import '../mapa_screen_2.dart';
import 'sitio_turistico/pantalla_lista_sitios.dart';

class PantallaAdministrador extends StatefulWidget {
  final String nombre;
  final String email;

  const PantallaAdministrador({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  State<PantallaAdministrador> createState() => _PantallaAdministradorState();
}

class _PantallaAdministradorState extends State<PantallaAdministrador> {
  late final ControladorPantallaAdministrador controlador;

  @override
  void initState() {
    super.initState();
    controlador = ControladorPantallaAdministrador()..addListener(_actualizar);
  }

  void _actualizar() {
    if (mounted) setState(() {});
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapaScreen2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controlador.titulo),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppDimensions.elevationNone,
      ),
      drawer: AdminMenuLateral(
        nombre: widget.nombre,
        email: widget.email,
        onOpcionSeleccionada: controlador.cambiarOpcion,
      ),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    switch (controlador.opcion) {
      case 'sitios':
        return const PantallaListaSitios();

      case 'perfil':
        return AdminPerfil(nombre: widget.nombre, email: widget.email);

      case 'estadisticas':
        return const AdminProximamente(nombre: 'Estadísticas');

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

      default:
        return _inicio();
    }
  }

  Widget _inicio() {
    return AdminInicio(
      nombre: widget.nombre,
      email: widget.email,
      onAbrirMapa: _abrirMapa,
      onGestionarSitios: () => controlador.cambiarOpcion('sitios'),
    );
  }

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();
    super.dispose();
  }
}
