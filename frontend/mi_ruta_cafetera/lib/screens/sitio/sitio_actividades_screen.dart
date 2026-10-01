import 'package:flutter/material.dart';

import '../../models/sitio/sitio_actividad_model.dart';
import '../../services/sitio/sitio_actividades_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
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

  final SitioSesionService _sesionService =
      SitioSesionService();

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
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null ||
          sesion.token.isEmpty ||
          sesion.sitioId.isEmpty) {
        throw Exception(
          'No se encontró una sesión activa del sitio.',
        );
      }

      if (!sesion.activo) {
        throw Exception(
          'La cuenta del sitio está inactiva.',
        );
      }

      _token = sesion.token;
      _sitioId = sesion.sitioId;

      final actividades =
          await _actividadesService.obtenerActividades(
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
        _error = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
        _cargando = false;
      });
    }
  }

  int get _cantidadPublicadas {
    return _actividades
        .where(
          (actividad) =>
              actividad.estadoPublicacion == 'aprobado' &&
              actividad.activo,
        )
        .length;
  }

  Future<void> _mostrarFormulario({
    SitioActividadModel? actividad,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _FormularioActividadDialog(
          actividad: actividad,
          onGuardar: (
            nombre,
            descripcion,
            precio,
            horario,
            duracion,
          ) async {
            await _guardarActividad(
              actividad: actividad,
              nombre: nombre,
              descripcion: descripcion,
              precio: precio,
              horario: horario,
              duracion: duracion,
            );
          },
        );
      },
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
  }) async {
    if (_token.isEmpty || _sitioId.isEmpty) {
      throw Exception(
        'No hay una sesión activa del sitio.',
      );
    }

    if (nombre.trim().isEmpty) {
      throw Exception(
        'El nombre de la actividad es obligatorio.',
      );
    }

    if (mounted) {
      setState(() {
        _guardando = true;
      });
    }

    try {
      if (actividad == null) {
        await _actividadesService.crearActividad(
          token: _token,
          sitioId: _sitioId,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          horario: horario,
          duracion: duracion,
        );
      } else {
        await _actividadesService.actualizarActividad(
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
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
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

      _mostrarMensaje(
        'La actividad fue enviada a revisión.',
      );

      await _cargarActividades();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );
    }
  }

  Future<void> _desactivarActividad(
    SitioActividadModel actividad,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Desactivar actividad',
          ),
          content: Text(
            '¿Deseas desactivar "${actividad.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _actividadesService.desactivarActividad(
        token: _token,
        sitioId: _sitioId,
        actividadId: actividad.id,
      );

      if (!mounted) return;

      _mostrarMensaje(
        'Actividad desactivada correctamente.',
      );

      await _cargarActividades();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        esError: true,
      );
    }
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            esError ? Colors.red.shade700 : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esEscritorio = ancho >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        esEscritorio
            ? AppDimensions.spacingXl
            : AppDimensions.spacingMd,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(context),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              _resumenActividades(esEscritorio),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              _seccionActividades(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividades',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Administra las experiencias y actividades que los visitantes pueden realizar en tu sitio.',
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _resumenActividades(bool esEscritorio) {
    final contenido = [
      _tarjetaResumen(
        icono: Icons.local_activity_rounded,
        titulo: 'Actividades',
        valor: _actividades.length.toString(),
        descripcion: 'Actividades registradas',
      ),
      _tarjetaResumen(
        icono: Icons.visibility_rounded,
        titulo: 'Publicadas',
        valor: _cantidadPublicadas.toString(),
        descripcion: 'Disponibles para visitantes',
      ),
    ];

    if (esEscritorio) {
      return Row(
        children: [
          Expanded(child: contenido[0]),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(child: contenido[1]),
        ],
      );
    }

    return Column(
      children: [
        contenido[0],
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        contenido[1],
      ],
    );
  }

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
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Icon(
              icono,
              color: AppColors.primary,
              size: 25,
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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

  Widget _seccionActividades() {
    return TarjetaSeccionSitio(
      titulo: 'Mis actividades',
      subtitulo:
          'Agrega experiencias para que los visitantes conozcan lo que pueden realizar.',
      icono: Icons.local_activity_rounded,
      child: Column(
        children: [
          _botonAgregarActividad(),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          _contenidoActividades(),
        ],
      ),
    );
  }

  Widget _botonAgregarActividad() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _guardando
            ? null
            : () => _mostrarFormulario(),
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Agregar actividad',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingMd,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenidoActividades() {
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.all(
          AppDimensions.spacingXl,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return _estadoError();
    }

    if (_actividades.isEmpty) {
      return _estadoSinActividades();
    }

    return Column(
      children: _actividades
          .map(
            (actividad) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingMd,
              ),
              child: _tarjetaActividad(actividad),
            ),
          )
          .toList(),
    );
  }

  Widget _estadoError() {
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
            Icons.error_outline_rounded,
            color: AppColors.textSecondary,
            size: 44,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          const Text(
            'No pudimos cargar las actividades',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
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
            onPressed: _cargarActividades,
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

  Widget _estadoSinActividades() {
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
      child: const Column(
        children: [
          Icon(
            Icons.hiking_rounded,
            color: AppColors.textSecondary,
            size: 44,
          ),
          SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            'Todavía no hay actividades',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Las actividades que registres aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaActividad(
    SitioActividadModel actividad,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: AppColors.background,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  actividad.nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _estadoActividad(
                actividad.estadoPublicacion,
              ),
            ],
          ),
          if (actividad.descripcion.isNotEmpty) ...[
            const SizedBox(
              height: AppDimensions.spacingSm,
            ),
            Text(
              actividad.descripcion,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Wrap(
            spacing: AppDimensions.spacingLg,
            runSpacing: AppDimensions.spacingSm,
            children: [
              if (actividad.precio > 0)
                _datoActividad(
                  Icons.attach_money_rounded,
                  '\$${actividad.precio.toStringAsFixed(0)}',
                ),
              if (actividad.horario.isNotEmpty)
                _datoActividad(
                  Icons.schedule_rounded,
                  actividad.horario,
                ),
              if (actividad.duracion.isNotEmpty)
                _datoActividad(
                  Icons.timer_outlined,
                  actividad.duracion,
                ),
            ],
          ),
          if (actividad.motivoRechazo.isNotEmpty &&
              actividad.estadoPublicacion == 'rechazado') ...[
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                AppDimensions.spacingMd,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withValues(
                  alpha: 0.06,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
              child: Text(
                'Motivo del rechazo:\n${actividad.motivoRechazo}',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              OutlinedButton.icon(
                onPressed: _guardando
                    ? null
                    : () => _mostrarFormulario(
                          actividad: actividad,
                        ),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                ),
                label: const Text('Editar'),
              ),
              if (actividad.estadoPublicacion ==
                  'borrador')
                ElevatedButton.icon(
                  onPressed: _guardando
                      ? null
                      : () => _enviarARevision(
                            actividad,
                          ),
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Enviar a revisión',
                  ),
                ),
              if (actividad.activo)
                TextButton.icon(
                  onPressed: _guardando
                      ? null
                      : () => _desactivarActividad(
                            actividad,
                          ),
                  icon: const Icon(
                    Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Desactivar',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estadoActividad(String estado) {
    String texto;
    IconData icono;

    switch (estado) {
      case 'aprobado':
        texto = 'Aprobada';
        icono = Icons.check_circle_rounded;
        break;

      case 'pendiente_revision':
        texto = 'En revisión';
        icono = Icons.hourglass_top_rounded;
        break;

      case 'rechazado':
        texto = 'Rechazada';
        icono = Icons.cancel_rounded;
        break;

      default:
        texto = 'Borrador';
        icono = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoActividad(
    IconData icono,
    String texto,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icono,
          size: 17,
          color: AppColors.primary,
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FormularioActividadDialog extends StatefulWidget {
  final SitioActividadModel? actividad;

  final Future<void> Function(
    String nombre,
    String descripcion,
    double precio,
    String horario,
    String duracion,
  ) onGuardar;

  const _FormularioActividadDialog({
    required this.actividad,
    required this.onGuardar,
  });

  @override
  State<_FormularioActividadDialog> createState() =>
      _FormularioActividadDialogState();
}

class _FormularioActividadDialogState
    extends State<_FormularioActividadDialog> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;
  late final TextEditingController _horarioController;
  late final TextEditingController _duracionController;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    final actividad = widget.actividad;

    _nombreController = TextEditingController(
      text: actividad?.nombre ?? '',
    );

    _descripcionController = TextEditingController(
      text: actividad?.descripcion ?? '',
    );

    _precioController = TextEditingController(
      text: actividad != null && actividad.precio > 0
          ? actividad.precio.toStringAsFixed(0)
          : '',
    );

    _horarioController = TextEditingController(
      text: actividad?.horario ?? '',
    );

    _duracionController = TextEditingController(
      text: actividad?.duracion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _horarioController.dispose();
    _duracionController.dispose();

    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      _mostrarError(
        'El nombre de la actividad es obligatorio.',
      );
      return;
    }

    final precioTexto =
        _precioController.text.trim().replaceAll(',', '.');

    final precio = double.tryParse(precioTexto) ?? 0;

    if (precio < 0) {
      _mostrarError(
        'El precio no puede ser negativo.',
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await widget.onGuardar(
        nombre,
        _descripcionController.text.trim(),
        precio,
        _horarioController.text.trim(),
        _duracionController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      _mostrarError(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.actividad != null;

    return AlertDialog(
      title: Text(
        esEdicion
            ? 'Editar actividad'
            : 'Nueva actividad',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Tour de café especial',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descripcionController,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText:
                      'Describe la experiencia...',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _precioController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _horarioController,
                decoration: const InputDecoration(
                  labelText: 'Horario',
                  hintText: 'Ej. 8:00 a. m. - 4:00 p. m.',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _duracionController,
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  hintText: 'Ej. 2 horas',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _guardando ? null : _guardar,
          icon: _guardando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.save_rounded,
                ),
          label: Text(
            _guardando ? 'Guardando...' : 'Guardar',
          ),
        ),
      ],
    );
  }
}