
import 'package:flutter/material.dart';

import '../../../models/admin/admin_producto_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../fondo_admin.dart';
import '../chatbot/evaluacion_ia.dart';
import '../chatbot/revision_administrador.dart';
import '../contenido/galeria_imagenes.dart';
import 'estado_producto.dart';

class TarjetaProducto extends StatelessWidget {
  final AdminProductoModel producto;
  final bool procesando;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final ValueChanged<String>? onConfirmarRechazo;
  final VoidCallback? onVerDetalle;

  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.procesando,
    required this.onAprobar,
    required this.onRechazar,
    this.onConfirmarRechazo,
    this.onVerDetalle,
  });

  List<String> get _fotos => {
        if (producto.imagenPrincipal.trim().isNotEmpty)
          producto.imagenPrincipal.trim(),
        ...producto.imagenes
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim()),
      }.toList();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onVerDetalle ?? () => _detalle(context),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imagen(producto.imagenPrincipal, double.infinity, 180),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          producto.nombre,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      EstadoProducto(
                        estado: producto.estadoPublicacion,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    producto.descripcion.isEmpty
                        ? 'Sin descripción'
                        : producto.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  _fila(Icons.category_outlined, producto.categoria),
                  _fila(Icons.place_outlined, producto.sitioNombre),
                  _fila(
                    Icons.location_city_outlined,
                    [producto.ciudad, producto.departamento]
                        .where((e) => e.isNotEmpty)
                        .join(', '),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Precio: ${_precio(producto.precio)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _evaluacion(),
                  const SizedBox(height: 8),
                  Text(
                    '${_fotos.length} fotografía(s). Toca para ver.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          if (producto.estaPendiente) _botones(context),
        ],
      ),
    );
  }

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

  Widget _botones(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  procesando ? null : () => _mostrarDialogoRechazo(context),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Rechazar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF9800),
                side: const BorderSide(color: Color(0xFFFF9800)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: procesando ? null : onAprobar,
              icon: const Icon(Icons.check_rounded),
              label: Text(procesando ? 'Procesando...' : 'Aceptar'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF218653),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoRechazo(BuildContext context) async {
    final controlador = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFFFCF7),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Rechazar producto',
          style: TextStyle(
            color: Color(0xFF244C36),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controlador,
          autofocus: true,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: 'Motivo del rechazo',
            hintText: 'Explica por qué se rechaza el producto...',
            filled: true,
            fillColor: const Color(0xFFFFF8EC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controlador.text.trim().length < 3) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Escribe un motivo de al menos 3 caracteres.',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, controlador.text.trim());
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar rechazo'),
          ),
        ],
      ),
    );

    controlador.dispose();

    if (motivo == null || motivo.trim().length < 3) return;

    if (onConfirmarRechazo != null) {
      onConfirmarRechazo!(motivo.trim());
    } else {
      onRechazar();
    }
  }

  void _detalle(BuildContext context) {
    final fotos = _fotos;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FondoAdmin(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: const Text(
                'Detalle del producto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    color: Color(0xFF244C36),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        [producto.ciudad, producto.departamento]
                            .where((e) => e.isNotEmpty)
                            .join(', '),
                        style: const TextStyle(
                          color: Color(0xFF655F55),
                        ),
                      ),
                    ),
                    EstadoProducto(
                      estado: producto.estadoPublicacion,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _panel('PRECIO DEL PRODUCTO', _precio(producto.precio)),
                const SizedBox(height: 22),
                _seccion('Descripción', producto.descripcion),
                const SizedBox(height: 18),
                const Text(
                  'Información del producto',
                  style: TextStyle(
                    color: Color(0xFF244C36),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _informacion(
                  Icons.category_outlined,
                  'Categoría',
                  producto.categoria,
                ),
                _informacion(
                  Icons.storefront_outlined,
                  'Sitio turístico',
                  producto.sitioNombre,
                ),
                _informacion(
                  Icons.check_circle_outline,
                  'Disponibilidad',
                  producto.activo ? 'Activo' : 'Inactivo',
                ),
                _informacion(
                  Icons.calendar_month_outlined,
                  'Fecha de creación',
                  _fecha(producto.createdAt),
                ),
                const SizedBox(height: 20),
                _evaluacion(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Fotografías',
                        style: TextStyle(
                          color: Color(0xFF244C36),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${fotos.length} imágenes',
                      style: const TextStyle(
                        color: Color(0xFF655F55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (fotos.isEmpty)
                  const Text(
                    'No hay fotografías disponibles.',
                    style: TextStyle(color: Color(0xFF655F55)),
                  )
                else
                  SizedBox(
                    height: 125,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: fotos.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 12),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => GaleriaImagenes.mostrar(ctx, fotos, i),
                        child: _imagen(fotos[i], 125, 125),
                      ),
                    ),
                  ),
                if (producto.estaPendiente) ...[
                  const SizedBox(height: 26),
                  _botones(ctx),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagen(String url, double ancho, double alto) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: url.trim().isEmpty
            ? _imagenVacia(ancho, alto)
            : Image.network(
                url,
                width: ancho,
                height: alto,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imagenVacia(ancho, alto),
              ),
      );

  Widget _imagenVacia(double ancho, double alto) => Container(
        width: ancho,
        height: alto,
        color: const Color(0xFFFFF8EC),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFFFF9800),
          size: 36,
        ),
      );

  Widget _fila(IconData icono, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icono, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto.isEmpty ? 'No especificado' : texto,
              ),
            ),
          ],
        ),
      );

  Widget _seccion(String titulo, String contenido) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFFB86B00),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contenido.isEmpty ? 'Sin información disponible' : contenido,
            style: const TextStyle(
              color: Color(0xFF655F55),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      );

  Widget _panel(String titulo, String valor) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xEFFFFFF7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF9800).withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF655F55),
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                color: Color(0xFFFF9800),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _informacion(
    IconData icono,
    String titulo,
    String contenido,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xEFFFFFF7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: const Color(0xFFFF9800),
              size: 23,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Color(0xFF655F55),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contenido.isEmpty ? 'No disponible' : contenido,
                    style: const TextStyle(
                      color: Color(0xFF244C36),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

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

  String _fecha(DateTime? fecha) => fecha == null
      ? 'No disponible'
      : '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
}
