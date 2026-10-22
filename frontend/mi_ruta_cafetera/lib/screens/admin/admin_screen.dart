import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/admin/admin_menu_lateral.dart';
import '../../widgets/admin/admin_proximamente.dart';
import '../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';

import 'admin_inicio.dart';
import 'admin_perfil.dart';
import 'admin_sitio_list_screen.dart';

import '../mapa_screen_2.dart';

import '../../screens/admin/usuario/pantalla_usuarios_admin.dart';

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

  late final FotoPerfilAdminControlador fotoPerfilControlador;

  @override
  void initState() {
    super.initState();
    fotoPerfilControlador = FotoPerfilAdminControlador();
    fotoPerfilControlador.cargarFoto();
  }

  String _normalizarOpcion(String opcion) {
    switch (opcion.trim().toLowerCase()) {
      case 'inicio':
      case 'home':
        return 'inicio';

      case 'estadistica':
      case 'estadisticas':
        return 'estadisticas';

      case 'sitio':
      case 'sitios':
      case 'sitios_turisticos':
        return 'sitios';

      case 'actividad':
      case 'actividades':
      case 'actividad_pendiente':
      case 'actividades_pendientes':
        return 'actividades';

      case 'producto':
      case 'productos':
      case 'producto_pendiente':
      case 'productos_pendientes':
      case 'productos-pendientes':
        return 'productos';

      case 'categoria':
      case 'categorias':
        return 'categorias';

      case 'contenido':
      case 'contenidos':
      case 'moderacion':
      case 'moderacion_contenidos':
      case 'moderacion-contenidos':
        return 'contenido';

      case 'resena':
      case 'resenas':
        return 'resenas';

      case 'reserva':
      case 'reservas':
        return 'reservas';

      case 'reporte':
      case 'reportes':
        return 'reportes';

      case 'usuario':
      case 'usuarios':
        return 'usuarios';

      case 'perfil':
      case 'mi_cuenta':
        return 'perfil';

      case 'logout':
      case 'cerrar_sesion':
        return 'logout';

      default:
        return 'inicio';
    }
  }

  void _cambiarOpcion(String opcion) {
    if (!mounted) return;

    final opcionNormalizada = _normalizarOpcion(opcion);

    if (opcionNormalizada == 'logout') {
      _mostrarConfirmacionCerrarSesion();
      return;
    }

    setState(() {
      _opcionSeleccionada = opcionNormalizada;
    });
  }

  Future<void> _mostrarConfirmacionCerrarSesion() async {
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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Debes cerrar la sesión desde el flujo de autenticación.',
        ),
      ),
    );
  }

  void _abrirMapa() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MapaScreen2(),
      ),
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
        return 'Panel de administración';

      case 'estadisticas':
        return 'Estadísticas';

      case 'sitios':
        return 'Sitios turísticos';

      case 'actividades':
        return 'Actividades pendientes';

      case 'productos':
        return 'Productos pendientes';

      case 'categorias':
        return 'Categorías';

      case 'contenido':
        return 'Moderación de contenidos';

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

  Widget _crearContenido() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return _inicio();

      case 'sitios':
        return _sitios();

      case 'productos':
        return const AdminProximamente(nombre: 'Productos');

      case 'perfil':
        return AdminPerfil(
          nombre: widget.nombre,
          email: widget.email,
        );

      case 'estadisticas':
        return const AdminProximamente(nombre: 'Estadísticas');

      case 'categorias':
        return const AdminProximamente(nombre: 'Categorías');

      case 'actividades':
        return const AdminProximamente(nombre: 'Actividades');

      case 'contenido':
        return const AdminProximamente(nombre: 'Moderación de contenidos');

      case 'resenas':
        return const AdminProximamente(nombre: 'Reseñas');

      case 'reservas':
        return const AdminProximamente(nombre: 'Reservas');

      case 'reportes':
        return const AdminProximamente(nombre: 'Reportes');

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
      onAbrirMapa: _abrirMapa,
      onGestionarSitios: () {
        _cambiarOpcion('sitios');
      },
    );
  }

  Widget _sitios() {
    return const AdminSitioListScreen();
  }

  @override
  void dispose() {
    fotoPerfilControlador.dispose();
    super.dispose();
  }
}