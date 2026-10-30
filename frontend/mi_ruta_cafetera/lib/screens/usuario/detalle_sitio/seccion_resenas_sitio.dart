import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart'; // <-- Importante para kIsWeb
import 'package:flutter/material.dart';

import '../../../models/sitio/sitio_resena_model.dart';
import '../../../services/sitio/sitio_resenas_service.dart';
import '../../../services/usuario/usuario_sesion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/sitio/sitio_avatar_perfil.dart';
import '../../../l10n/textos.dart';
import '../../../widgets/usuario/detalle_sitio/componentes_detalle.dart';

class SeccionResenasSitio extends StatefulWidget {
  const SeccionResenasSitio({
    super.key,
    required this.sitioId,
    this.onRequiereCuenta,
    this.mostrarEncabezado = true,
  });

  final String sitioId;

  /// Cuando la pantalla que lo contiene ya dibuja el encabezado
  /// de la sección, se envía `false` para no repetirlo.
  final bool mostrarEncabezado;
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

  final ImagePicker _selectorImagenes = ImagePicker();
  final List<XFile> _imagenesSeleccionadas = [];
  static const int _maximoImagenes = 10;

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
        _error = Textos.t('Este sitio no tiene un identificador válido.');
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

  Future<void> _seleccionarImagenes() async {
    if (_publicando) return;

    final disponibles =
        _maximoImagenes - _imagenesSeleccionadas.length;

    if (disponibles <= 0) {
      _mostrarMensaje(
        Textos.t('Solo puedes adjuntar hasta 10 imágenes.'),
      );
      return;
    }

    try {
      final seleccionadas = await _selectorImagenes.pickMultiImage(
        imageQuality: 85,
      );

      if (!mounted || seleccionadas.isEmpty) return;

      final nuevas = seleccionadas
          .where(
            (archivo) => !_imagenesSeleccionadas.any(
              (actual) => actual.path == archivo.path,
            ),
          )
          .take(disponibles)
          .toList();

      setState(() {
        _imagenesSeleccionadas.addAll(nuevas);
      });

      if (seleccionadas.length > disponibles) {
        _mostrarMensaje(
        Textos.t('Puedes adjuntar hasta 10 imágenes en total.'),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        Textos.t('No fue posible seleccionar las imágenes.'),
      );
    }
  }

  void _quitarImagen(int indice) {
    if (_publicando) return;

    setState(() {
      _imagenesSeleccionadas.removeAt(indice);
    });
  }

  Future<void> _publicarResena() async {
    final comentario = _comentarioController.text.trim();

    if (comentario.isEmpty) {
      _mostrarMensaje(Textos.t('Escribe tu opinión antes de publicar.'));
      return;
    }

    if (_publicando) return;

    setState(() => _publicando = true);

    try {
      await _service.crear(
        sitioId: widget.sitioId,
        calificacion: _calificacion,
        comentario: comentario,
        imagenes: List<XFile>.from(_imagenesSeleccionadas),
      );

      if (!mounted) return;

      _comentarioController.clear();
      setState(() {
        _calificacion = 5;
        _imagenesSeleccionadas.clear();
      });

      await _cargarResenas();
      await _cargarUsuarioActual();

      if (!mounted) return;

      _mostrarMensaje(Textos.t('¡Tu reseña se publicó correctamente!'));
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
          title: const Tr('Eliminar reseña'),
          content: const Tr(
            '¿Quieres eliminar tu opinión? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Tr('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Tr('Eliminar'),
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

      _mostrarMensaje(Textos.t('Reseña eliminada correctamente.'));
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
          if (widget.mostrarEncabezado) ...[
            EncabezadoSeccionDetalle(
              icono: Icons.reviews_outlined,
              titulo: Textos.t('Opiniones de los visitantes'),
              descripcion: Textos.t(
                'Conoce las experiencias de otros viajeros y comparte la tuya.',
              ),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
          ],
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
      decoration: decoracionTarjetaDetalle(
        radio: AppDimensions.cardRadius,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.sitioAccent,
            size: 38,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resenas.isEmpty
                      ? Textos.t('Sin calificaciones')
                      : _promedio.toStringAsFixed(1),
                  style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.sitioTextPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                ),
                Text(
                  Textos.t(
                    _resenas.length == 1 ? '{0} reseña' : '{0} reseñas',
                    [_resenas.length],
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.sitioTextSecondary,
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
      decoration: decoracionTarjetaDetalle(
        radio: AppDimensions.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tr(
            'Comparte tu experiencia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          const Tr('¿Qué calificación le das a este lugar?'),
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
                      tooltip: Textos.t('{0} estrellas', [numero]),
                      onPressed: _publicando
                          ? null
                          : () => setState(
                                () => _calificacion = numero,
                              ),
                      icon: Icon(
                        numero <= _calificacion
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.sitioAccent,
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
            decoration: InputDecoration(
              hintText: Textos.t('Cuéntanos qué te gustó de este lugar...'),
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _publicando ||
                        _imagenesSeleccionadas.length >= _maximoImagenes
                    ? null
                    : _seleccionarImagenes,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  Textos.t(
                    'Añadir fotos ({0}/10)',
                    [_imagenesSeleccionadas.length],
                  ),
                ),
              ),
            ],
          ),
          if (_imagenesSeleccionadas.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: [
                for (int i = 0; i < _imagenesSeleccionadas.length; i++)
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // CORREGIDO PARA SOPORTAR FLUTTER WEB Y MÓVIL
                          child: kIsWeb
                              ? Image.network(
                                  _imagenesSeleccionadas[i].path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_imagenesSeleccionadas[i].path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: IconButton(
                            tooltip: Textos.t('Quitar imagen'),
                            onPressed: _publicando
                                ? null
                                : () => _quitarImagen(i),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(30, 30),
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.spacingSm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sitioPrimary,
                foregroundColor: AppColors.sitioTextOnPrimary,
                minimumSize: const Size.fromHeight(
                  AppDimensions.buttonHeight,
                ),
              ),
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
                _publicando ? Textos.t('Publicando...') : Textos.t('Publicar reseña'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirListado() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.sitioPrimary),
      );
    }

    if (_error != null && _resenas.isEmpty) {
      return TarjetaEstadoDetalle(
        icono: Icons.cloud_off_outlined,
        titulo: _error!,
        accion: OutlinedButton.icon(
          onPressed: _cargarResenas,
          icon: const Icon(Icons.refresh),
          label: const Tr('Intentar de nuevo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sitioPrimary,
            side: const BorderSide(color: AppColors.sitioPrimary),
          ),
        ),
      );
    }

    if (_resenas.isEmpty) {
      return TarjetaEstadoDetalle(
        icono: Icons.rate_review_outlined,
        titulo: Textos.t('Todavía no hay reseñas'),
        descripcion:
            Textos.t('Sé la primera persona en compartir su experiencia.'),
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
        ? Textos.t('Visitante')
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
      decoration: decoracionTarjetaDetalle(
        radio: AppDimensions.cardRadius,
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
                colorFondo: AppColors.sitioSurfaceGreen,
                colorIcono: AppColors.sitioPrimary,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.sitioTextPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (fechaTexto.isNotEmpty)
                      Text(
                        fechaTexto,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.sitioTextSecondary,
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
                        color: AppColors.sitioAccent,
                        size: 18,
                      ),
                    ),
                  ),
                  if (esPropia)
                    PopupMenuButton<String>(
                      tooltip: Textos.t('Opciones de mi reseña'),
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
                                color: AppColors.sitioError,
                              ),
                              SizedBox(width: 8),
                              Tr('Eliminar reseña'),
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
                ? Textos.t('Sin comentario escrito.')
                : resena.comentario,
            softWrap: true,
          ),
          if (resena.imagenes.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: [
                for (final url in resena.imagenes)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 100,
                          height: 100,
                          child: Icon(Icons.broken_image_outlined),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
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