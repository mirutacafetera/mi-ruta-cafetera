import 'package:flutter/material.dart';

import '../../../models/admin/admin_producto_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../actividades/dialogo_rechazo_actividad.dart';
import '../chatbot/evaluacion_ia.dart';
import '../chatbot/revision_administrador.dart';
import 'estado_producto.dart';

class TarjetaProducto extends StatelessWidget {
  final AdminProductoModel producto;
  final bool procesando;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback onEliminar;
  final ValueChanged<String>? onConfirmarRechazo;
  final VoidCallback? onVerDetalle;
  final Future<void> Function()? onActualizar;

  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.procesando,
    required this.onAprobar,
    required this.onRechazar,
    required this.onEliminar,
    this.onConfirmarRechazo,
    this.onVerDetalle,
    this.onActualizar,
  });

  static const Color _terracota = Color(0xFFB85C50);

  List<String> get _fotos => {
        if (producto.imagenPrincipal.trim().isNotEmpty)
          producto.imagenPrincipal.trim(),
        ...producto.imagenes
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim()),
      }.toList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: AppDimensions.spacingSm,
          ),
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: AppColors.adminBorder,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            color: AppColors.creamLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.5),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onVerDetalle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _imagen(
                        producto.imagenPrincipal,
                        double.infinity,
                        AppDimensions.cardImageHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimensions.spacingMd,
                          top: AppDimensions.spacingMd,
                          bottom: AppDimensions.spacingMd,
                          right: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      producto.nombre.isEmpty
                                          ? 'Producto sin nombre'
                                          : producto.nombre,
                                      softWrap: true,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: EstadoProducto(
                                      estado: producto.estadoPublicacion,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              producto.descripcion.isEmpty
                                  ? 'Sin descripción'
                                  : producto.descripcion,
                              softWrap: true,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _fila(
                              Icons.place_outlined,
                              producto.sitioNombre,
                            ),
                            _fila(
                              Icons.location_city_outlined,
                              [
                                producto.ciudad,
                                producto.departamento,
                              ].where((e) => e.isNotEmpty).join(', '),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  color: AppColors.secondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Precio: ${_precio(producto.precio)}',
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _evaluacion(),
                            const SizedBox(height: 8),
                            Text(
                              '${_fotos.length} fotografía(s). Toca para ver.',
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (producto.estaPendiente) _botones(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // EVALUACIÓN DE IA Y REVISIÓN DEL ADMINISTRADOR.
  Widget _evaluacion() {
    if (producto.tieneRevisionManual) {
      return RevisionAdministrador(
        estado: producto.estaAprobado
            ? 'aprobado_manual'
            : producto.estaRechazado
                ? 'rechazado_manual'
                : null,
        motivo: producto.motivoRechazo,
        nombreAdministrador: producto.nombreAdministrador,
        fechaRevision: producto.fechaRevisionManual,
      );
    }

    if (producto.evaluacionIAExiste) {
      return EvaluacionIA(
        decision: producto.decisionIA,
        motivo: producto.motivoIA,
        criterios: producto.criteriosIA,
        modelo: producto.modeloIA,
        fechaDecision: producto.fechaDecisionIA,
        motivoRechazo: producto.motivoRechazo,
      );
    }

    return const SizedBox.shrink();
  }

  // BOTONES DE APROBAR Y RECHAZAR.
  Widget _botones(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        0,
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: procesando
                  ? null
                  : () => mostrarDialogoRechazoAdmin(
                        context: context,
                        titulo: 'Motivo de rechazo *',
                        textoAyuda:
                            'Explica por qué se rechaza el producto...',
                        onRechazar: (motivo) {
                          if (onConfirmarRechazo != null) {
                            onConfirmarRechazo!(motivo);
                          } else {
                            onRechazar();
                          }
                        },
                      ),
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
              ),
              label: const Text('Rechazar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _terracota,
                side: const BorderSide(color: _terracota),
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.standard,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: procesando ? null : onAprobar,
              icon: const Icon(
                Icons.check_circle_outline_rounded,
                size: 20,
              ),
              label: Text(
                procesando ? 'Procesando...' : 'Aceptar',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.standard,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // IMAGEN CON BOTÓN DE ELIMINAR.
  Widget _imagen(String url, double ancho, double alto) {
    return SizedBox(
      width: ancho,
      height: alto,
      child: Stack(
        fit: StackFit.expand,
        children: [
          url.trim().isEmpty
              ? _imagenVacia()
              : Image.network(
                  url,
                  width: ancho,
                  height: alto,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _imagenVacia(),
                ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: AppColors.creamLight,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: AppColors.adminBorder,
                  width: 1.2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  tooltip: 'Eliminar producto',
                  onPressed: procesando ? null : onEliminar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: procesando
                        ? AppColors.textSecondary
                        : _terracota,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      color: AppColors.cream,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.secondary,
        size: 36,
      ),
    );
  }

  // FILAS DE INFORMACIÓN.
  Widget _fila(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto.isEmpty ? 'No especificado' : texto,
              softWrap: true,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORMATO DEL PRECIO.
  String _precio(double precio) {
    final numero = precio.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (var i = 0; i < numero.length; i++) {
      buffer.write(numero[i]);

      if (i < numero.length - 1 &&
          (numero.length - i - 1) % 3 == 0) {
        buffer.write('.');
      }
    }

    return '\$ $buffer COP';
  }
}