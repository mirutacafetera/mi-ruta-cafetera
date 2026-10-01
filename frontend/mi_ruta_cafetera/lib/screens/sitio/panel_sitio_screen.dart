import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

import '../../widgets/sitio/encabezado_sitio.dart';
import '../../widgets/sitio/navegacion_sitio.dart';

import 'sitio_actividades_screen.dart';
import 'sitio_contenido_screen.dart';
import 'sitio_dashboard_screen.dart';
import 'sitio_multimedia_screen.dart';
import 'sitio_perfil_screen.dart';
import 'sitio_resenas_screen.dart';
import 'sitio_reservas_screen.dart';

class PanelSitioScreen extends StatefulWidget {
  const PanelSitioScreen({
    super.key,
  });

  @override
  State<PanelSitioScreen> createState() =>
      _PanelSitioScreenState();
}

class _PanelSitioScreenState
    extends State<PanelSitioScreen> {
  // ============================================================
  // ESTADO
  // ============================================================

  int _indiceActual = 0;

  // ============================================================
  // MÓDULOS DEL PANEL
  // ============================================================

  static const List<String> _titulos = [
    'Inicio',
    'Mi sitio',
    'Contenido',
    'Multimedia',
    'Actividades',
    'Reservas',
    'Reseñas',
  ];

  static const List<IconData> _iconos = [
    Icons.dashboard_rounded,
    Icons.storefront_rounded,
    Icons.article_rounded,
    Icons.photo_library_rounded,
    Icons.local_activity_rounded,
    Icons.calendar_month_rounded,
    Icons.star_rounded,
  ];

  // ============================================================
  // PANTALLAS
  // ============================================================

  late final List<Widget> _pantallas = [
    const SitioDashboardScreen(),
    const SitioPerfilScreen(),
    const SitioContenidoScreen(),
    const SitioMultimediaScreen(),
    const SitioActividadesScreen(),
    const SitioReservasScreen(),
    const SitioResenasScreen(),
  ];

  // ============================================================
  // CAMBIAR MÓDULO
  // ============================================================

  void _cambiarModulo(int indice) {
    if (indice < 0 ||
        indice >= _pantallas.length ||
        _indiceActual == indice) {
      return;
    }

    setState(() {
      _indiceActual = indice;
    });
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  void _cerrarSesion() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '¿Deseas cerrar la sesión de tu cuenta de sitio?',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // ------------------------------------------------
                // La lógica real de cierre de sesión se conectará
                // posteriormente con sitio_auth_service.dart.
                // ------------------------------------------------
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text(
                'Cerrar sesión',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;

    final esEscritorio = ancho >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ==========================================================
      // CONTENIDO
      // ==========================================================

      body: SafeArea(
        child: Row(
          children: [
            // ====================================================
            // NAVEGACIÓN ESCRITORIO
            // ====================================================

            if (esEscritorio)
              NavegacionSitio (
                indiceActual: _indiceActual,
                titulos: _titulos,
                iconos: _iconos,
                modoEscritorio: true,
                onSeleccionar: _cambiarModulo,
                onCerrarSesion: _cerrarSesion,
              ),

            // ====================================================
            // ÁREA PRINCIPAL
            // ====================================================

            Expanded(
              child: Column(
                children: [
                  // ------------------------------------------------
                  // CABECERA
                  // ------------------------------------------------

                  EncabezadoSitio(
                    titulo: _titulos[_indiceActual],
                    icono: _iconos[_indiceActual],
                    onCerrarSesion: _cerrarSesion,
                  ),

                  // ------------------------------------------------
                  // MÓDULO ACTUAL
                  // ------------------------------------------------

                  Expanded(
                    child: IndexedStack(
                      index: _indiceActual,
                      children: _pantallas,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // NAVEGACIÓN MÓVIL
      // ==========================================================

      bottomNavigationBar: esEscritorio
          ? null
          : NavegacionSitio(
              indiceActual: _indiceActual,
              titulos: _titulos,
              iconos: _iconos,
              modoEscritorio: false,
              onSeleccionar: _cambiarModulo,
              onCerrarSesion: _cerrarSesion,
            ),
    );
  }
}