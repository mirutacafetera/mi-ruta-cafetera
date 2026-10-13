import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/admin/admin_contenido_model.dart';
import '../../services/admin/admin_moderacion_contenido_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminContenidosScreen extends StatefulWidget {
  const AdminContenidosScreen({super.key});

  @override
  State<AdminContenidosScreen> createState() => _AdminContenidosScreenState();
}

class _AdminContenidosScreenState extends State<AdminContenidosScreen> {
  List<AdminContenidoModel> _contenidos = [];
  bool _cargando = true;
  bool _procesando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarContenidos();
  }

  Future<void> _cargarContenidos() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado =
          await AdminModeracionContenidoService.obtenerPendientes();

      if (!mounted) return;

      setState(() {
        _contenidos = resultado;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<void> _aprobar(AdminContenidoModel contenido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aprobar contenido'),
        content: Text(
          '¿Deseas aprobar "${contenido.titulo}" '
          'para su publicación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await _ejecutarAccion(
      () => AdminModeracionContenidoService.aprobar(contenido.id),
      'El contenido fue aprobado correctamente.',
    );
  }

  Future<void> _rechazar(AdminContenidoModel contenido) async {
    final controlador = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar contenido'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Motivo del rechazo',
            hintText: 'Indica qué debe corregir el sitio turístico.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final texto = controlador.text.trim();

              if (texto.length < 3) {
                ScaffoldMessenger.of(dialogContext)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Escribe un motivo de al menos 3 caracteres.',
                      ),
                    ),
                  );
                return;
              }

              Navigator.pop(dialogContext, texto);
            },
            child: const Text('Confirmar rechazo'),
          ),
        ],
      ),
    );

    controlador.dispose();

    if (motivo == null || !mounted) return;

    await _ejecutarAccion(
      () => AdminModeracionContenidoService.rechazar(
        contenidoId: contenido.id,
        motivoRechazo: motivo,
      ),
      'El contenido fue rechazado.',
    );
  }

  Future<void> _ejecutarAccion(
    Future<void> Function() accion,
    String mensaje,
  ) async {
    if (_procesando) return;

    setState(() => _procesando = true);

    try {
      await accion();

      if (!mounted) return;

      _mostrarMensaje(mensaje);
      await _cargarContenidos();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(
        e.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: error ? AppColors.error : null,
        ),
      );
  }

  Future<void> _verDetalle(AdminContenidoModel contenido) async {
    try {
      final detalle = await AdminModeracionContenidoService.obtenerDetalle(
        contenido.id,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            detalle.titulo.isNotEmpty ? detalle.titulo : 'Contenido sin título',
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (detalle.imagenPrincipal.isNotEmpty) ...[
                    _imagen(detalle.imagenPrincipal, alto: 200),
                    const SizedBox(height: AppDimensions.spacingMd),
                  ],

                  Text(
                    'Sitio turístico',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    detalle.sitioNombre.isNotEmpty
                        ? detalle.sitioNombre
                        : 'Sitio sin nombre',
                  ),

                  if (detalle.ciudad.isNotEmpty ||
                      detalle.departamento.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      [
                        detalle.ciudad,
                        detalle.departamento,
                      ].where((e) => e.isNotEmpty).join(', '),
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    detalle.descripcion.isNotEmpty
                        ? detalle.descripcion
                        : 'Sin descripción.',
                  ),

                  // GUÍAS DE AUDIO
                  if (detalle.audioGuias.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingLg),
                    Text(
                      'Guías de audio',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    ...detalle.audioGuias.map(
                      (audio) => _ReproductorAudioGuia(
                        key: ValueKey(audio.url),
                        audio: audio,
                      ),
                    ),
                  ],

                  // GALERÍA DE IMÁGENES
                  if (detalle.imagenes.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingLg),
                    Text(
                      'Galería de imágenes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    ...detalle.imagenes.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingSm,
                        ),
                        child: _imagen(url, alto: 160),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(
        e.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    }
  }

  Widget _imagen(String url, {double alto = 150}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Image.network(
        url,
        width: double.infinity,
        height: alto,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: alto,
          width: double.infinity,
          color: AppColors.cream,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: AppDimensions.spacingMd),
          const Text(
            'No fue posible cargar los contenidos pendientes.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.spacingLg),
          Center(
            child: FilledButton.icon(
              onPressed: _cargarContenidos,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar nuevamente'),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarContenidos,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.article_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contenidos pendientes',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_contenidos.length} publicación'
                          '${_contenidos.length == 1 ? '' : 'es'} '
                          'esperando revisión.',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _procesando ? null : _cargarContenidos,
                    tooltip: 'Actualizar',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          if (_contenidos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingSection,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 68,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'No hay contenidos pendientes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  const Text(
                    'Las publicaciones enviadas por los sitios '
                    'turísticos aparecerán aquí para su revisión.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._contenidos.map(_crearTarjeta),

          if (_procesando) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _crearTarjeta(AdminContenidoModel contenido) {
    final ubicacion = [
      contenido.ciudad,
      contenido.departamento,
    ].where((e) => e.isNotEmpty).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contenido.imagenPrincipal.isNotEmpty) ...[
              _imagen(contenido.imagenPrincipal, alto: 190),
              const SizedBox(height: AppDimensions.spacingMd),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    contenido.titulo.isNotEmpty
                        ? contenido.titulo
                        : 'Contenido sin título',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    'Pendiente',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Expanded(
                  child: Text(
                    contenido.sitioNombre.isNotEmpty
                        ? contenido.sitioNombre
                        : 'Sitio turístico',
                  ),
                ),
              ],
            ),
            if (ubicacion.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(child: Text(ubicacion)),
                ],
              ),
            ],
            if (contenido.descripcion.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                contenido.descripcion,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppDimensions.spacingMd),
            OutlinedButton.icon(
              onPressed: _procesando ? null : () => _verDetalle(contenido),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Ver detalle'),
            ),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: [
                OutlinedButton.icon(
                  onPressed: _procesando ? null : () => _rechazar(contenido),
                  icon: const Icon(Icons.close),
                  label: const Text('Rechazar'),
                ),
                FilledButton.icon(
                  onPressed: _procesando ? null : () => _aprobar(contenido),
                  icon: const Icon(Icons.check),
                  label: const Text('Aprobar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reproductor individual para cada guía de audio.
class _ReproductorAudioGuia extends StatefulWidget {
  final AdminAudioGuiaModel audio;

  const _ReproductorAudioGuia({super.key, required this.audio});

  @override
  State<_ReproductorAudioGuia> createState() => _ReproductorAudioGuiaState();
}

class _ReproductorAudioGuiaState extends State<_ReproductorAudioGuia> {
  late final AudioPlayer _player;

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _prepararAudio();
  }

  Future<void> _prepararAudio() async {
    try {
      final url = widget.audio.url.trim();

      if (url.isEmpty) {
        throw Exception('No hay una URL de audio.');
      }

      await _player.setUrl(url);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar este audio.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _reproducirPausar() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo reproducir el audio.';
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.headphones_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.audio.titulo.isNotEmpty
                        ? widget.audio.titulo
                        : 'Guía de audio',
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.audio.duracion.isNotEmpty)
                  Text(widget.audio.duracion, style: tema.textTheme.bodySmall),
              ],
            ),
            if (widget.audio.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(widget.audio.descripcion),
            ],
            const SizedBox(height: 8),
            if (_cargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Row(
                children: [
                  Icon(Icons.error_outline, color: tema.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: tema.colorScheme.error),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Reintentar carga',
                    onPressed: () {
                      setState(() {
                        _cargando = true;
                        _error = null;
                      });
                      _prepararAudio();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              )
            else
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final estado = snapshot.data;
                  final reproduciendo = estado?.playing ?? false;
                  final completado =
                      estado?.processingState == ProcessingState.completed;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: reproduciendo
                                ? 'Pausar audio'
                                : 'Reproducir audio',
                            onPressed: () async {
                              if (completado) {
                                await _player.seek(Duration.zero);
                              }
                              await _reproducirPausar();
                            },
                            icon: Icon(
                              reproduciendo
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reproduciendo
                                  ? 'Reproduciendo guía'
                                  : completado
                                  ? 'Audio finalizado'
                                  : 'Escuchar guía de audio',
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<Duration>(
                        stream: _player.positionStream,
                        builder: (context, positionSnapshot) {
                          final posicion =
                              positionSnapshot.data ?? Duration.zero;
                          final duracion = _player.duration ?? Duration.zero;

                          final maximo = duracion.inMilliseconds > 0
                              ? duracion.inMilliseconds.toDouble()
                              : 1.0;

                          final valor = posicion.inMilliseconds
                              .toDouble()
                              .clamp(0.0, maximo);

                          return Column(
                            children: [
                              Slider(
                                value: valor,
                                max: maximo,
                                onChanged: duracion.inMilliseconds <= 0
                                    ? null
                                    : (nuevoValor) {
                                        _player.seek(
                                          Duration(
                                            milliseconds: nuevoValor.round(),
                                          ),
                                        );
                                      },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatearDuracion(posicion),
                                    style: tema.textTheme.bodySmall,
                                  ),
                                  Text(
                                    _formatearDuracion(duracion),
                                    style: tema.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatearDuracion(Duration duracion) {
    final minutos = duracion.inMinutes;
    final segundos = duracion.inSeconds.remainder(60);

    return '$minutos:${segundos.toString().padLeft(2, '0')}';
  }
}
