
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/admin/admin_menu_lateral.dart';
import '../../widgets/admin/admin_proximamente.dart';
import '../../controllers/admin/cuenta/cuenta_admin_controlador.dart';
import '../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../services/admin/admin_servicio_autenticacion.dart';

import 'admin_inicio.dart';
import 'admin_sitio_list_screen.dart';
import 'cuenta/admin_cuenta.dart';
import 'usuario/pantalla_usuarios_admin.dart';
import '../mapa_screen_2.dart';

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

  late final CuentaAdminController cuentaController;
  late final FotoPerfilAdminControlador fotoPerfilControlador;

  @override
  void initState() {
    super.initState();

    cuentaController = CuentaAdminController();
    fotoPerfilControlador = FotoPerfilAdminControlador();

    _cargarCuentaAdmin();
  }

  Future<void> _cargarCuentaAdmin() async {
    await AdminServicioAutenticacion.cargarToken();

    if (!mounted) return;

    final id = AdminServicioAutenticacion.idAdministrador;

    if (id == null || id.isEmpty) {
      return;
    }

    await cuentaController.cargarCuenta(id);

    if (!mounted) return;

    await fotoPerfilControlador.cargarFoto(
      idAdministrador: id,
    );
  }

  void _cambiarOpcion(String opcion) {
    final seleccion = opcion.toLowerCase().trim();

    if (seleccion == 'logout' ||
        seleccion == 'cerrar_sesion') {
      _mostrarConfirmacionCerrarSesion();
      return;
    }

    setState(() {
      _opcionSeleccionada = _normalizarOpcion(seleccion);
    });
  }

  String _normalizarOpcion(String opcion) {
    switch (opcion) {
      case 'home':
      case 'inicio':
        return 'inicio';

      case 'sitio':
      case 'sitios':
      case 'sitios_turisticos':
        return 'sitios';

      case 'usuario':
      case 'usuarios':
        return 'usuarios';

      case 'perfil':
      case 'mi_cuenta':
        return 'perfil';

      case 'estadisticas':
        return 'estadisticas';

      case 'categorias':
        return 'categorias';

      case 'actividades':
        return 'actividades';

      case 'productos':
        return 'productos';

      case 'contenido':
        return 'contenido';

      case 'resenas':
        return 'resenas';

      case 'reservas':
        return 'reservas';

      case 'reportes':
        return 'reportes';

      default:
        return 'inicio';
    }
  }

  void _abrirCuenta() {
    _cambiarOpcion('perfil');
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const MapaScreen2(),
      ),
    );
  }

  Future<void> _mostrarConfirmacionCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
      ),
    );

    if (!mounted || confirmar != true) return;

    await AdminServicioAutenticacion.cerrarSesion();

    if (!mounted) return;

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

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
        fotoPerfilControlador: fotoPerfilControlador,
        onOpcionSeleccionada: _cambiarOpcion,
        opcionSeleccionada: _opcionSeleccionada,
      ),
      body: _crearContenido(),
    );
  }

  String _tituloPantalla() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return 'Inicio';

      case 'sitios':
        return 'Sitios turísticos';

      case 'usuarios':
        return 'Usuarios';

      case 'perfil':
        return 'Mi cuenta';

      case 'estadisticas':
        return 'Estadísticas';

      case 'categorias':
        return 'Categorías';

      case 'actividades':
        return 'Actividades';

      case 'productos':
        return 'Productos';

      case 'contenido':
        return 'Moderación de contenido';

      case 'resenas':
        return 'Reseñas';

      case 'reservas':
        return 'Reservas';

      case 'reportes':
        return 'Reportes';

      default:
        return 'Inicio';
    }
  }

  Widget _crearContenido() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return _inicio();

      case 'sitios':
        return const AdminSitioListScreen();

      case 'usuarios':
        return const PantallaUsuariosAdmin();

      case 'perfil':
        return AdminCuenta(
          controller: cuentaController,
          fotoPerfilControlador: fotoPerfilControlador,
          onCerrarSesion: _mostrarConfirmacionCerrarSesion,
        );

      case 'estadisticas':
        return const AdminProximamente(
          nombre: 'Estadísticas',
        );

      case 'categorias':
        return const AdminProximamente(
          nombre: 'Categorías',
        );

      case 'actividades':
        return const AdminProximamente(
          nombre: 'Actividades',
        );

      case 'productos':
        return const AdminProximamente(
          nombre: 'Productos',
        );

      case 'contenido':
        return const AdminProximamente(
          nombre: 'Contenidos',
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
      onGestionarSitios: () => _cambiarOpcion('sitios'),
      onGestionarUsuarios: () => _cambiarOpcion('usuarios'),
      onAbrirCuenta: _abrirCuenta,
    );
  }

  @override
  void dispose() {
    cuentaController.dispose();
    fotoPerfilControlador.dispose();
    super.dispose();
  }
}
