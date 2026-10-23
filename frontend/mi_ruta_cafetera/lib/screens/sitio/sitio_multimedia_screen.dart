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
import 'sitio_multimedia/gestion_multimedia_helper.dart';

class SitioMultimediaScreen extends StatefulWidget {
  const SitioMultimediaScreen({super.key});

  @override
  State<SitioMultimediaScreen> createState() => _SitioMultimediaScreenState();
}

class _SitioMultimediaScreenState extends State<SitioMultimediaScreen> {
  final SitioMultimediaService _multimediaService = SitioMultimediaService();
  final SitioSesionService _sesionService = SitioSesionService();

  late final GestionMultimediaHelper _gestionMultimediaHelper = GestionMultimediaHelper(
    multimediaService: _multimediaService,
    sesionService: _sesionService,
  );

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
      final credenciales = await _gestionMultimediaHelper.obtenerCredenciales();
      if (!mounted) return;

      _token = credenciales['token'];
      _sitioId = credenciales['sitioId'];

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
    if (_token == null || _token!.isEmpty || _sitioId == null || _sitioId!.isEmpty) return;

    if (mounted) setState(() { _cargando = true; _error = null; });

    try {
      final multimedia = await _gestionMultimediaHelper.cargarMultimedia(
        token: _token!,
        sitioId: _sitioId!,
      );

      if (!mounted) return;
      setState(() {
        _multimedia = multimedia;
        _cargando = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _mostrarFormulario() {
    showDialog<void>(
      context: context,
      builder: (_) => FormularioMultimediaSitio(
        onSubir: ({
          required XFile imagen,
          required String titulo,
          required String descripcion,
        }) {
          return _subirImagen(imagen: imagen, titulo: titulo, descripcion: descripcion);
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
      _mostrarMensaje('Tu sesión no está disponible.', esError: true);
      return false;
    }

    try {
      final resultado = await _gestionMultimediaHelper.subirImagen(
        token: _token!,
        imagen: imagen,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (!mounted) return false;

      setState(() {
        if (resultado.tipo == 'imagen' && resultado.activo && resultado.url.isNotEmpty) {
          _multimedia.insert(0, resultado);
        }
      });

      _mostrarMensaje('La fotografía se subió correctamente.');
      return true;
    } catch (error) {
      if (!mounted) return false;
      _mostrarMensaje(error.toString().replaceFirst('Exception: ', ''), esError: true);
      return false;
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: esError ? AppColors.sitioError : AppColors.sitioPrimary,
          content: Text(mensaje),
        ),
      );
  }

  Widget _construirEncabezado() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 650;

        final titulo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Multimedia',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.sitioTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Administra las fotografías que muestran la esencia de tu sitio turístico.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.sitioTextSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        );

        final boton = ElevatedButton.icon(
          onPressed: _mostrarFormulario,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Agregar fotografía'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sitioPrimary,
            foregroundColor: AppColors.sitioTextOnPrimary,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );

        if (esMovil) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titulo, const SizedBox(height: 16), SizedBox(width: double.infinity, child: boton)],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: titulo), const SizedBox(width: 20), boton],
        );
      },
    );
  }

  Widget _construirResumen() {
    final cantidad = _multimedia.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tarjetas = [
          _tarjetaResumen(
            icono: Icons.photo_library_rounded,
            titulo: 'Fotografías',
            valor: cantidad.toString(),
            descripcion: cantidad == 1 ? 'Imagen publicada' : 'Imágenes publicadas',
          ),
          _tarjetaResumen(
            icono: Icons.image_rounded,
            titulo: 'Galería',
            valor: cantidad == 0 ? 'Vacía' : 'Activa',
            descripcion: cantidad == 0 ? 'Todavía no tienes imágenes' : '$cantidad imágenes disponibles',
          ),
        ];

        if (constraints.maxWidth >= 600) {
          return Row(
            children: [Expanded(child: tarjetas[0]), const SizedBox(width: 16), Expanded(child: tarjetas[1])],
          );
        }

        return Column(children: [tarjetas[0], const SizedBox(height: 12), tarjetas[1]]);
      },
    );
  }

  Widget _tarjetaResumen({
    required IconData icono,
    required String titulo,
    required String valor,
    required String descripcion,
  }) {
    final esGaleria = titulo == 'Galería';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.sitioStatCardPadding),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(AppDimensions.sitioStatCardRadius),
        border: Border.all(color: AppColors.sitioBorder),
        boxShadow: const [BoxShadow(color: AppColors.sitioCardShadow, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: esGaleria ? AppColors.sitioWarningSoft : AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: esGaleria ? AppColors.sitioWarning : AppColors.sitioPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: AppColors.sitioTextSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(valor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.sitioTextPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.sitioTextSecondary, fontSize: 11, height: 1.35)),
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
        child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.sitioPrimary)),
      );
    }

    if (_error != null && _multimedia.isEmpty) return _construirError();
    if (_multimedia.isEmpty) return _construirVacio();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maximo = constraints.maxWidth >= 1000 ? 260.0 : (constraints.maxWidth >= 600 ? 230.0 : 190.0);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _multimedia.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maximo,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.86,
          ),
          itemBuilder: (context, index) => TarjetaMultimediaSitio(imagen: _multimedia[index]),
        );
      },
    );
  }

  Widget _construirError() {
    return _estadoGaleria(
      icono: Icons.cloud_off_rounded,
      titulo: 'No fue posible cargar la galería',
      descripcion: _error ?? 'Ocurrió un error inesperado.',
      accion: OutlinedButton.icon(
        onPressed: _cargarMultimedia,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Intentar nuevamente'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sitioPrimary,
          side: const BorderSide(color: AppColors.sitioBorder),
        ),
      ),
    );
  }

  Widget _construirVacio() {
    return _estadoGaleria(
      icono: Icons.photo_camera_back_rounded,
      titulo: 'Tu galería está esperando sus primeras fotos',
      descripcion: 'Agrega fotografías de tus paisajes, instalaciones y experiencias para inspirar a los viajeros.',
      accion: ElevatedButton.icon(
        onPressed: _mostrarFormulario,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Agregar fotografía'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sitioPrimary,
          foregroundColor: AppColors.sitioTextOnPrimary,
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _estadoGaleria({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Widget accion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 68, height: 68,
            decoration: const BoxDecoration(color: AppColors.sitioSurfaceGreen, shape: BoxShape.circle),
            child: Icon(icono, color: AppColors.sitioPrimary, size: 32),
          ),
          const SizedBox(height: 18),
          Text(titulo, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.sitioTextPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(descripcion, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.sitioTextSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          accion,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final escritorio = ancho >= 900;

    return Container(
      color: AppColors.sitioBackground,
      child: RefreshIndicator(
        color: AppColors.sitioPrimary,
        onRefresh: _cargarMultimedia,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(escritorio ? AppDimensions.sitioPagePadding : AppDimensions.sitioPagePaddingCompact),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirEncabezado(),
                  const SizedBox(height: 20),
                  _construirResumen(),
                  const SizedBox(height: 24),
                  TarjetaSeccionSitio(
                    titulo: 'Galería de tu sitio',
                    subtitulo: 'Cada fotografía ayuda a los viajeros a imaginar su próxima experiencia.',
                    icono: Icons.photo_library_rounded,
                    child: _construirGaleria(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}