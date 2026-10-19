
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../models/sitio/sitio_resena_model.dart';
import '../../../services/sitio/sitio_resenas_service.dart';
import '../../../services/usuario/usuario_sesion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/sitio/sitio_avatar_perfil.dart';

class SeccionResenasSitio extends StatefulWidget {
  const SeccionResenasSitio({
    super.key,
    required this.sitioId,
    this.onRequiereCuenta,
  });

  final String sitioId;
  final VoidCallback? onRequiereCuenta;

  @override
  State<SeccionResenasSitio> createState() =>
      _SeccionResenasSitioState();
}

class _SeccionResenasSitioState extends State<SeccionResenasSitio> {
  final SitioResenasService _service = SitioResenasService.instance;
  final UsuarioSesionService _sesionService =
      UsuarioSesionService.instance;
  final TextEditingController _comentarioController =
      TextEditingController();

  List<SitioResenaModel> _resenas = [];
  String? _usuarioIdActual;
  String? _error;
  int _calificacion = 5;
  bool _cargando = true;
  bool _publicando = false;
  String? _eliminandoId;

  double get _promedio {
    if (_resenas.isEmpty) return 0;

    final suma = _resenas.fold<int>(
      0,
      (total, resena) => total + resena.calificacion,
    );

    return suma / _resenas.length;
  }

  @override
  void initState() {
    super.initState();
    _cargarResenas();
    _cargarUsuarioActual();
  }

