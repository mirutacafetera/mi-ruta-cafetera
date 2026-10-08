import 'package:flutter/material.dart';

import '../../controllers/admin/controlador_pantalla_administrador.dart';
import '../../controllers/admin/cuenta/cuenta_admin_controlador.dart';
import '../../services/admin/admin_servicio_autenticacion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/admin/admin_menu_lateral.dart';
import '../../widgets/admin/admin_proximamente.dart';

import 'admin_inicio.dart';
import 'cuenta/admin_cuenta.dart';
import 'admin_inicio_sesion.dart';

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
  State<PantallaAdministrador> createState() =>
      _PantallaAdministradorState();
}

class _PantallaAdministradorState
    extends State<PantallaAdministrador> {
  late final ControladorPantallaAdministrador controlador;
  late final CuentaAdminController cuentaAdminController;

  @override
  void initState() {
    super.initState();

    controlador = ControladorPantallaAdministrador()
      ..addListener(_actualizar);

    cuentaAdminController = CuentaAdminController();

    _cargarCuenta();
  }

  Future<void> _cargarCuenta() async {
    await AdminServicioAutenticacion.cargarToken();

    final idAdministrador =
        AdminServicioAutenticacion.idAdministrador;

    if (idAdministrador != null &&
        idAdministrador.isNotEmpty) {
      await cuentaAdminController.cargarCuenta(
        idAdministrador,
      );
    }
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _cerrarSesion() async {
    await AdminServicioAutenticacion.cerrarSesion();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminInicioSesion(),
      ),
      (route) => false,
    );
  }

  void _manejarOpcion(String opcion) {
    if (opcion == 'logout') {
      _cerrarSesion();
      return;
    }

    controlador.cambiarOpcion(opcion);
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapaScreen2(),
      ),
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
        onOpcionSeleccionada: _manejarOpcion,
      ),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    switch (controlador.opcion) {
      case 'sitios':
        return const PantallaListaSitios();

      case 'perfil':
        return AdminCuenta(
          controller: cuentaAdminController,
        );

      case 'estadisticas':
        return const AdminProximamente(
          nombre: 'Estadísticas',
        );

      case 'categorias':
        return const AdminProximamente(
          nombre: 'Categorías',
        );

      case 'contenido':
        return const AdminProximamente(
          nombre: 'Contenido',
        );

      case 'resenas':
        return const AdminProximamente(
          nombre: 'Reseñas',
        );

      case 'reservas':
        return const AdminProximamente(
          nombre: 'Reservas',
        );

      case 'reportes':
        return const AdminProximamente(
          nombre: 'Reportes',
        );

      case 'usuarios':
        return const AdminProximamente(
          nombre: 'Usuarios',
        );

      default:
        return _inicio();
    }
  }

  Widget _inicio() {
    return AdminInicio(
      nombre: widget.nombre,
      email: widget.email,
      onAbrirMapa: _abrirMapa,
      onGestionarSitios: () {
        controlador.cambiarOpcion('sitios');
      },
    );
  }

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();
    cuentaAdminController.dispose();

    super.dispose();
  }
}