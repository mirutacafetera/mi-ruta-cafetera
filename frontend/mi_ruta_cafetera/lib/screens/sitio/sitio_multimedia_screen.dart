import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_multimedia_model.dart';
import '../../services/sitio/sitio_multimedia_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/formulario_multimedia_sitio.dart';
import '../../widgets/sitio/tarjeta_multimedia_sitio.dart';
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
  final SitioMultimediaService _multimediaService =
      SitioMultimediaService();

  final SitioSesionService _sesionService =
      SitioSesionService();

  List<SitioMultimediaModel> _multimedia = [];

  bool _cargando = true;
  String? _error;

  String? _token;
  String? _sitioId;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      final sesion = await _sesionService.obtenerSesion();

      if (!mounted) return;

      if (sesion == null ||
          sesion.token.isEmpty ||
          sesion.sitioId.isEmpty) {
        setState(() {
          _cargando = false;
          _error = 'No hay una sesión de sitio disponible.';
        });
        return;
      }

      _token = sesion.token;
      _sitioId = sesion.sitioId;

      await _cargarMultimedia();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No fue posible cargar la galería.';
      });
    }
  }

  Future<void> _cargarMultimedia() async {
    if (_token == null ||
        _token!.isEmpty ||
        _sitioId == null ||
        _sitioId!.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final multimedia =
          await _multimediaService.obtenerMultimedia(
        token: _token!,
        sitioId: _sitioId!,
      );

      if (!mounted) return;

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
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  void _mostrarFormulario() {
    showDialog(
      context: context,
      builder: (_) => FormularioMultimediaSitio(
        onSubir: ({
          required XFile imagen,
          required String titulo,
          required String descripcion,
        }) {
          return _subirImagen(
            imagen: imagen,
            titulo: titulo,
            descripcion: descripcion,
          );
        },
      ),
    );
  }

  Future<bool> _subirImagen({
    required XFile imagen,
    required String titulo,
    required String descripcion,
  }) async {
    if (_token == null || _token!.isEmpty) {
      _mostrarMensaje(
        'Tu sesión no está disponible.',
        esError: true,
      );
      return false;
    }

    try {
      final resultado =
          await _multimediaService.subirImagen(
        token: _token!,
        archivo: imagen,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (!mounted) return false;

      setState(() {
        _multimedia.insert(0, resultado);
      });

      _mostrarMensaje(
        'La fotografía se subió correctamente.',
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );

      return false;
    }
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    if (!mounted) return;

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

  Widget _construirEncabezado() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 650;

        final titulo = Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Multimedia',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(
              height: AppDimensions.spacingXs,
            ),
            Text(
              'Administra las fotografías y material visual '
              'que representan tu sitio turístico.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
          ],
        );

        final boton = ElevatedButton.icon(
          onPressed: _mostrarFormulario,
          icon: const Icon(
            Icons.add_photo_alternate_outlined,
          ),
          label: const Text(
            'Agregar fotografía',
          ),
        );

        if (esMovil) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              titulo,
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              SizedBox(
                width: double.infinity,
                child: boton,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: titulo,
            ),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            boton,
          ],
        );
      },
    );
  }

  Widget _construirResumen() {
    final cantidad = _multimedia.length;

    final tarjetas = [
      _tarjetaResumen(
        icono: Icons.photo_library_rounded,
        titulo: 'Fotografías',
        valor: cantidad.toString(),
        descripcion: cantidad == 1
            ? 'Imagen publicada'
            : 'Imágenes publicadas',
      ),
      _tarjetaResumen(
        icono: Icons.image_rounded,
        titulo: 'Galería',
        valor: cantidad == 0
            ? 'Vacía'
            : 'Activa',
        descripcion: cantidad == 0
            ? 'Todavía no tienes imágenes'
            : '$cantidad imágenes disponibles',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final dosColumnas =
            constraints.maxWidth >= 600;

        if (dosColumnas) {
          return Row(
            children: [
              Expanded(
                child: tarjetas[0],
              ),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: tarjetas[1],
              ),
            ],
          );
        }

        return Column(
          children: [
            tarjetas[0],
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            tarjetas[1],
          ],
        );
      },
    );
  }

  Widget _tarjetaResumen({
    required IconData icono,
    required String titulo,
    required String valor,
    required String descripcion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.55,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(
              alpha: 0.07,
            ),
            blurRadius:
                AppDimensions.elevationFloating,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Icon(
              icono,
              color: AppColors.white,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color:
                            AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color:
                            AppColors.textSecondary,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirGaleria() {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.spacingXl,
          ),
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null &&
        _multimedia.isEmpty) {
      return _construirError();
    }

    if (_multimedia.isEmpty) {
      return _construirVacio();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: _multimedia.length,
      gridDelegate:
          const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisSpacing:
            AppDimensions.spacingMd,
        crossAxisSpacing:
            AppDimensions.spacingMd,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (_, index) {
        return TarjetaMultimediaSitio(
          imagen: _multimedia[index],
        );
      },
    );
  }

  Widget _construirError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.textSecondary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          const Text(
            'No fue posible cargar la galería',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          OutlinedButton.icon(
            onPressed: _cargarMultimedia,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Intentar nuevamente',
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.photo_camera_back_rounded,
            color: AppColors.textSecondary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          const Text(
            'Todavía no hay fotografías',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          const Text(
            'Las imágenes que agregues aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          ElevatedButton.icon(
            onPressed: _mostrarFormulario,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
            ),
            label: const Text(
              'Agregar fotografía',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final escritorio = ancho >= 900;

    return RefreshIndicator(
      onRefresh: _cargarMultimedia,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(
          escritorio
              ? AppDimensions.spacingXl
              : AppDimensions.spacingMd,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _construirEncabezado(),
                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),
                _construirResumen(),
                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),
                TarjetaSeccionSitio(
                  titulo: 'Galería del sitio',
                  subtitulo:
                      'Agrega fotografías que permitan '
                      'a los visitantes conocer tu experiencia.',
                  icono: Icons.photo_library_rounded,
                  child: _construirGaleria(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}