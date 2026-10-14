
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
  const PanelSitioScreen({super.key});

  @override
  State<PanelSitioScreen> createState() => _PanelSitioScreenState();
}

class _PanelSitioScreenState extends State<PanelSitioScreen> {
  int _indiceActual = 0;

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

  late final List<Widget> _pantallas = [
    const SitioDashboardScreen(),
    const SitioPerfilScreen(),
    const SitioContenidoScreen(),
    const SitioMultimediaScreen(),
    const SitioActividadesScreen(),
    const SitioReservasScreen(),
    const SitioResenasScreen(),
  ];

  void _cambiarModulo(int indice) {
    if (indice < 0 || indice >= _pantallas.length) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _indiceActual = indice;
    });
  }

  void _seleccionarModuloMovil(int indice) {
    _cambiarModulo(indice);
    Navigator.of(context).pop();
  }

  void _abrirMenuMovil() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (menuContext) {
        return NavegacionSitio(
          indiceActual: _indiceActual,
          titulos: _titulos,
          iconos: _iconos,
          modoEscritorio: false,
          menuMovil: true,
          onSeleccionar: (indice) {
            _cambiarModulo(indice);
            Navigator.of(menuContext).pop();
          },
          onCerrarSesion: _cerrarSesion,
        );
      },
    );
  }

  void _cerrarSesion() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
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
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final esEscritorio = ancho >= 900;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: esEscritorio
              ? null
              : Drawer(
                  backgroundColor: AppColors.surface,
                  width: ancho < 400 ? ancho * 0.86 : 330,
                  child: NavegacionSitio(
                    indiceActual: _indiceActual,
                    titulos: _titulos,
                    iconos: _iconos,
                    modoEscritorio: false,
                    menuMovil: true,
                    onSeleccionar: _seleccionarModuloMovil,
                    onCerrarSesion: _cerrarSesion,
                  ),
                ),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (esEscritorio)
                  NavegacionSitio(
                    indiceActual: _indiceActual,
                    titulos: _titulos,
                    iconos: _iconos,
                    modoEscritorio: true,
                    menuMovil: false,
                    onSeleccionar: _cambiarModulo,
                    onCerrarSesion: _cerrarSesion,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      EncabezadoSitio(
                        titulo: _titulos[_indiceActual],
                        icono: _iconos[_indiceActual],
                        mostrarMenu: !esEscritorio,
                        onMenu: _abrirMenuMovil,
                        onCerrarSesion: _cerrarSesion,
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: AppColors.background,
                          child: IndexedStack(
                            index: _indiceActual,
                            children: _pantallas,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
