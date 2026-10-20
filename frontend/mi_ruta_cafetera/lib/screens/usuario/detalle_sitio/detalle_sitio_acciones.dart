import 'package:flutter/material.dart';

import '../../../models/sitio_turistico_model.dart';
import '../../../models/sitio/sitio_actividad_model.dart';
import '../../../services/usuario/usuario_sesion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/mapa/mapa_detalle_sitio.dart';
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
  // Se conserva el comportamiento existente.
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
  // Se conserva el comportamiento existente.
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
  // MOSTRAR DETALLE COMPLETO DE UNA ACTIVIDAD
  // Identidad visual: colores exclusivos del sitio.
  // =====================================================

  static void mostrarActividad(
    BuildContext context,
    SitioActividadModel actividad, {
    String nombreSitio = '',
  }) {
    // Reunir la imagen principal y las imágenes adicionales
    // sin repetir direcciones.
    final Set<String> imagenesUnicas = <String>{};

    final String imagenPrincipal =
        actividad.imagenPrincipal.trim();

    if (imagenPrincipal.isNotEmpty) {
      imagenesUnicas.add(imagenPrincipal);
    }

    for (final String imagen in actividad.imagenes) {
      final String url = imagen.trim();

      if (url.isNotEmpty) {
        imagenesUnicas.add(url);
      }
    }

    final List<String> imagenes =
        imagenesUnicas.toList(growable: false);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(sheetContext).size.height * 0.90,
            ),
            decoration: const BoxDecoration(
              color: AppColors.sitioBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Indicador superior
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.spacingMd,
                    bottom: AppDimensions.spacingSm,
                  ),
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.sitioBorder,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Contenido desplazable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pageHorizontal,
                      AppDimensions.spacingSm,
                      AppDimensions.pageHorizontal,
                      AppDimensions.spacingXl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carrusel de imágenes
                        if (imagenes.isNotEmpty)
                          _CarruselImagenesActividad(
                            imagenes: imagenes,
                          )
                        else
                          _ImagenActividadVacia(),

                        const SizedBox(
                          height: AppDimensions.spacingLg,
                        ),

                        // Etiqueta decorativa
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sitioSurfaceGreen,
                            borderRadius: BorderRadius.circular(20),
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
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),

                        // Nombre de la actividad
                        Text(
                          actividad.nombre,
                          style: Theme.of(sheetContext)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.sitioPrimaryDark,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                        ),

                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),

                        // Descripción
                        Text(
                          actividad.descripcion.trim().isNotEmpty
                              ? actividad.descripcion
                              : 'No hay una descripción disponible '
                                  'para esta actividad.',
                          style: Theme.of(sheetContext)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: AppColors.sitioTextPrimary,
                                height: 1.6,
                              ),
                        ),

                        // Información adicional
                        if (actividad.duracion.trim().isNotEmpty ||
                            actividad.horario.trim().isNotEmpty ||
                            actividad.precio > 0) ...[
                          const SizedBox(
                            height: AppDimensions.spacingXl,
                          ),
                          const Divider(
                            color: AppColors.sitioDivider,
                            height: 1,
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                          const Text(
                            'Información de la actividad',
                            style: TextStyle(
                              color: AppColors.sitioPrimaryDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingMd,
                          ),

                          if (actividad.duracion.trim().isNotEmpty)
                            _DatoActividad(
                              icono: Icons.schedule_rounded,
                              titulo: 'Duración',
                              valor: actividad.duracion,
                            ),

                          if (actividad.horario.trim().isNotEmpty) ...[
                            const SizedBox(
                              height: AppDimensions.spacingMd,
                            ),
                            _DatoActividad(
                              icono: Icons.access_time_rounded,
                              titulo: 'Horario',
                              valor: actividad.horario,
                            ),
                          ],

                          if (actividad.precio > 0) ...[
                            const SizedBox(
                              height: AppDimensions.spacingMd,
                            ),
                            _DatoActividad(
                              icono: Icons.payments_outlined,
                              titulo: 'Precio',
                              valor: actividad.precio
                                  .toStringAsFixed(
                                    actividad.precio % 1 == 0 ? 0 : 2,
                                  ),
                            ),
                          ],
                        ],

                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),

                        // Solicitar reserva (solo con sesión de usuario)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final sesion = UsuarioSesionService
                                  .instance.sesionActual.value;
                              final navegador = Navigator.of(context);
                              final mensajes =
                                  ScaffoldMessenger.of(context);

                              Navigator.of(sheetContext).pop();

                              if (sesion == null) {
                                mensajes.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Inicia sesión para solicitar '
                                      'una reserva.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              navegador.push(
                                MaterialPageRoute(
                                  builder: (_) => ReservarActividadScreen(
                                    actividad: actividad,
                                    nombreSitio: nombreSitio,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.sitioAccent,
                              foregroundColor:
                                  AppColors.sitioTextOnPrimary,
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

                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),

                        // Botón para cerrar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.sitioPrimary,
                              foregroundColor:
                                  AppColors.sitioTextOnPrimary,
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
                            child: const Text(
                              'Cerrar detalle',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// =====================================================
// CARRUSEL DE IMÁGENES
// =====================================================

class _CarruselImagenesActividad extends StatefulWidget {
  const _CarruselImagenesActividad({
    required this.imagenes,
  });

  final List<String> imagenes;

  @override
  State<_CarruselImagenesActividad> createState() =>
      _CarruselImagenesActividadState();
}

class _CarruselImagenesActividadState
    extends State<_CarruselImagenesActividad> {
  late final PageController _pageController;
  int _paginaActual = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppDimensions.featuredImageHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imagenes.length,
              onPageChanged: (pagina) {
                setState(() => _paginaActual = pagina);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imagenes[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return Container(
                      color: AppColors.sitioSurfaceSoft,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.sitioPrimary,
                        strokeWidth: 2.5,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.sitioSurfaceGreen,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 42,
                            color: AppColors.sitioTextSecondary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No se pudo cargar esta imagen',
                            style: TextStyle(
                              color: AppColors.sitioTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // Contador y puntos de navegación
        if (widget.imagenes.length > 1) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 17,
                color: AppColors.sitioTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_paginaActual + 1} de ${widget.imagenes.length}',
                style: const TextStyle(
                  color: AppColors.sitioTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              ...List.generate(
                widget.imagenes.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _paginaActual ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _paginaActual
                        ? AppColors.sitioAccent
                        : AppColors.sitioBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// =====================================================
// MARCADOR PARA ACTIVIDADES SIN IMÁGENES
// =====================================================

class _ImagenActividadVacia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.featuredImageHeight,
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceGreen,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_back_outlined,
            size: 48,
            color: AppColors.sitioPrimary,
          ),
          SizedBox(height: 8),
          Text(
            'Esta actividad aún no tiene imágenes',
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
// FILA DE INFORMACIÓN
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
