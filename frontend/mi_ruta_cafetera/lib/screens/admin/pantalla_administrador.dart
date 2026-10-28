import 'package:flutter/material.dart';

import '../../controllers/admin/controlador_pantalla_administrador.dart';
import '../../controllers/admin/cuenta/cuenta_admin_controlador.dart';
import '../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../services/admin/admin_servicio_autenticacion.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/admin/admin_menu_lateral.dart';
import '../../widgets/admin/fondo_admin.dart';
import '../mapa_screen_2.dart';

import 'admin_inicio.dart';
import 'actividades/pantalla_actividades.dart';
import 'categoria/pantalla_categoria.dart';
import 'contenido/pantalla_contenido.dart';
import 'cuenta/admin_cuenta.dart';
import 'cuenta_sitio/pantalla_cuenta_sitio.dart';
import 'estadistica/pantalla_estadistica.dart';
import 'producto/pantalla_producto.dart';
import 'reporte/pantalla_reporte_admin.dart';
import 'reportes_sitios/pantalla_reportes_sitios_admin.dart';
import 'reserva/pantalla_reserva_admin.dart';
import 'resena/pantalla_resenas_admin.dart';
import 'sitio_turistico/pantalla_lista_sitios.dart';
import 'usuario/pantalla_usuarios_admin.dart';

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

class _PantallaAdministradorState extends State<PantallaAdministrador> {
  late final ControladorPantallaAdministrador controlador;
  late final CuentaAdminController cuentaAdminController;
  late final FotoPerfilAdminControlador fotoPerfilControlador;

  final GlobalKey<ScaffoldState> _claveScaffold =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    controlador = ControladorPantallaAdministrador()
      ..addListener(_actualizar);

    cuentaAdminController = CuentaAdminController();
    fotoPerfilControlador = FotoPerfilAdminControlador();

    _cargarCuenta();
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _cargarCuenta() async {
    await AdminServicioAutenticacion.cargarToken();

    if (!mounted) return;

    final idAdministrador =
        AdminServicioAutenticacion.idAdministrador;

    if (idAdministrador == null || idAdministrador.isEmpty) {
      return;
    }

    await cuentaAdminController.cargarCuenta(idAdministrador);

    if (!mounted) return;

    await fotoPerfilControlador.cargarFoto(
      idAdministrador: idAdministrador,
    );
  }

  Future<void> _cerrarSesion() async {
    await AdminServicioAutenticacion.cerrarSesion();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  Future<void> _confirmarCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            '¿Deseas cerrar la sesión de administrador?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      await _cerrarSesion();
    }
  }

  void _manejarOpcion(String opcion) {
    final opcionNormalizada = opcion.trim().toLowerCase();

    if (opcionNormalizada == 'logout' ||
        opcionNormalizada == 'cerrar_sesion') {
      _confirmarCerrarSesion();
      return;
    }

    controlador.cambiarOpcion(opcionNormalizada);
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const MapaScreen2(),
      ),
    );
  }

  void _abrirUsuarios() {
    controlador.cambiarOpcion('usuarios');
  }

  @override
  Widget build(BuildContext context) {
    final titulo = switch (controlador.opcion) {
      'contenido' => 'Contenidos',
      'productos' => 'Productos',
      'usuarios' => 'Usuarios',
      'reportes_sitios' => 'Reportes de sitios',
      _ => controlador.titulo,
    };

    return Scaffold(
      key: _claveScaffold,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppDimensions.elevationNone,
      ),
      drawer: AdminMenuLateral(
        nombre: widget.nombre,
        email: widget.email,
        fotoPerfilControlador: fotoPerfilControlador,
        onOpcionSeleccionada: _manejarOpcion,
        opcionSeleccionada: controlador.opcion,
      ),
      body: FondoAdmin(
        child: _contenido(),
      ),
    );
  }

  Widget _contenido() {
    switch (controlador.opcion) {
      case 'inicio':
        return _inicio();

      case 'sitios':
        return const PantallaListaSitios();

      case 'actividades':
        return const PantallaActividades();

      case 'productos':
        return const PantallaProducto();

      case 'contenido':
        return const PantallaContenido();

      case 'reportes_sitios':
        return const PantallaReportesSitiosAdmin();

      case 'perfil':
        return AdminCuenta(
          controller: cuentaAdminController,
          fotoPerfilControlador: fotoPerfilControlador,
          onCerrarSesion: _confirmarCerrarSesion,
        );

      case 'categorias':
        return const PantallaCategoria();

      case 'cuentasitio':
        return PantallaCuentasSitio(
          token: AdminServicioAutenticacion.tokenAdmin ?? '',
        );

      case 'estadisticas':
        return const PantallaEstadistica();

      case 'resenas':
        return const PantallaResenasAdmin();

      case 'reservas':
        return const PantallaReservaAdmin();

      case 'reportes':
        return const PantallaReporteAdmin();

      case 'usuarios':
        return const PantallaUsuariosAdmin();

      default:
        return _inicio();
    }
  }

  Widget _inicio() {
    return AdminInicio(
      nombre: widget.nombre,
      email: widget.email,
      fotoPerfilControlador: fotoPerfilControlador,
      onAbrirMapa: _abrirMapa,
      onGestionarSitios: () {
        controlador.cambiarOpcion('sitios');
      },
      onGestionarUsuarios: _abrirUsuarios,
      onAbrirCuenta: () {
        controlador.cambiarOpcion('perfil');
      },
    );
  }

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();
    cuentaAdminController.dispose();
    fotoPerfilControlador.dispose();
    super.dispose();
  }
}