
import 'package:flutter/material.dart';

import '../../../../models/admin/admin_contenido_model.dart';
import '../../../../theme/app_colors.dart';
import '../chatbot/evaluacion_ia.dart';
import '../chatbot/revision_administrador.dart';

class TarjetaContenido extends StatelessWidget {
  final AdminContenidoModel contenido;
  final VoidCallback onVer;
  final VoidCallback onEditar;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback? onSeleccionar;
  final bool procesando;
  final bool seleccionado;

  const TarjetaContenido({
    super.key,
    required this.contenido,
    required this.onVer,
    required this.onEditar,
    required this.onCambiarEstado,
    required this.onEliminar,
    required this.onAprobar,
    required this.onRechazar,
    this.onSeleccionar,
    this.procesando = false,
    this.seleccionado = false,
  });

  static const _fondo = AppColors.creamLight;
  static const _beige = Color(0xFFF4F0E8);
  static const _borde = AppColors.adminBorder;
  static const _terracota = Color(0xFFB85C50);
  static const _naranjaSuave = Color(0xFFFFEBDD);

  @override
  Widget build(BuildContext context) {
    final estado = contenido.estadoPublicacion;
    final pendiente = contenido.estaPendiente;

    final imagenes = contenido.imagenes.length +
        (contenido.imagenPrincipal.trim().isNotEmpty ? 1 : 0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          color: _fondo,
          surfaceTintColor: Colors.transparent,
          elevation: seleccionado ? 3 : 1,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
            side: BorderSide(
              color: seleccionado ? AppColors.primary : _borde,
              width: 1.4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onSeleccionar ?? onVer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _imagen(contenido.imagenPrincipal.trim()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  contenido.titulo.isEmpty
                                      ? 'Contenido sin título'
                                      : contenido.titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: _estado(estado),
                                ),
                              ),
                            ],
                          ),
                          if (contenido.descripcion.isNotEmpty) ...[
                            const SizedBox(height: 11),
                            Text(
                              contenido.descripcion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                          if (contenido.sitioNombre.isNotEmpty ||
                              contenido.ciudad.isNotEmpty ||
                              contenido.departamento.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            if (contenido.sitioNombre.isNotEmpty)
                              _fila(
                                Icons.storefront_outlined,
                                contenido.sitioNombre,
                              ),
                            if (contenido.ciudad.isNotEmpty ||
                                contenido.departamento.isNotEmpty) ...[
                              if (contenido.sitioNombre.isNotEmpty)
                                const SizedBox(height: 7),
                              _fila(
                                Icons.location_on_outlined,
                                [
                                  contenido.ciudad,
                                  contenido.departamento,
                                ]
                                    .where((v) => v.trim().isNotEmpty)
                                    .join(', '),
                              ),
                            ],
                          ],
                          const SizedBox(height: 13),
                          Wrap(
                            spacing: 8,
                            runSpacing: 7,
                            children: [
                              _dato(
                                Icons.photo_library_outlined,
                                '$imagenes imágenes',
                              ),
                              _dato(
                                Icons.headphones_rounded,
                                '${contenido.audioGuias.length} audioguías',
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _revision(),
                          if (estado == 'rechazado' &&
                              contenido.motivoRechazo.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _terracota.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _terracota.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                'Motivo del rechazo\n'
                                '${contenido.motivoRechazo}',
                                style: const TextStyle(
                                  color: _terracota,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          if (contenido.createdAt != null) ...[
                            const SizedBox(height: 13),
                            Container(
                              height: 1,
                              color: _borde.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 12),
                            _fila(
                              Icons.calendar_today_outlined,
                              'Creado el ${_fecha(contenido.createdAt!)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (pendiente)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: procesando ? null : onRechazar,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                          ),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _terracota,
                            side: const BorderSide(
                              color: _terracota,
                              width: 1.2,
                            ),
                            minimumSize: const Size.fromHeight(42),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: procesando ? null : onAprobar,
                          icon: const Icon(
                            Icons.check_rounded,
                            size: 20,
                          ),
                          label: const Text('Aceptar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size.fromHeight(42),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (procesando)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.secondary,
                  backgroundColor: _naranjaSuave,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _revision() {
    if (contenido.tieneRevisionManual) {
      return RevisionAdministrador(
        estado: contenido.estaAprobado
            ? 'aprobado_manual'
            : contenido.estaRechazado
                ? 'rechazado_manual'
                : null,
        motivo: contenido.motivoRechazo,
        nombreAdministrador: contenido.nombreAdministrador,
        fechaRevision: contenido.fechaRevisionManual,
      );
    }

    if (contenido.evaluacionIAExiste) {
      return EvaluacionIA(
        decision: contenido.decisionIA,
        motivo: contenido.motivoIA,
        criterios: contenido.criteriosIA,
        modelo: contenido.modeloIA,
        fechaDecision: contenido.fechaDecisionIA,
        motivoRechazo: contenido.motivoRechazo,
      );
    }

    return const SizedBox.shrink();
  }

  // Imagen con el botón de eliminar en la esquina superior derecha.
  Widget _imagen(String url) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isEmpty)
            Container(
              color: _beige,
              alignment: Alignment.center,
              child: const Icon(
                Icons.photo_outlined,
                color: AppColors.secondary,
                size: 32,
              ),
            )
          else
            Image.network(
              url,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: _beige,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.secondary,
                  size: 32,
                ),
              ),
            ),

          // BOTÓN FLOTANTE DE ELIMINAR
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: _fondo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: _borde,
                  width: 1,
                ),
              ),
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                tooltip: 'Eliminar contenido',
                onPressed: procesando ? null : onEliminar,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: _terracota,
                  size: 22,
                ),
                iconSize: 22,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estado(String estado) {
    final Color color;
    final String texto;

    switch (estado.toLowerCase()) {
      case 'pendiente_revision':
        color = AppColors.secondary;
        texto = 'Pendiente de revisión';
        break;
      case 'aprobado':
        color = AppColors.primary;
        texto = 'Aprobado';
        break;
      case 'rechazado':
        color = _terracota;
        texto = 'Rechazado';
        break;
      default:
        color = AppColors.textSecondary;
        texto = estado.isEmpty
            ? 'Sin estado'
            : '${estado[0].toUpperCase()}${estado.substring(1)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _fila(
    IconData icono,
    String texto, {
    Color color = AppColors.secondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dato(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _borde,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 15,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _fecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';
}
