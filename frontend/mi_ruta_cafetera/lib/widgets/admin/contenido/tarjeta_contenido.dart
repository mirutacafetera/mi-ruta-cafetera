
import 'package:flutter/material.dart';

import '../../../../models/admin/admin_contenido_model.dart';
import '../../../../theme/app_colors.dart';
import '../chatbot/evaluacion_ia.dart';
import '../chatbot/revision_administrador.dart';

class TarjetaContenido extends StatelessWidget {
  final AdminContenidoModel contenido;
  final VoidCallback onVer, onEditar, onCambiarEstado, onEliminar;
  final VoidCallback onAprobar, onRechazar;
  final VoidCallback? onSeleccionar;
  final bool procesando, seleccionado;

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

  static const _fondo = Color(0xFFFFFCF7);
  static const _beige = Color(0xFFF4F0E8);
  static const _borde = Color(0xFFB58A70);
  static const _verdeMenu = Color(0xFFE8EEE7);
  static const _verdeTexto = Color(0xFF293D32);
  static const _rojo = Color(0xFFD94B45);
  static const _naranjaSuave = Color(0xFFFFEBDD);

  @override
  Widget build(BuildContext context) {
    final estado = contenido.estadoPublicacion;
    final pendiente = contenido.estaPendiente;
    final imagenes = contenido.imagenes.length +
        (contenido.imagenPrincipal.trim().isNotEmpty ? 1 : 0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 19, vertical: 8),
      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _borde, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF493326).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(20, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onSeleccionar ?? onVer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagen(contenido.imagenPrincipal.trim()),
                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          _menu(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _estado(estado),
                      if (contenido.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(
                          contenido.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (contenido.sitioNombre.isNotEmpty ||
                          contenido.ciudad.isNotEmpty ||
                          contenido.departamento.isNotEmpty) ...[
                        const SizedBox(height: 11),
                        if (contenido.sitioNombre.isNotEmpty)
                          _fila(
                            Icons.storefront_outlined,
                            contenido.sitioNombre,
                          ),
                        if (contenido.ciudad.isNotEmpty ||
                            contenido.departamento.isNotEmpty) ...[
                          if (contenido.sitioNombre.isNotEmpty)
                            const SizedBox(height: 5),
                          _fila(
                            Icons.location_on_outlined,
                            [
                              contenido.ciudad,
                              contenido.departamento,
                            ].where((v) => v.trim().isNotEmpty).join(', '),
                          ),
                        ],
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 13,
                        runSpacing: 6,
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
                      const SizedBox(height: 12),
                      _revision(),
                      if (estado == 'rechazado' &&
                          contenido.motivoRechazo.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'Motivo del rechazo\n${contenido.motivoRechazo}',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      if (contenido.createdAt != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 1,
                          color: _borde.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 10),
                        _fila(
                          Icons.calendar_today_outlined,
                          'Creado el ${_fecha(contenido.createdAt!)}',
                          color: const Color(0xFF948779),
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
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: procesando ? null : onRechazar,
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: procesando ? null : onAprobar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aceptar'),
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

  Widget _imagen(String url) => Stack(
        children: [
          SizedBox(
            height: 115,
            width: double.infinity,
            child: url.isEmpty
                ? Container(
                    color: _beige,
                    child: const Icon(
                      Icons.photo_outlined,
                      color: AppColors.secondary,
                    ),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: _beige,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
          ),
          Positioned(
            left: 10,
            bottom: 9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: _fondo.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _borde.withValues(alpha: 0.6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: AppColors.secondary,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Contenido turístico',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _menu() => PopupMenuButton<String>(
        enabled: !procesando,
        tooltip: 'Más opciones',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 185, maxWidth: 205),
        offset: const Offset(-8, 4),
        color: _verdeMenu,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
        shadowColor: _verdeTexto.withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
          side: const BorderSide(color: Color(0xFFD7E1D5)),
        ),
        icon: const Icon(
          Icons.more_vert_rounded,
          color: AppColors.secondary,
          size: 23,
        ),
        onSelected: (opcion) {
          switch (opcion) {
            case 'ver':
              onVer();
              break;
            case 'editar':
              onEditar();
              break;
            case 'estado':
              onCambiarEstado();
              break;
            case 'eliminar':
              onEliminar();
              break;
          }
        },
        itemBuilder: (_) => [
          _opcion(
            'ver',
            'Ver detalles',
            Icons.visibility_outlined,
            const Color(0xFF3478A5),
          ),
          _opcion(
            'editar',
            'Editar contenido',
            Icons.edit_outlined,
            const Color(0xFFB87924),
          ),
          _opcion(
            'estado',
            contenido.activo ? 'Desactivar' : 'Activar',
            contenido.activo
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            const Color(0xFF47805A),
          ),
          _opcion(
            'eliminar',
            'Eliminar contenido',
            Icons.delete_outline_rounded,
            _rojo,
          ),
        ],
      );

  PopupMenuItem<String> _opcion(
    String valor,
    String texto,
    IconData icono,
    Color color,
  ) =>
      PopupMenuItem(
        value: valor,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Row(
          children: [
            Icon(icono, size: 19, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  color: valor == 'eliminar' ? _rojo : _verdeTexto,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _estado(String estado) {
    final color = estado == 'aprobado'
        ? const Color(0xFF477A50)
        : estado == 'pendiente_revision'
            ? AppColors.secondary
            : AppColors.error;

    final texto = estado == 'pendiente_revision'
        ? 'Pendiente de revisión'
        : estado.isEmpty
            ? 'Sin estado'
            : '${estado[0].toUpperCase()}${estado.substring(1)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(
    IconData icono,
    String texto, {
    Color color = AppColors.secondary,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 16, color: color),
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

  Widget _dato(IconData icono, String texto) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: AppColors.secondary),
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
      );

  String _fecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';
}
