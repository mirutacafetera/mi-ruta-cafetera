import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../models/admin/admin_contenido_model.dart';
import '../../../theme/app_colors.dart';

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

  static const _borde = Color(0xFFB58A70);
  static const _vainilla = Color(0xFFFFFCF7);

  @override
  Widget build(BuildContext context) {
    final pendiente =
        contenido.estadoPublicacion == 'pendiente_revision';

    return Column(
      children: [
        _barra(),
        Expanded(
          child: Container(
            color: const Color(0xFFF4F0E8),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.creamLight,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _borde),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _encabezado(),
                    const SizedBox(height: 24),
                    _seccion('Información general', Icons.info_outline),
                    const SizedBox(height: 16),
                    _dato('Descripción', contenido.descripcion, Icons.notes),
                    _dato('Sitio turístico', contenido.sitioNombre, Icons.place_outlined),
                    _dato('Ciudad', contenido.ciudad, Icons.location_city),
                    _dato('Departamento', contenido.departamento, Icons.map_outlined),
                    _dato(
                      'Estado de publicación',
                      contenido.estadoPublicacion.replaceAll('_', ' '),
                      Icons.verified_outlined,
                    ),
                    if (contenido.motivoRechazo.isNotEmpty)
                      _dato('Motivo del rechazo', contenido.motivoRechazo, Icons.warning_amber),
                    _separador(),
                    _seccion('Audioguías', Icons.headphones),
                    const SizedBox(height: 14),
                    if (contenido.audioGuias.isEmpty)
                      _vacio('No hay audioguías disponibles.')
                    else
                      ...contenido.audioGuias.map(_audioguia),
                    _separador(),
                    _acciones(pendiente),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.creamLight,
          border: Border(bottom: BorderSide(color: _borde)),
        ),
        child: Row(
          children: [
            _icono(Icons.arrow_back, onVolver),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Detalles del contenido',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
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
          backgroundColor: AppColors.secondary.withValues(alpha: 0.09),
        ),
        icon: Icon(icono),
      );

  Widget _encabezado() {
    final pendiente = contenido.estadoPublicacion == 'pendiente_revision';
    final color = pendiente
        ? AppColors.secondary
        : contenido.activo
            ? AppColors.success
            : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EBDD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contenido.titulo.isEmpty ? 'Contenido sin título' : contenido.titulo,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _etiqueta(
            contenido.estadoPublicacion.replaceAll('_', ' '),
            color,
            pendiente ? Icons.hourglass_top : Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, IconData icono) => Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D6),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icono, color: AppColors.secondary, size: 23),
          ),
          const SizedBox(width: 12),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );

  Widget _dato(String titulo, String valor, IconData icono) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _vainilla,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _borde.withValues(alpha: 0.38)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: AppColors.secondary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icono, size: 17, color: AppColors.secondary),
                            const SizedBox(width: 7),
                            Text(
                              titulo,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          valor.trim().isEmpty ? 'No disponible' : valor,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _audioguia(AdminAudioGuiaModel guia) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _vainilla,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _borde.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              guia.titulo.isEmpty ? 'Audioguía' : guia.titulo,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (guia.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(guia.descripcion),
            ],
            if (guia.duracion.isNotEmpty)
              Text('Duración: ${guia.duracion}'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _audioBoton(Icons.play_arrow, () async {
                  if (guia.url.trim().isEmpty) {
                    onMensaje('Esta audioguía no tiene una URL disponible.');
                    return;
                  }
                  try {
                    await audio.stop();
                    await audio.setUrl(guia.url.trim());
                    await audio.play();
                  } catch (_) {
                    onMensaje('No se pudo reproducir el audio.');
                  }
                }),
                _audioBoton(Icons.pause, () => audio.pause()),
                _audioBoton(Icons.stop, () => audio.stop()),
              ],
            ),
          ],
        ),
      );

  Widget _audioBoton(IconData icono, VoidCallback accion) => IconButton(
        onPressed: accion,
        color: AppColors.secondary,
        icon: Icon(icono),
      );

  Widget _acciones(bool pendiente) {
    final botones = pendiente
        ? [
            _boton('Aprobar', Icons.check_circle_outline, onAprobar, AppColors.success),
            _boton('Rechazar', Icons.cancel_outlined, onRechazar, AppColors.error),
          ]
        : [
            _boton('Editar', Icons.edit_outlined, onEditar, AppColors.primary),
            _boton(
              contenido.activo ? 'Desactivar' : 'Activar',
              contenido.activo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              onCambiarEstado,
              AppColors.secondary,
            ),
            _boton('Eliminar', Icons.delete_outline, onEliminar, AppColors.error),
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: botones,
    );
  }

  Widget _boton(String texto, IconData icono, VoidCallback accion, Color color) =>
      OutlinedButton.icon(
        onPressed: accion,
        icon: Icon(icono, size: 17),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.55)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _etiqueta(String texto, Color color, IconData icono) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: color, size: 17),
            const SizedBox(width: 7),
            Text(texto, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ],
        ),
      );

  Widget _vacio(String texto) => Padding(
        padding: const EdgeInsets.all(18),
        child: Center(child: Text(texto)),
      );

  Widget _separador() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(height: 1, color: _borde.withValues(alpha: 0.45)),
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
      await Future<void>.delayed(const Duration(milliseconds: 900));
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
          backgroundColor: AppColors.secondary.withValues(alpha: 0.09),
        ),
        icon: cargando
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.secondary,
                ),
              )
            : const Icon(Icons.refresh_rounded),
      );
}