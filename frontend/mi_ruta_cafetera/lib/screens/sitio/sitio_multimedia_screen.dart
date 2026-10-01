import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_multimedia_model.dart';
import '../../services/sitio/sitio_multimedia_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioMultimediaScreen extends StatefulWidget {
  const SitioMultimediaScreen({
    super.key,
  });

  @override
  State<SitioMultimediaScreen> createState() =>
      _SitioMultimediaScreenState();
}

class _SitioMultimediaScreenState
    extends State<SitioMultimediaScreen> {
  // ============================================================
  // SERVICIOS
  // ============================================================

  final ImagePicker _imagePicker = ImagePicker();

  final SitioMultimediaService _multimediaService =
      SitioMultimediaService();

  final SitioSesionService _sesionService =
      SitioSesionService();

  // ============================================================
  // DATOS
  // ============================================================

  List<SitioMultimediaModel> _multimedia = [];

  XFile? _imagenSeleccionada;

  Uint8List? _imagenSeleccionadaBytes;

  String? _token;

  String? _sitioId;

  // ============================================================
  // ESTADO
  // ============================================================

  bool _cargando = true;

  bool _subiendo = false;

  String? _error;

  // ============================================================
  // CONTROLADORES
  // ============================================================

  final TextEditingController _tituloController =
      TextEditingController();

  final TextEditingController _descripcionController =
      TextEditingController();

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _inicializar();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();

    super.dispose();
  }

  // ============================================================
  // INICIALIZAR
  // ============================================================

  Future<void> _inicializar() async {
    try {
      final sesion =
          await _sesionService.obtenerSesion();

      if (!mounted) {
        return;
      }

      if (sesion == null ||
          sesion.token.isEmpty ||
          sesion.sitioId.isEmpty) {
        setState(() {
          _cargando = false;
          _error =
              'No hay una sesión de sitio disponible.';
        });

        return;
      }

      _token = sesion.token;
      _sitioId = sesion.sitioId;

      await _cargarMultimedia();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error =
            'No fue posible cargar la galería.';
      });
    }
  }

  // ============================================================
  // CARGAR MULTIMEDIA
  // ============================================================

  Future<void> _cargarMultimedia() async {
    if (_token == null ||
        _token!.isEmpty ||
        _sitioId == null ||
        _sitioId!.isEmpty) {
      return;
    }

    try {
      final multimedia =
          await _multimediaService.obtenerMultimedia(
        token: _token!,
        sitioId: _sitioId!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _multimedia = multimedia
            .where(
              (item) =>
                  item.tipo == 'imagen' &&
                  item.activo &&
                  item.url.isNotEmpty,
            )
            .toList();

        _cargando = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error =
            error.toString().replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    }
  }

  // ============================================================
  // SELECCIONAR IMAGEN
  // ============================================================

  Future<void> _seleccionarImagen() async {
    if (_subiendo) {
      return;
    }

    try {
      final XFile? imagen =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (imagen == null) {
        return;
      }

      final bytes =
          await imagen.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _imagenSeleccionada = imagen;
        _imagenSeleccionadaBytes = bytes;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        'No fue posible seleccionar la imagen.',
        esError: true,
      );
    }
  }

  // ============================================================
  // SUBIR IMAGEN
  // ============================================================

  Future<void> _subirImagen() async {
    if (_imagenSeleccionada == null) {
      _mostrarMensaje(
        'Primero selecciona una imagen.',
        esError: true,
      );

      return;
    }

    if (_token == null ||
        _token!.isEmpty) {
      _mostrarMensaje(
        'Tu sesión no está disponible.',
        esError: true,
      );

      return;
    }

    setState(() {
      _subiendo = true;
    });

    try {
      final resultado =
          await _multimediaService.subirImagen(
        token: _token!,
        archivo: _imagenSeleccionada!,
        titulo:
            _tituloController.text.trim(),
        descripcion:
            _descripcionController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _multimedia.insert(
          0,
          resultado,
        );

        _imagenSeleccionada = null;
        _imagenSeleccionadaBytes = null;

        _tituloController.clear();
        _descripcionController.clear();

        _subiendo = false;
      });

      _mostrarMensaje(
        'La fotografía se subió correctamente.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _subiendo = false;
      });

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );
    }
  }

  // ============================================================
  // MENSAJES
  // ============================================================

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor:
              esError
                  ? AppColors.error
                  : AppColors.primary,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ancho =
        MediaQuery.sizeOf(context).width;

    final esEscritorio =
        ancho >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        esEscritorio
            ? AppDimensions.spacingXl
            : AppDimensions.spacingMd,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _encabezado(context),

              const SizedBox(
                height:
                    AppDimensions.spacingLg,
              ),

              _resumenMultimedia(
                esEscritorio,
              ),

              const SizedBox(
                height:
                    AppDimensions.spacingLg,
              ),

              _galeria(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget _encabezado(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Multimedia',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                color:
                    AppColors.textPrimary,
                fontWeight:
                    FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Administra las fotografías y material visual que representan tu sitio turístico.',
          style: TextStyle(
            color:
                AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================

  Widget _resumenMultimedia(
    bool esEscritorio,
  ) {
    final cantidad =
        _multimedia.length;

    final contenido = [
      _tarjetaResumen(
        icono:
            Icons.photo_library_rounded,
        titulo: 'Fotografías',
        valor:
            cantidad.toString(),
        descripcion:
            cantidad == 1
                ? 'Imagen publicada'
                : 'Imágenes publicadas',
      ),
      _tarjetaResumen(
        icono:
            Icons.image_rounded,
        titulo: 'Galería',
        valor:
            cantidad == 0
                ? 'Vacía'
                : 'Activa',
        descripcion:
            cantidad == 0
                ? 'Todavía no tienes imágenes'
                : '$cantidad imágenes disponibles',
      ),
    ];

    if (esEscritorio) {
      return Row(
        children: [
          Expanded(
            child: contenido[0],
          ),
          const SizedBox(
            width:
                AppDimensions.spacingMd,
          ),
          Expanded(
            child: contenido[1],
          ),
        ],
      );
    }

    return Column(
      children: [
        contenido[0],
        const SizedBox(
          height:
              AppDimensions.spacingMd,
        ),
        contenido[1],
      ],
    );
  }

  // ============================================================
  // TARJETA RESUMEN
  // ============================================================

  Widget _tarjetaResumen({
    required IconData icono,
    required String titulo,
    required String valor,
    required String descripcion,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color:
                  AppColors.primary
                      .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Icon(
              icono,
              color:
                  AppColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(
            width:
                AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .textSecondary,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  valor,
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .textPrimary,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  descripcion,
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GALERÍA
  // ============================================================

  Widget _galeria() {
    return TarjetaSeccionSitio(
      titulo: 'Galería del sitio',
      subtitulo:
          'Agrega fotografías que permitan a los visitantes conocer tu experiencia.',
      icono:
          Icons.photo_library_rounded,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _zonaAgregar(),

          const SizedBox(
            height:
                AppDimensions.spacingLg,
          ),

          _construirGaleria(),
        ],
      ),
    );
  }

  // ============================================================
  // ZONA PARA AGREGAR
  // ============================================================

  Widget _zonaAgregar() {
    return Column(
      children: [
        InkWell(
          onTap:
              _subiendo
                  ? null
                  : _seleccionarImagen,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              vertical:
                  AppDimensions.spacingXl,
              horizontal:
                  AppDimensions.spacingLg,
            ),
            decoration:
                BoxDecoration(
              color:
                  AppColors.background,
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
              border:
                  Border.all(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.25,
                ),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primary
                            .withValues(
                      alpha: 0.10,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .add_photo_alternate_rounded,
                    color:
                        AppColors.primary,
                    size: 31,
                  ),
                ),
                const SizedBox(
                  height:
                      AppDimensions
                          .spacingMd,
                ),
                const Text(
                  'Agregar fotografías',
                  style:
                      TextStyle(
                    color:
                        AppColors
                            .textPrimary,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'Selecciona una imagen para mostrar tu sitio turístico.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        AppColors
                            .textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(
                  height:
                      AppDimensions
                          .spacingMd,
                ),
                OutlinedButton.icon(
                  onPressed:
                      _subiendo
                          ? null
                          : _seleccionarImagen,
                  icon:
                      const Icon(
                    Icons.upload_rounded,
                  ),
                  label:
                      const Text(
                    'Seleccionar imagen',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColors
                            .primary,
                    side:
                        BorderSide(
                      color:
                          AppColors
                              .primary
                              .withValues(
                        alpha: 0.35,
                      ),
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal:
                          AppDimensions
                              .spacingLg,
                      vertical:
                          AppDimensions
                              .spacingSm,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions
                            .radiusMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_imagenSeleccionada != null &&
            _imagenSeleccionadaBytes != null)
          _vistaPrevia(),
      ],
    );
  }

  // ============================================================
  // VISTA PREVIA
  // ============================================================

  Widget _vistaPrevia() {
    return Container(
      margin: const EdgeInsets.only(
        top: AppDimensions.spacingMd,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color:
              AppColors.primary
                  .withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.memory(
                _imagenSeleccionadaBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(
            height:
                AppDimensions.spacingMd,
          ),

          TextField(
            controller:
                _tituloController,
            decoration:
                const InputDecoration(
              labelText: 'Título',
              hintText:
                  'Ej. Entrada principal del sitio',
              prefixIcon:
                  Icon(
                Icons.title_rounded,
              ),
            ),
          ),

          const SizedBox(
            height:
                AppDimensions.spacingMd,
          ),

          TextField(
            controller:
                _descripcionController,
            maxLines: 3,
            decoration:
                const InputDecoration(
              labelText:
                  'Descripción',
              hintText:
                  'Describe brevemente esta fotografía',
              prefixIcon:
                  Icon(
                Icons
                    .description_outlined,
              ),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(
            height:
                AppDimensions.spacingMd,
          ),

          SizedBox(
            width: double.infinity,
            height:
                AppDimensions
                    .buttonHeightLarge,
            child:
                ElevatedButton.icon(
              onPressed:
                  _subiendo
                      ? null
                      : _subirImagen,
              icon:
                  _subiendo
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons
                              .cloud_upload_rounded,
                        ),
              label:
                  Text(
                _subiendo
                    ? 'Subiendo fotografía...'
                    : 'Subir fotografía',
              ),
            ),
          ),

          const SizedBox(
            height:
                AppDimensions.spacingSm,
          ),

          Center(
            child: TextButton(
              onPressed:
                  _subiendo
                      ? null
                      : _cancelarSeleccion,
              child:
                  const Text(
                'Cancelar',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CANCELAR SELECCIÓN
  // ============================================================

  void _cancelarSeleccion() {
    setState(() {
      _imagenSeleccionada = null;
      _imagenSeleccionadaBytes = null;

      _tituloController.clear();
      _descripcionController.clear();
    });
  }

  // ============================================================
  // GALERÍA REAL
  // ============================================================

  Widget _construirGaleria() {
    if (_cargando) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          AppDimensions.spacingXl,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.background,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height:
                  AppDimensions.spacingMd,
            ),
            Text(
              'Cargando fotografías...',
              style: TextStyle(
                color:
                    AppColors
                        .textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null &&
        _multimedia.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          AppDimensions.spacingXl,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.background,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons
                  .cloud_off_rounded,
              color:
                  AppColors
                      .textSecondary,
              size: 42,
            ),
            const SizedBox(
              height:
                  AppDimensions.spacingMd,
            ),
            const Text(
              'No fue posible cargar la galería',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    AppColors
                        .textPrimary,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              _error!,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    AppColors
                        .textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(
              height:
                  AppDimensions.spacingMd,
            ),
            OutlinedButton.icon(
              onPressed:
                  _cargarMultimedia,
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text(
                'Intentar nuevamente',
              ),
            ),
          ],
        ),
      );
    }

    if (_multimedia.isEmpty) {
      return _estadoGaleriaVacia();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount:
          _multimedia.length,
      gridDelegate:
          const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisSpacing:
            AppDimensions.spacingMd,
        crossAxisSpacing:
            AppDimensions.spacingMd,
        childAspectRatio: 1.05,
      ),
      itemBuilder:
          (context, index) {
        final imagen =
            _multimedia[index];

        return _tarjetaImagen(
          imagen,
        );
      },
    );
  }

  // ============================================================
  // TARJETA DE IMAGEN
  // ============================================================

  Widget _tarjetaImagen(
    SitioMultimediaModel imagen,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        AppDimensions.radiusLg,
      ),
      child: Container(
        color:
            AppColors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imagen.url,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Center(
                  child: Icon(
                    Icons
                        .broken_image_rounded,
                    color:
                        AppColors
                            .textSecondary,
                    size: 40,
                  ),
                );
              },
              loadingBuilder:
                  (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress ==
                    null) {
                  return child;
                }

                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.all(
                  AppDimensions
                      .spacingMd,
                ),
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black
                          .withValues(
                        alpha: 0.75,
                      ),
                    ],
                  ),
                ),
                child: Text(
                  imagen.titulo
                          .trim()
                          .isEmpty
                      ? 'Fotografía'
                      : imagen.titulo,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        AppColors.white,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GALERÍA VACÍA
  // ============================================================

  Widget _estadoGaleriaVacia() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.background,
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons
                .photo_camera_back_rounded,
            color:
                AppColors
                    .textSecondary,
            size: 42,
          ),
          SizedBox(
            height:
                AppDimensions.spacingMd,
          ),
          Text(
            'Todavía no hay fotografías',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Las imágenes que agregues aparecerán aquí.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppColors
                      .textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}