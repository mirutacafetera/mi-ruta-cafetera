import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../models/admin/admin_contenido_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class DetalleContenido extends StatelessWidget {
  final AdminContenidoModel contenido;
  final AudioPlayer audio;
  final VoidCallback onVolver, onActualizar, onEditar;
  final VoidCallback onCambiarEstado, onEliminar, onAprobar, onRechazar;
  final Function(List<String>, int) onMostrarGaleria;
  final Function(String) onMensaje;

  const DetalleContenido({
    super.key,
    required this.contenido,
    required this.audio,
    required this.onVolver,
    required this.onActualizar,
    required this.onEditar,
    required this.onCambiarEstado,
    required this.onEliminar,
    required this.onAprobar,
    required this.onRechazar,
    required this.onMostrarGaleria,
    required this.onMensaje,
  });

  bool get _pendiente =>
      contenido.estadoPublicacion == 'pendiente_revision';

  Color get _colorEstado => _pendiente
      ? AppColors.secondary
      : contenido.activo
          ? AppColors.success
          : AppColors.error;

  @override
  Widget build(BuildContext context) {
    final datos = [
      ('Descripción', contenido.descripcion, Icons.notes_rounded),
      ('Sitio turístico', contenido.sitioNombre, Icons.place_outlined),
      ('Ciudad', contenido.ciudad, Icons.location_city_outlined),
      ('Departamento', contenido.departamento, Icons.map_outlined),
      (
        'Estado de publicación',
        contenido.estadoPublicacion.replaceAll('_', ' '),
        Icons.verified_outlined,
      ),
    ];

    return Column(
      children: [
        _barra(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 45),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 950),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _encabezado(),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _tituloSeccion('Información general', Icons.info_outline),
                    _tarjeta(
                      Column(
                        children: [
                          for (int i = 0; i < datos.length; i++) ...[
                            _dato(datos[i].$1, datos[i].$2, datos[i].$3),
                            if (i < datos.length - 1) _separador(),
                          ],
                        ],
                      ),
                    ),
                    if (contenido.motivoRechazo.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingLg),
                      _motivoRechazo(),
                    ],
                    const SizedBox(height: AppDimensions.spacingXl),
                    _tituloSeccion('Audioguías', Icons.headphones_rounded),
                    const SizedBox(height: AppDimensions.spacingSm),
                    if (contenido.audioGuias.isEmpty)
                      _vacio('No hay audioguías disponibles.')
                    else
                      ...contenido.audioGuias.map(_audioguia),
                    const SizedBox(height: AppDimensions.spacingLg),
                    _acciones(),
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _barra() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.adminBorder),
          ),
        ),
        child: Row(
          children: [
            _icono(Icons.arrow_back_rounded, onVolver),
            const SizedBox(width: AppDimensions.spacingSm),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalle del contenido',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Información y gestión turística',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _Actualizar(onActualizar: onActualizar),
          ],
        ),
      );

  Widget _icono(IconData icono, VoidCallback accion) => IconButton(
        onPressed: accion,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.secondary,
          backgroundColor: AppColors.orangeSoft,
        ),
        icon: Icon(icono),
      );

  Widget _encabezado() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.landscape_rounded,
              color: AppColors.secondary,
              size: 32,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              contenido.titulo.isEmpty
                  ? 'Contenido sin título'
                  : contenido.titulo,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _etiqueta(
              contenido.estadoPublicacion.replaceAll('_', ' '),
              _colorEstado,
              _pendiente
                  ? Icons.hourglass_top_rounded
                  : contenido.activo
                      ? Icons.check_circle_outline
                      : Icons.visibility_off_outlined,
            ),
          ],
        ),
      );

  Widget _tituloSeccion(String titulo, IconData icono) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.adminBorder),
              ),
              child: Icon(icono, color: AppColors.secondary),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  Widget _tarjeta(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.adminBorder, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: AppColors.coffeeDark.withValues(alpha: 0.05),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  Widget _separador() => const Divider(
        height: 1,
        thickness: 0.7,
        color: AppColors.divider,
      );

  Widget _dato(String titulo, String valor, IconData icono) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: AppDimensions.spacingMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: AppColors.secondary, size: 21),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    valor.trim().isEmpty ? 'No disponible' : valor,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _motivoRechazo() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.error),
                SizedBox(width: AppDimensions.spacingSm),
                Text(
                  'Motivo del rechazo',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              contenido.motivoRechazo,
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      );

  Widget _audioguia(AdminAudioGuiaModel guia) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
        child: _tarjeta(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.orangeSoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      guia.titulo.isEmpty ? 'Audioguía' : guia.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              if (guia.descripcion.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  guia.descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (guia.duracion.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Duración: ${guia.duracion}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _botonAudio(
                    'Reproducir',
                    Icons.play_arrow_rounded,
                    () => _reproducir(guia.url),
                    principal: true,
                  ),
                  _botonAudio('Pausar', Icons.pause_rounded, audio.pause),
                  _botonAudio('Detener', Icons.stop_rounded, audio.stop),
                ],
              ),
            ],
          ),
        ),
      );

  Future<void> _reproducir(String url) async {
    if (url.trim().isEmpty) {
      onMensaje('Esta audioguía no tiene una URL disponible.');
      return;
    }

    try {
      await audio.stop();
      await audio.setUrl(url.trim());
      await audio.play();
    } catch (_) {
      onMensaje('No se pudo reproducir el audio.');
    }
  }

  Widget _botonAudio(
    String texto,
    IconData icono,
    VoidCallback accion, {
    bool principal = false,
  }) =>
      OutlinedButton.icon(
        onPressed: accion,
        icon: Icon(icono, size: 17),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor: principal ? AppColors.white : AppColors.primary,
          backgroundColor: principal ? AppColors.primary : AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          minimumSize: const Size(0, 42),
          visualDensity: VisualDensity.compact,
          side: const BorderSide(color: AppColors.adminBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

  Widget _acciones() {
    final botones = _pendiente
        ? [
            _boton(
              'Aprobar',
              Icons.check_rounded,
              onAprobar,
              AppColors.success,
              principal: true,
            ),
            _boton(
              'Rechazar',
              Icons.close_rounded,
              onRechazar,
              AppColors.error,
            ),
          ]
        : [
            _boton('Editar', Icons.edit_outlined, onEditar, AppColors.primary),
            _boton(
              contenido.activo ? 'Desactivar' : 'Activar',
              contenido.activo
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onCambiarEstado,
              AppColors.secondary,
            ),
            _boton(
              'Eliminar',
              Icons.delete_outline,
              onEliminar,
              AppColors.error,
            ),
          ];

    return _tarjeta(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones disponibles',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Administra el contenido desde aquí.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: botones,
          ),
        ],
      ),
    );
  }

  Widget _boton(
    String texto,
    IconData icono,
    VoidCallback accion,
    Color color, {
    bool principal = false,
  }) =>
      OutlinedButton.icon(
        onPressed: accion,
        icon: Icon(icono, size: 17),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor: principal ? AppColors.white : color,
          backgroundColor: principal ? color : AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          minimumSize: const Size(0, 42),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(
            color: AppColors.adminBorder,
            width: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

  Widget _etiqueta(String texto, Color color, IconData icono) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: AppColors.white, size: AppDimensions.iconSm),
            const SizedBox(width: AppDimensions.spacingSm),
            Flexible(
              child: Text(
                texto,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _vacio(String texto) => _tarjeta(
        Column(
          children: [
            const Icon(
              Icons.headphones_outlined,
              color: AppColors.secondary,
              size: 36,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}

class _Actualizar extends StatefulWidget {
  final VoidCallback onActualizar;

  const _Actualizar({required this.onActualizar});

  @override
  State<_Actualizar> createState() => _ActualizarState();
}

class _ActualizarState extends State<_Actualizar> {
  bool cargando = false;

  Future<void> _actualizar() async {
    if (cargando) return;
    setState(() => cargando = true);

    try {
      widget.onActualizar();
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: cargando ? 'Actualizando...' : 'Actualizar',
        onPressed: cargando ? null : _actualizar,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.secondary,
          backgroundColor: AppColors.orangeSoft,
        ),
        icon: cargando
            ? const SizedBox(
                width: AppDimensions.iconSm,
                height: AppDimensions.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            : const Icon(Icons.refresh_rounded),
      );
}