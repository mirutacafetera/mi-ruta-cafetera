
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_actividad_model.dart';
import '../../services/sitio/sitio_actividades_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
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

class _SitioActividadesScreenState
    extends State<SitioActividadesScreen> {
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
  }) async {
    if (_token.isEmpty || _sitioId.isEmpty) {
      throw Exception('No hay una sesión activa del sitio.');
    }

    setState(() => _guardando = true);

    try {
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

      // Subir las imágenes nuevas.
      if (imagenes.isNotEmpty) {
        guardada = await _actividadesService.subirImagenes(
          token: _token,
          sitioId: _sitioId,
          actividadId: guardada.id,
          archivos: imagenes,
        );
      }

      // Si la imagen principal elegida ya está guardada y no se
      // ha marcado para eliminar, establecerla antes de borrar otras.
      if (imagenPrincipalUrl.isNotEmpty &&
          !imagenesEliminar.contains(imagenPrincipalUrl) &&
          guardada.imagenes.contains(imagenPrincipalUrl)) {
        guardada =
            await _actividadesService.establecerImagenPrincipal(
          token: _token,
          sitioId: _sitioId,
          actividadId: guardada.id,
          url: imagenPrincipalUrl,
        );
      }

      // Eliminar las imágenes guardadas que se marcaron para quitar.
      for (final url in imagenesEliminar) {
        // El backend no permite eliminar la principal directamente.
        // Por eso se exige elegir otra antes de eliminarla.
        if (url == guardada.imagenPrincipal) {
          throw Exception(
            'Selecciona otra imagen principal antes de eliminar '
            'la imagen principal actual.',
          );
        }

        guardada = await _actividadesService.eliminarImagen(
          token: _token,
          sitioId: _sitioId,
          actividadId: guardada.id,
          url: url,
        );
      }
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
        title: const Text('Eliminar actividad'),
        content: Text(
          '¿Deseas eliminar definitivamente "${actividad.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
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

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor:
              esError ? AppColors.error : AppColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: esDesktop
                ? AppDimensions.pageHorizontal
                : AppDimensions.pageHorizontalSmall,
            vertical: AppDimensions.spacingLg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(esDesktop),
                  const SizedBox(height: AppDimensions.spacingLg),
                  _resumen(esDesktop),
                  const SizedBox(height: AppDimensions.sectionGap),
                  TarjetaSeccionSitio(
                    titulo: 'Actividades turísticas',
                    subtitulo:
                        'Administra las experiencias que ofreces a tus visitantes.',
                    icono: Icons.local_activity_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: esDesktop
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _guardando
                                ? null
                                : () => _mostrarFormulario(),
                            icon: const Icon(Icons.add),
                            label: const Text('Nueva actividad'),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        _contenidoActividades(),
                      ],
                    ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actividades',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Gestiona las experiencias que hacen especial tu sitio turístico.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        if (esDesktop)
          IconButton(
            onPressed: _cargando ? null : _cargarActividades,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }

  Widget _resumen(bool esDesktop) {
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

    if (esDesktop) {
      return Row(
        children: [
          Expanded(child: tarjetas[0]),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(child: tarjetas[1]),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(child: tarjetas[2]),
        ],
      );
    }

    return Column(
      children: [
        tarjetas[0],
        const SizedBox(height: AppDimensions.spacingMd),
        tarjetas[1],
        const SizedBox(height: AppDimensions.spacingMd),
        tarjetas[2],
      ],
    );
  }

  Widget _contenidoActividades() {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          OutlinedButton.icon(
            onPressed: _cargarActividades,
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar nuevamente'),
          ),
        ],
      );
    }

    if (_actividades.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXl),
        child: Center(
          child: Text('Aún no tienes actividades registradas.'),
        ),
      );
    }

    return Column(
      children: _actividades.map((actividad) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppDimensions.spacingMd,
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