  @override
  void didUpdateWidget(covariant SeccionResenasSitio oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sitioId != widget.sitioId) {
      _cargarResenas();
    }
  }

  Future<void> _cargarUsuarioActual() async {
    try {
      final sesion = await _sesionService.obtenerSesion();

      if (!mounted) return;

      if (sesion == null || sesion.token.isEmpty) {
        setState(() => _usuarioIdActual = null);
        return;
      }

      final partes = sesion.token.split('.');
      if (partes.length != 3) return;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(partes[1])),
      );

      final datos = jsonDecode(payload);
      if (datos is! Map) return;

      final id = (
        datos['id'] ??
        datos['_id'] ??
        datos['usuarioId'] ??
        datos['sub']
      )?.toString();

      setState(() {
        _usuarioIdActual =
            id == null || id.isEmpty ? null : id;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _usuarioIdActual = null);
    }
  }

  Future<void> _cargarResenas() async {
    if (widget.sitioId.trim().isEmpty) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'Este sitio no tiene un identificador válido.';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado =
          await _service.obtenerPorSitio(widget.sitioId);

      if (!mounted) return;

      setState(() {
        _resenas = resultado;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _mensajeError(e);
        _cargando = false;
      });
    }
  }

  Future<void> _publicarResena() async {
    final comentario = _comentarioController.text.trim();

    if (comentario.isEmpty) {
      _mostrarMensaje('Escribe tu opinión antes de publicar.');
      return;
    }

    if (_publicando) return;

    setState(() => _publicando = true);

    try {
      await _service.crear(
        sitioId: widget.sitioId,
        calificacion: _calificacion,
        comentario: comentario,
      );

      if (!mounted) return;

      _comentarioController.clear();
      setState(() => _calificacion = 5);

      await _cargarResenas();
      await _cargarUsuarioActual();

      if (!mounted) return;

      _mostrarMensaje('¡Tu reseña se publicó correctamente!');
    } catch (e) {
      if (!mounted) return;

      final mensaje = _mensajeError(e);

      if (mensaje.toLowerCase().contains('iniciar sesión')) {
        widget.onRequiereCuenta?.call();
      } else {
        _mostrarMensaje(mensaje);
      }
    } finally {
      if (mounted) {
        setState(() => _publicando = false);
      }
    }
  }

  Future<void> _confirmarEliminacion(
    SitioResenaModel resena,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar reseña'),
          content: const Text(
            '¿Quieres eliminar tu opinión? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    await _eliminarResena(resena);
  }

  Future<void> _eliminarResena(
    SitioResenaModel resena,
  ) async {
    if (_eliminandoId != null) return;

    setState(() => _eliminandoId = resena.id);

    try {
      await _service.eliminar(resena.id);

      if (!mounted) return;

      setState(() {
        _resenas.removeWhere((item) => item.id == resena.id);
        _eliminandoId = null;
      });

      _mostrarMensaje('Reseña eliminada correctamente.');
    } catch (e) {
      if (!mounted) return;

      setState(() => _eliminandoId = null);

      final mensaje = _mensajeError(e);

      if (mensaje.toLowerCase().contains('iniciar sesión')) {
        widget.onRequiereCuenta?.call();
      } else {
        _mostrarMensaje(mensaje);
      }
    }
  }

  String _mensajeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
        vertical: AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opiniones de los visitantes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Conoce las experiencias de otros viajeros y comparte la tuya.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          _construirResumen(),
          const SizedBox(height: AppDimensions.spacingLg),
          _construirFormulario(),
          const SizedBox(height: AppDimensions.spacingXl),
          _construirListado(),
        ],
      ),
    );
  }

  Widget _construirResumen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 38,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resenas.isEmpty
                      ? 'Sin calificaciones'
                      : _promedio.toStringAsFixed(1),
                  style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                ),
                Text(
                  '${_resenas.length} '
                  '${_resenas.length == 1 ? 'reseña' : 'reseñas'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirFormulario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparte tu experiencia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          const Text('¿Qué calificación le das a este lugar?'),
          const SizedBox(height: AppDimensions.spacingSm),
          LayoutBuilder(
            builder: (context, constraints) {
              final anchoEstrella = constraints.maxWidth / 5;

              return Row(
                children: List.generate(5, (index) {
                  final numero = index + 1;

                  return SizedBox(
                    width: anchoEstrella,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 48,
                      ),
                      tooltip: '$numero estrellas',
                      onPressed: _publicando
                          ? null
                          : () => setState(
                                () => _calificacion = numero,
                              ),
                      icon: Icon(
                        numero <= _calificacion
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          TextField(
            controller: _comentarioController,
            enabled: !_publicando,
            minLines: 3,
            maxLines: 5,
            maxLength: 1000,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Cuéntanos qué te gustó de este lugar...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _publicando ? null : _publicarResena,
              icon: _publicando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _publicando ? 'Publicando...' : 'Publicar reseña',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirListado() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _resenas.isEmpty) {
      return Column(
        children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.spacingSm),
          OutlinedButton.icon(
            onPressed: _cargarResenas,
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      );
    }

    if (_resenas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 42),
            SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Todavía no hay reseñas',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Sé la primera persona en compartir su experiencia.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final resena in _resenas) ...[
          _tarjetaResena(resena),
          const SizedBox(height: AppDimensions.spacingMd),
        ],
      ],
    );
  }

  Widget _tarjetaResena(SitioResenaModel resena) {
    final nombre = resena.nombreUsuario.trim().isEmpty
        ? 'Visitante'
        : resena.nombreUsuario.trim();

    final fecha = resena.creadaEn;
    final fechaTexto = fecha == null
        ? ''
        : '${fecha.day.toString().padLeft(2, '0')}/'
            '${fecha.month.toString().padLeft(2, '0')}/'
            '${fecha.year}';

    final usuarioActual = _usuarioIdActual;
    final esPropia = usuarioActual != null &&
        usuarioActual.isNotEmpty &&
        resena.usuarioId == usuarioActual;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SitioAvatarPerfil(
                fotoPerfil: resena.fotoPerfil,
                avatar: resena.avatar,
                nombre: nombre,
                radio: 24,
                colorFondo: AppColors.surfaceGreen,
                colorIcono: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (fechaTexto.isNotEmpty)
                      Text(
                        fechaTexto,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 0,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < resena.calificacion
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                  if (esPropia)
                    PopupMenuButton<String>(
                      tooltip: 'Opciones de mi reseña',
                      padding: EdgeInsets.zero,
                      onSelected: (opcion) {
                        if (opcion == 'eliminar') {
                          _confirmarEliminacion(resena);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('Eliminar reseña'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            resena.comentario.trim().isEmpty
                ? 'Sin comentario escrito.'
                : resena.comentario,
            softWrap: true,
          ),
          if (_eliminandoId == resena.id) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}
