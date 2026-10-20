import 'package:flutter/material.dart';

import '../../../models/sitio_turistico_model.dart';
import '../../../models/sitio/sitio_actividad_model.dart';
import '../../../services/usuario/usuario_sesion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/mapa/mapa_detalle_sitio.dart';
import '../../../widgets/usuario/detalle_sitio/panel_detalle_adaptable.dart';
import '../../mapa_screen_2.dart';
import '../reservar_actividad_screen.dart';

class DetalleSitioAcciones {
  DetalleSitioAcciones._();

  // =====================================================
  // ABRIR MAPA DEL SITIO
  // =====================================================

  static void verMapa(
    BuildContext context,
    SitioTuristicoModel sitio,
  ) {
    if (!sitio.tieneCoordenadas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este sitio todavía no tiene una ubicación válida.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaScreen2(sitioInicial: sitio),
      ),
    );
  }

  // =====================================================
  // DETALLE DEL SITIO DESDE EL MAPA
  // =====================================================

  static void mostrarDetalleMapa(
    BuildContext context,
    SitioTuristicoModel sitio,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapaDetalleSitio(
        sitio: sitio,
        onVerMapa: () => verMapa(context, sitio),
        onAgregarRuta: () => agregarRuta(context),
      ),
    );
  }

  // =====================================================
  // AGREGAR A LA RUTA
  // =====================================================

  static void agregarRuta(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La selección de sitios para tu ruta estará disponible aquí.',
        ),
      ),
    );
  }

  // =====================================================
  // DETALLE DE ACTIVIDAD
  // =====================================================

  static void mostrarActividad(
    BuildContext context,
    SitioActividadModel actividad, {
    String nombreSitio = '',
  }) {
    // Reunir la imagen principal y las adicionales sin duplicados.
    final Set<String> imagenesUnicas = <String>{};

    final principal = actividad.imagenPrincipal.trim();

    if (principal.isNotEmpty) {
      imagenesUnicas.add(principal);
    }

    for (final imagen in actividad.imagenes) {
      final url = imagen.trim();

      if (url.isNotEmpty) {
        imagenesUnicas.add(url);
      }
    }

    PanelDetalleAdaptable.mostrar<void>(
      context: context,
      titulo: actividad.nombre,
      icono: Icons.eco_rounded,
      maxWidth: 820,
      builder: (panelContext) => _ContenidoDetalleActividad(
        actividad: actividad,
        imagenes: imagenesUnicas.toList(growable: false),
        onSolicitarReserva: () {
          final sesion =
              UsuarioSesionService.instance.sesionActual.value;

          final mensajes = ScaffoldMessenger.of(context);

          // Cerrar el panel antes de continuar.
          Navigator.of(panelContext).pop();

          if (sesion == null) {
            mensajes.showSnackBar(
              const SnackBar(
                content: Text(
                  'Inicia sesión para solicitar una reserva.',
                ),
              ),
            );
            return;
          }

          if (!context.mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReservarActividadScreen(
                actividad: actividad,
                nombreSitio: nombreSitio,
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// CONTENIDO DEL DETALLE DE LA ACTIVIDAD
// =====================================================

class _ContenidoDetalleActividad extends StatefulWidget {
  const _ContenidoDetalleActividad({
    required this.actividad,
    required this.imagenes,
    required this.onSolicitarReserva,
  });

  final SitioActividadModel actividad;
  final List<String> imagenes;
  final VoidCallback onSolicitarReserva;

  @override
  State<_ContenidoDetalleActividad> createState() =>
      _ContenidoDetalleActividadState();
}

class _ContenidoDetalleActividadState
    extends State<_ContenidoDetalleActividad> {
  final PageController _pageController = PageController();

  int _paginaActual = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividad = widget.actividad;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imágenes de la actividad.
        if (widget.imagenes.isNotEmpty)
          _carruselImagenes()
        else
          _imagenVacia(),

        const SizedBox(height: AppDimensions.spacingLg),

        // Etiqueta de experiencia turística.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.sitioSurfaceGreen,
            borderRadius: BorderRadius.circular(
              AppDimensions.chipRadius,
            ),
            border: Border.all(
              color: AppColors.sitioBorder,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.eco_rounded,
                size: 17,
                color: AppColors.sitioPrimary,
              ),
              SizedBox(width: 6),
              Text(
                'EXPERIENCIA TURÍSTICA',
                style: TextStyle(
                  color: AppColors.sitioPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Nombre.
        Text(
          actividad.nombre,
          style: const TextStyle(
            color: AppColors.sitioPrimaryDark,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Descripción.
        Text(
          actividad.descripcion.trim().isEmpty
              ? 'No hay una descripción disponible para esta actividad.'
              : actividad.descripcion.trim(),
          style: const TextStyle(
            color: AppColors.sitioTextPrimary,
            fontSize: 15,
            height: 1.7,
          ),
        ),

        // Información adicional.
        if (actividad.duracion.trim().isNotEmpty ||
            actividad.horario.trim().isNotEmpty ||
            actividad.precio > 0) ...[
          const SizedBox(height: AppDimensions.spacingXl),

          const Divider(
            color: AppColors.sitioDivider,
            height: 1,
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          const Text(
            'Información de la actividad',
            style: TextStyle(
              color: AppColors.sitioPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          if (actividad.duracion.trim().isNotEmpty)
            _DatoActividad(
              icono: Icons.schedule_rounded,
              titulo: 'Duración',
              valor: actividad.duracion,
            ),

          if (actividad.horario.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            _DatoActividad(
              icono: Icons.access_time_rounded,
              titulo: 'Horario',
              valor: actividad.horario,
            ),
          ],

          if (actividad.precio > 0) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            _DatoActividad(
              icono: Icons.payments_outlined,
              titulo: 'Precio',
              valor: actividad.precio.toStringAsFixed(
                actividad.precio % 1 == 0 ? 0 : 2,
              ),
            ),
          ],
        ],

        const SizedBox(height: AppDimensions.spacingXl),

        // Solicitar reserva.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onSolicitarReserva,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioAccent,
              foregroundColor: AppColors.sitioTextOnPrimary,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
            ),
            icon: const Icon(
              Icons.event_available_rounded,
            ),
            label: const Text(
              'Solicitar reserva',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // CARRUSEL DE IMÁGENES
  // =====================================================

  Widget _carruselImagenes() {
    final imagenes = widget.imagenes;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: imagenes.length,
                  onPageChanged: (pagina) {
                    setState(() {
                      _paginaActual = pagina;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      imagenes[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          return child;
                        }

                        return const ColoredBox(
                          color: AppColors.sitioSurfaceGreen,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.sitioPrimary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) => _imagenVacia(),
                    );
                  },
                ),

                if (imagenes.length > 1)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.chipRadius,
                        ),
                      ),
                      child: Text(
                        '${_paginaActual + 1} / ${imagenes.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Miniaturas para navegar por las imágenes.
        if (imagenes.length > 1) ...[
          const SizedBox(height: AppDimensions.spacingMd),

          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imagenes.length,
              separatorBuilder: (_, _) => const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              itemBuilder: (context, index) {
                final seleccionada = _paginaActual == index;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: seleccionada
                            ? AppColors.sitioPrimary
                            : AppColors.sitioBorder,
                        width: seleccionada ? 3 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      imagenes[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagenVacia(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // =====================================================
  // IMAGEN ALTERNATIVA
  // =====================================================

  Widget _imagenVacia() {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_camera_back_outlined,
            size: 44,
            color: AppColors.sitioPrimary,
          ),
          SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FILA REUTILIZABLE DE INFORMACIÓN
// =====================================================

class _DatoActividad extends StatelessWidget {
  const _DatoActividad({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  final IconData icono;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: AppColors.sitioPrimary,
              size: 21,
            ),
          ),

          const SizedBox(width: AppDimensions.spacingMd),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.sitioTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  valor,
                  style: const TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}