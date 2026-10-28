
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../models/admin/admin_contenido_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../actividades/botones_navegacion_admin.dart';
import '../actividades/componentes_detalle_actividad.dart';
import '../actividades/galeria_detalle_actividad.dart';
import '../actividades/tarjeta_principal_actividad.dart';

class DetalleContenido extends StatefulWidget {
  final AdminContenidoModel contenido;
  final AudioPlayer audio;
  final VoidCallback onVolver;
  final Future<void> Function() onActualizar;
  final VoidCallback onEditar;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
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

  @override
  State<DetalleContenido> createState() => _DetalleContenidoState();
}

class _DetalleContenidoState extends State<DetalleContenido> {
  bool _actualizando = false;

  Future<void> _actualizarDetalle() async {
    if (_actualizando) return;

    setState(() => _actualizando = true);

    try {
      await widget.onActualizar();

      if (mounted) {
        widget.onMensaje('Contenido actualizado correctamente.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error al actualizar el contenido: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        widget.onMensaje('No se pudo actualizar el contenido.');
      }
    } finally {
      if (mounted) {
        setState(() => _actualizando = false);
      }
    }
  }

  List<String> get _imagenes {
    final resultado = <String>[];
    final principal = widget.contenido.imagenPrincipal.trim();

    if (principal.isNotEmpty) {
      resultado.add(principal);
    }

    for (final imagen in widget.contenido.imagenes) {
      final url = imagen.trim();

      if (url.isNotEmpty && !resultado.contains(url)) {
        resultado.add(url);
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final imagenes = _imagenes;

    return Column(
      children: [
        _encabezado(),
        Expanded(
          child: _actualizando
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pageHorizontalSmall,
                    AppDimensions.spacingSm,
                    AppDimensions.pageHorizontalSmall,
                    AppDimensions.spacingXl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 950),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TARJETA PRINCIPAL
                          TarjetaPrincipalActividad(
                            titulo: widget.contenido.titulo.trim().isEmpty
                                ? 'Contenido sin título'
                                : widget.contenido.titulo,
                            descripcion: widget.contenido.descripcion,
                            imagenUrl:
                                imagenes.isNotEmpty ? imagenes.first : null,
                            estado: _estadoParaTarjeta(
                              widget.contenido.estadoPublicacion,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // INFORMACIÓN DEL CONTENIDO
                          TarjetaDetalleActividad(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TituloDetalleActividad(
                                    texto: 'Información del contenido',
                                    icono: Icons.description_outlined,
                                  ),
                                  const SizedBox(height: 22),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final datos = <Widget>[
                                        _dato(
                                          icono: Icons.storefront_outlined,
                                          titulo: 'Sitio turístico',
                                          valor: widget.contenido.sitioNombre,
                                        ),
                                        _dato(
                                          icono: Icons.location_city_outlined,
                                          titulo: 'Ciudad',
                                          valor: widget.contenido.ciudad,
                                        ),
                                        _dato(
                                          icono: Icons.map_outlined,
                                          titulo: 'Departamento',
                                          valor:
                                              widget.contenido.departamento,
                                        ),
                                        _dato(
                                          icono: Icons.verified_outlined,
                                          titulo: 'Estado de publicación',
                                          valor: _textoEstado(
                                            widget.contenido.estadoPublicacion,
                                          ),
                                        ),
                                        _dato(
                                          icono: Icons.event_outlined,
                                          titulo: 'Fecha de creación',
                                          valor: widget.contenido.createdAt ==
                                                  null
                                              ? 'No disponible'
                                              : FormateadorFechaActividad
                                                  .formatear(
                                                  widget.contenido.createdAt!,
                                                ),
                                        ),
                                        _dato(
                                          icono: Icons.visibility_outlined,
                                          titulo: 'Disponibilidad',
                                          valor: widget.contenido.activo
                                              ? 'Activo'
                                              : 'Inactivo',
                                        ),
                                      ];

                                      if (constraints.maxWidth >= 620) {
                                        final ancho =
                                            (constraints.maxWidth - 20) / 2;

                                        return Wrap(
                                          spacing: 20,
                                          runSpacing: 22,
                                          children: datos
                                              .map(
                                                (dato) => SizedBox(
                                                  width: ancho,
                                                  child: dato,
                                                ),
                                              )
                                              .toList(),
                                        );
                                      }

                                      return Column(
                                        children: [
                                          for (int i = 0;
                                              i < datos.length;
                                              i++) ...[
                                            datos[i],
                                            if (i < datos.length - 1)
                                              const SizedBox(height: 20),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // MOTIVO DEL RECHAZO
                          if (widget.contenido.motivoRechazo
                              .trim()
                              .isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _motivoRechazo(),
                          ],

                          // GALERÍA DE IMÁGENES
                          const SizedBox(height: 16),
                          GaleriaDetalleActividad(
                            imagenes: imagenes,
                            onMostrarGaleria: widget.onMostrarGaleria,
                          ),

                          // AUDIOGUÍAS
                          const SizedBox(height: 22),
                          const TituloDetalleActividad(
                            texto: 'Audioguías',
                            icono: Icons.headphones_rounded,
                          ),
                          const SizedBox(height: 12),

                          if (widget.contenido.audioGuias.isEmpty)
                            _vacio('No hay audioguías disponibles.')
                          else
                            ...widget.contenido.audioGuias.map(_audioguia),

                          const SizedBox(height: 24),

                          // ÚNICA ACCIÓN: ELIMINAR
                          _acciones(),

                          const SizedBox(height: AppDimensions.spacingXl),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ENCABEZADO
  Widget _encabezado() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 6,
            color: AppColors.primary,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.adminBorder.withValues(alpha: .65),
                ),
              ),
            ),
            child: Row(
              children: [
                BotonNavegacionAdmin(
                  icono: Icons.arrow_back_rounded,
                  tooltip: 'Volver',
                  onPressed: widget.onVolver,
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detalles del contenido',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Información y gestión turística',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                BotonNavegacionAdmin(
                  icono: Icons.refresh_rounded,
                  tooltip: _actualizando ? 'Actualizando...' : 'Actualizar',
                  onPressed: _actualizando ? null : _actualizarDetalle,
                ),
              ],
            ),
          ),
        ],
      );

  // DATO REUTILIZABLE
  Widget _dato({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return DatoDetalleActividad(
      ancho: double.infinity,
      icono: icono,
      titulo: titulo,
      valor: valor,
    );
  }

  // MOTIVO DEL RECHAZO
  Widget _motivoRechazo() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: const Color(0xFFB85C50).withValues(alpha: .07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFB85C50).withValues(alpha: .45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFB85C50),
                  size: 22,
                ),
                SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    'Motivo del rechazo',
                    style: TextStyle(
                      color: Color(0xFFB85C50),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              widget.contenido.motivoRechazo,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );

  // TARJETA DE AUDIOGUÍA
  Widget _audioguia(AdminAudioGuiaModel guia) => Padding(
        padding: const EdgeInsets.only(
          bottom: AppDimensions.spacingMd,
        ),
        child: TarjetaDetalleActividad(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Column(
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
                        guia.titulo.trim().isEmpty
                            ? 'Audioguía'
                            : guia.titulo,
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
                if (guia.descripcion.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    guia.descripcion,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                if (guia.duracion.trim().isNotEmpty) ...[
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

                // BOTONES DE AUDIO
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _botonAudio(
                        'Reproducir',
                        Icons.play_arrow_rounded,
                        () => _reproducir(guia.url),
                        principal: true,
                      ),
                      _botonAudio(
                        'Detener',
                        Icons.stop_rounded,
                        () => widget.audio.stop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _reproducir(String url) async {
    if (url.trim().isEmpty) {
      widget.onMensaje('Esta audioguía no tiene una URL disponible.');
      return;
    }

    try {
      await widget.audio.stop();
      await widget.audio.setUrl(url.trim());
      await widget.audio.play();
    } catch (_) {
      widget.onMensaje('No se pudo reproducir el audio.');
    }
  }

  // BOTONES DE AUDIO
  Widget _botonAudio(
    String texto,
    IconData icono,
    VoidCallback accion, {
    bool principal = false,
  }) =>
      OutlinedButton.icon(
        onPressed: accion,
        icon: Icon(icono, size: 20),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              principal ? AppColors.white : AppColors.primary,
          backgroundColor:
              principal ? AppColors.primary : AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          minimumSize: const Size(0, 42),
          visualDensity: VisualDensity.compact,
          side: BorderSide(
            color: AppColors.adminBorder,
            width: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // ESTADO SIN CONTENIDO
  Widget _vacio(String texto) => TarjetaDetalleActividad(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );

  // ÚNICO BOTÓN: ELIMINAR, SIN TARJETA
  Widget _acciones() => Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: widget.onEliminar,
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 18,
          ),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            minimumSize: const Size(0, 42),
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(
              color: AppColors.adminBorder,
              width: 1.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  String _textoEstado(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'pendiente_revision':
        return 'Pendiente de revisión';
      case 'aprobado':
      case 'aprobada':
      case 'aprobado_manual':
      case 'aprobada_manual':
        return 'Aprobado';
      case 'rechazado':
      case 'rechazada':
      case 'rechazado_manual':
      case 'rechazada_manual':
        return 'Rechazado';
      default:
        return estado.replaceAll('_', ' ');
    }
  }

  String _estadoParaTarjeta(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'aprobado':
      case 'aprobada':
      case 'aprobado_manual':
      case 'aprobada_manual':
        return 'aprobada';
      case 'rechazado':
      case 'rechazada':
      case 'rechazado_manual':
      case 'rechazada_manual':
        return 'rechazada';
      case 'pendiente':
      case 'pendiente_revision':
        return 'pendiente_revision';
      default:
        return estado;
    }
  }
}
