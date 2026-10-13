import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

import '../../widgets/admin/admin_menu_lateral.dart';
import '../../widgets/admin/admin_proximamente.dart';

import 'admin_inicio.dart';
import 'admin_perfil.dart';
import 'admin_actividades_screen.dart';
import 'admin_contenidos_screen.dart';
import 'admin_sitio_list_screen.dart';

import '../mapa_screen_2.dart';

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
  // NORMALIZAR IDENTIFICADORES DEL MENÚ
  // ============================================================

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

  // ============================================================
  // CAMBIAR OPCIÓN DEL MENÚ
  // ============================================================

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

  // ============================================================
  // CONFIRMAR CIERRE DE SESIÓN
  // ============================================================

  Future<void> _mostrarConfirmacionCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Deseas cerrar la sesión de administrador?'),
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

    // La sesión se limpia y la navegación se realiza en el flujo
    // de autenticación correspondiente.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Debes cerrar la sesión desde el flujo de autenticación.',
        ),
      ),
    );
  }

  // ============================================================
  // ABRIR MAPA TURÍSTICO
  // ============================================================

  void _abrirMapa() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MapaScreen2()));
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
  // TÍTULO DE LA PANTALLA
  // ============================================================

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

  // ============================================================
  // CONTENIDO SEGÚN LA OPCIÓN SELECCIONADA
  // ============================================================

  Widget _crearContenido() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return _inicio();

      case 'sitios':
        return _sitios();

      case 'actividades':
        return const AdminActividadesScreen();

      case 'contenido':
        return const AdminContenidosScreen();

      case 'perfil':
        return AdminPerfil(nombre: widget.nombre, email: widget.email);

      case 'estadisticas':
        return const AdminProximamente(nombre: 'Estadísticas');

      case 'categorias':
        return const AdminProximamente(nombre: 'Categorías');

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

  // ============================================================
  // INICIO DEL PANEL
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
  // GESTIÓN DE SITIOS TURÍSTICOS
  // ============================================================

  Widget _sitios() {
    return const AdminSitioListScreen();
  }
}
