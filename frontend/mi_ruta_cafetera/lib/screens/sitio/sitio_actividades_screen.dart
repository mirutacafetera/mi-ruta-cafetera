import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
 
import '../../models/sitio/sitio_actividad_model.dart';
import '../../services/sitio/sitio_actividades_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/avisos_sitio.dart';
import '../../widgets/sitio/formulario_actividad_sitio.dart';
import '../../widgets/sitio/tarjeta_actividad_sitio.dart';
import '../../widgets/sitio/tarjeta_resumen_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';
 
class SitioActividadesScreen extends StatefulWidget {
  const SitioActividadesScreen({super.key});
 
  @override
  State<SitioActividadesScreen> createState() =>
      _SitioActividadesScreenState();
}
 
class _SitioActividadesScreenState extends State<SitioActividadesScreen> {
  final SitioActividadesService _actividadesService =
      SitioActividadesService();
  final SitioSesionService _sesionService = SitioSesionService();
 
  List<SitioActividadModel> _actividades = [];
  bool _cargando = true;
  bool _guardando = false;
  String? _error;
  String _token = '';
  String _sitioId = '';
 
  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }
 
  Future<void> _cargarActividades() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
 
    try {
      final sesion = await _sesionService.obtenerSesion();
 
      if (sesion == null ||
          sesion.token.isEmpty ||
          sesion.sitioId.isEmpty) {
        throw Exception('No se encontró una sesión activa del sitio.');
      }
 
      if (!sesion.activo) {
        throw Exception('La cuenta del sitio está inactiva.');
      }
 
      _token = sesion.token;
      _sitioId = sesion.sitioId;
 
      final actividades = await _actividadesService.obtenerActividades(
        token: _token,
        sitioId: _sitioId,
      );
 
      if (!mounted) return;
 
      setState(() {
        _actividades = actividades;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
 
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }
 
  int get _cantidadPublicadas => _actividades
      .where((a) => a.estadoPublicacion == 'aprobado' && a.activo)
      .length;
 
  int get _cantidadEnRevision => _actividades
      .where((a) => a.estadoPublicacion == 'pendiente_revision')
      .length;
 
  Future<void> _mostrarFormulario({
    SitioActividadModel? actividad,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => FormularioActividadSitio(
        actividad: actividad,
        onGuardar: ({
          required String nombre,
          required String descripcion,
          required double precio,
          required String horario,
          required String duracion,
          required List<XFile> imagenes,
          required List<String> imagenesEliminar,
          required String imagenPrincipalUrl,
          required String? imagenPrincipalNueva,
        }) async {
          await _guardarActividad(
            actividad: actividad,
            nombre: nombre,
            descripcion: descripcion,
            precio: precio,
            horario: horario,
            duracion: duracion,
            imagenes: imagenes,
            imagenesEliminar: imagenesEliminar,
            imagenPrincipalUrl: imagenPrincipalUrl,
            imagenPrincipalNueva: imagenPrincipalNueva,
          );
        },
      ),
    );
 
    if (resultado == true && mounted) {
      await _cargarActividades();
    }
  }
 
  Future<void> _guardarActividad({
    SitioActividadModel? actividad,
    required String nombre,
    required String descripcion,
    required double precio,
    required String horario,
    required String duracion,
    required List<XFile> imagenes,
    required List<String> imagenesEliminar,
    required String imagenPrincipalUrl,
    required String? imagenPrincipalNueva,
  }) async {
    if (_token.isEmpty || _sitioId.isEmpty) {
      throw Exception('No hay una sesión activa del sitio.');
    }
 
    if (mounted) {
      setState(() => _guardando = true);
    }
 
    try {
      final imagenesOriginales = <String>{
        if (actividad != null && actividad.imagenPrincipal.isNotEmpty)
          actividad.imagenPrincipal,
        ...?actividad?.imagenes,
      };
 
      late SitioActividadModel guardada;
 
      if (actividad == null) {
        guardada = await _actividadesService.crearActividad(
          token: _token,
          sitioId: _sitioId,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          horario: horario,
          duracion: duracion,
        );
      } else {
        guardada = await _actividadesService.actualizarActividad(
          token: _token,
          sitioId: _sitioId,
          actividadId: actividad.id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          horario: horario,
          duracion: duracion,
        );
      }
 
      if (imagenes.isNotEmpty) {
        guardada = await _actividadesService.subirImagenes(
          token: _token,
          sitioId: _sitioId,
          actividadId: guardada.id,
          archivos: imagenes,
        );
      }
 
      List<String> obtenerUrls(SitioActividadModel item) {
        return {
          if (item.imagenPrincipal.isNotEmpty) item.imagenPrincipal,
          ...item.imagenes.where((url) => url.isNotEmpty),
        }.toList();
      }
 
      var urlsDisponibles = obtenerUrls(guardada);
 
      final urlsNuevas = urlsDisponibles
          .where((url) => !imagenesOriginales.contains(url))
          .toList();
 
      var principalDeseada = imagenPrincipalUrl.trim();
 
      if (imagenPrincipalNueva != null) {
        final indiceSeleccionado = imagenes.indexWhere(
          (imagen) => imagen.path == imagenPrincipalNueva,
        );
 
        if (indiceSeleccionado < 0) {
          throw Exception(
            'No se encontró la fotografía seleccionada como portada.',
          );
        }
 
        if (indiceSeleccionado >= urlsNuevas.length) {
          throw Exception(
            'El servidor no devolvió una URL para la fotografía elegida. '
            'No se eliminarán las imágenes existentes.',
          );
        }
 
        principalDeseada = urlsNuevas[indiceSeleccionado];
      }
 
      if (principalDeseada.isEmpty ||
          imagenesEliminar.contains(principalDeseada) ||
          !urlsDisponibles.contains(principalDeseada)) {
        principalDeseada = '';
 
        for (final url in urlsDisponibles) {
          if (!imagenesEliminar.contains(url)) {
            principalDeseada = url;
            break;
          }
        }
      }
 
      if (principalDeseada.isEmpty) {
        throw Exception(
          'La actividad debe conservar al menos una imagen.',
        );
      }
 
      if (guardada.imagenPrincipal != principalDeseada) {
        if (!guardada.imagenes.contains(principalDeseada)) {
          throw Exception(
            'La imagen elegida como portada no está disponible '
            'en la galería del servidor.',
          );
        }
 
        guardada = await _actividadesService.establecerImagenPrincipal(
          token: _token,
          sitioId: _sitioId,
          actividadId: guardada.id,
          url: principalDeseada,
        );
 
        urlsDisponibles = obtenerUrls(guardada);
      }
 
      for (final url in imagenesEliminar.toSet()) {
        if (url == guardada.imagenPrincipal) {
          throw Exception(
            'No se puede eliminar la imagen principal actual. '
            'Selecciona otra portada antes de continuar.',
          );
        }
 
        if (!urlsDisponibles.contains(url)) {
          continue;
        }
 
        guardada = await _actividadesService.eliminarImagen(
          token: _token,
          sitioId: _sitioId,
          actividadId: guardada.id,
          url: url,
        );
 
        urlsDisponibles = obtenerUrls(guardada);
      }
 
      if (mounted) {
        _mostrarMensaje(
          actividad == null
              ? 'Actividad creada correctamente.'
              : 'Actividad actualizada correctamente.',
        );
      }
    } catch (error) {
      if (mounted) {
        _mostrarMensaje(
          error.toString().replaceFirst('Exception: ', ''),
          esError: true,
        );
      }
 
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }
 
  Future<void> _enviarARevision(
    SitioActividadModel actividad,
  ) async {
    try {
      await _actividadesService.enviarARevision(
        token: _token,
        sitioId: _sitioId,
        actividadId: actividad.id,
      );
 
      if (!mounted) return;
 
      _mostrarMensaje('La actividad fue enviada a revisión.');
      await _cargarActividades();
    } catch (error) {
      if (!mounted) return;
 
      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }
  }
 
  Future<void> _eliminarActividad(
    SitioActividadModel actividad,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.sitioSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioPanelCardRadius,
          ),
        ),
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.sitioError,
          size: 32,
        ),
        title: const Text(
          'Eliminar actividad',
          style: TextStyle(
            color: AppColors.sitioTextPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          '¿Deseas eliminar definitivamente "${actividad.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
          style: const TextStyle(
            color: AppColors.sitioTextSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.sitioPrimary,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioError,
              foregroundColor: AppColors.sitioTextOnPrimary,
            ),
          ),
        ],
      ),
    );
 
    if (confirmar != true || !mounted) return;
 
    setState(() => _guardando = true);
 
    try {
      await _actividadesService.eliminarActividad(
        token: _token,
        sitioId: _sitioId,
        actividadId: actividad.id,
      );
 
      if (!mounted) return;
 
      _mostrarMensaje('Actividad eliminada correctamente.');
      await _cargarActividades();
    } catch (error) {
      if (!mounted) return;
 
      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }
 
  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    if (!mounted) return;
 
    // Aviso en el overlay raíz: siempre queda encima de los
    // formularios y diálogos.
    if (esError) {
      AvisosSitio.error(context, mensaje);
    } else {
      AvisosSitio.exito(context, mensaje);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final esDesktop = ancho >= 900;
 
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: esDesktop
                ? AppDimensions.sitioPagePadding
                : AppDimensions.sitioPagePaddingCompact,
            vertical: AppDimensions.sitioSectionGapCompact,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(esDesktop),
                  const SizedBox(
                    height: AppDimensions.sitioSectionGap,
                  ),
                  _resumen(esDesktop, ancho),
                  const SizedBox(
                    height: AppDimensions.sitioSectionGap,
                  ),
                  TarjetaSeccionSitio(
                    titulo: 'Actividades turísticas',
                    subtitulo:
                        'Administra las experiencias que ofreces a tus visitantes.',
                    icono: Icons.local_activity_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: esDesktop ? null : double.infinity,
                          child: Align(
                            alignment: esDesktop
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: _guardando
                                  ? null
                                  : () => _mostrarFormulario(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Nueva actividad'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sitioPrimary,
                                foregroundColor:
                                    AppColors.sitioTextOnPrimary,
                                minimumSize: const Size(
                                  0,
                                  AppDimensions.sitioButtonHeight,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.sitioFormRadius,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: AppDimensions.sitioSectionGapCompact,
                        ),
                        _contenidoActividades(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.sitioSectionGap,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
 
  Widget _encabezado(bool esDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.sitioPrimary,
            AppColors.sitioPrimaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_activity_rounded,
              color: AppColors.sitioTextOnPrimary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GESTIÓN DE TU EXPERIENCIA',
                  style: TextStyle(
                    color: Color(0xFFE6EDE7),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Actividades',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.sitioTextOnPrimary,
                        fontSize: esDesktop ? 28 : 24,
                      ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Gestiona las experiencias que hacen especial tu sitio turístico.',
                  style: TextStyle(
                    color: Color(0xFFE6EDE7),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (esDesktop) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _cargando ? null : _cargarActividades,
              tooltip: 'Actualizar actividades',
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.sitioTextOnPrimary,
            ),
          ],
        ],
      ),
    );
  }
 
  Widget _resumen(bool esDesktop, double ancho) {
    final tarjetas = [
      TarjetaResumenSitio(
        titulo: 'Total',
        valor: _actividades.length.toString(),
        descripcion: 'Actividades registradas',
        icono: Icons.local_activity_rounded,
      ),
      TarjetaResumenSitio(
        titulo: 'Publicadas',
        valor: _cantidadPublicadas.toString(),
        descripcion: 'Disponibles para visitantes',
        icono: Icons.check_circle_outline_rounded,
      ),
      TarjetaResumenSitio(
        titulo: 'En revisión',
        valor: _cantidadEnRevision.toString(),
        descripcion: 'Pendientes de aprobación',
        icono: Icons.hourglass_empty_rounded,
      ),
    ];
 
    final columnas = esDesktop
        ? 3
        : ancho >= 520
            ? 3
            : 1;
 
    if (columnas == 1) {
      return Column(
        children: [
          for (int i = 0; i < tarjetas.length; i++) ...[
            tarjetas[i],
            if (i < tarjetas.length - 1)
              const SizedBox(
                height: AppDimensions.sitioPanelCardGap,
              ),
          ],
        ],
      );
    }
 
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tarjetas.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: AppDimensions.sitioPanelCardGap,
        mainAxisSpacing: AppDimensions.sitioPanelCardGap,
        mainAxisExtent: esDesktop ? 150 : 165,
      ),
      itemBuilder: (context, index) => tarjetas[index],
    );
  }
 
  Widget _contenidoActividades() {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.sitioSectionGap,
          ),
          child: CircularProgressIndicator(
            color: AppColors.sitioPrimary,
          ),
        ),
      );
    }
 
    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          AppDimensions.sitioPanelCardPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.sitioErrorSoft,
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: AppColors.sitioError,
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.sitioError,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _cargarActividades,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Intentar nuevamente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sitioPrimary,
                side: const BorderSide(
                  color: AppColors.sitioPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
 
    if (_actividades.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 30,
        ),
        decoration: BoxDecoration(
          color: AppColors.sitioSurfaceSoft,
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          border: Border.all(
            color: AppColors.sitioDivider,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.local_activity_outlined,
              size: 42,
              color: AppColors.sitioPrimary,
            ),
            SizedBox(height: 12),
            Text(
              'Aún no tienes actividades registradas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.sitioTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Crea tu primera actividad para que los visitantes conozcan las experiencias que ofreces.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.sitioTextSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }
 
    return Column(
      children: _actividades.map((actividad) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppDimensions.sitioPanelCardGap,
          ),
          child: TarjetaActividadSitio(
            actividad: actividad,
            guardando: _guardando,
            onEditar: () => _mostrarFormulario(actividad: actividad),
            onEnviarRevision: () => _enviarARevision(actividad),
            onEliminar: () => _eliminarActividad(actividad),
          ),
        );
      }).toList(),
    );
  }
}