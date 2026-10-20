import 'package:flutter/material.dart';

import '../../../models/admin/admin_producto_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../contenido/galeria_imagenes.dart';
import 'estado_producto.dart';

class TarjetaProducto extends StatelessWidget {
  final AdminProductoModel producto;
  final bool procesando;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback? onVerDetalle;

  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.procesando,
    required this.onAprobar,
    required this.onRechazar,
    this.onVerDetalle,
  });

  List<String> get _fotos => <String>{
        if (producto.imagenPrincipal.trim().isNotEmpty)
          producto.imagenPrincipal.trim(),
        ...producto.imagenes
            .where((url) => url.trim().isNotEmpty)
            .map((url) => url.trim()),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      EstadoProducto(estado: producto.estadoPublicacion),
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
                    [
                      producto.ciudad,
                      producto.departamento,
                    ].where((e) => e.isNotEmpty).join(', '),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Precio: ${_precio(producto.precio)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${_fotos.length} fotografía(s). Toca para ver.'),
                  if (producto.motivoRechazo.isNotEmpty)
                    Text(
                      'Motivo: ${producto.motivoRechazo}',
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          if (producto.estaPendiente)
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
                    child: FilledButton(
                      onPressed: procesando ? null : onAprobar,
                      child: Text(procesando ? 'Procesando...' : 'Aprobar'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _detalle(BuildContext context) {
    final fotos = _fotos;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: const Color(0xFF101411),
          appBar: AppBar(
            backgroundColor: const Color(0xFF174D36),
            foregroundColor: Colors.white,
            title: const Text(
              'Detalle del producto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _imagen(producto.imagenPrincipal, double.infinity, 220),
              ),
              const SizedBox(height: 20),
              Text(
                producto.nombre,
                style: const TextStyle(
                  color: Colors.white,
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
                    size: 19,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      [
                        producto.ciudad,
                        producto.departamento,
                      ].where((e) => e.isNotEmpty).join(', '),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  EstadoProducto(estado: producto.estadoPublicacion),
                ],
              ),
              const SizedBox(height: 18),
              _panel(
                'PRECIO DEL PRODUCTO',
                _precio(producto.precio),
              ),
              const SizedBox(height: 22),
              _seccion('Descripción', producto.descripcion),
              const SizedBox(height: 18),
              const Text(
                'Información del producto',
                style: TextStyle(
                  color: Colors.white,
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
              if (producto.motivoRechazo.isNotEmpty) ...[
                const SizedBox(height: 12),
                _seccion('Motivo del rechazo', producto.motivoRechazo),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Fotografías',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${fotos.length} imágenes',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (fotos.isEmpty)
                const Text(
                  'No hay fotografías disponibles.',
                  style: TextStyle(color: Colors.white70),
                )
              else
                SizedBox(
                  height: 125,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: fotos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => GaleriaImagenes.mostrar(ctx, fotos, i),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _imagen(fotos[i], 125, 125),
                      ),
                    ),
                  ),
                ),
              if (producto.estaPendiente) ...[
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: procesando ? null : onRechazar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF9800),
                          side: const BorderSide(color: Color(0xFFFF9800)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: procesando ? null : onAprobar,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF218653),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          procesando ? 'Procesando...' : 'Aprobar',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagen(String url, double ancho, double alto) {
    return ClipRRect(
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
  }

  Widget _imagenVacia(double ancho, double alto) {
    return Container(
      width: ancho,
      height: alto,
      color: const Color(0xFF1D2921),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFFFF9800),
        size: 36,
      ),
    );
  }

  Widget _fila(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto.isEmpty ? 'No especificado' : texto),
          ),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, String contenido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFFFF9800),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          contenido.isEmpty ? 'Sin información disponible' : contenido,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _panel(String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2921),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
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
  }

  Widget _informacion(IconData icono, String titulo, String contenido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2921),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icono, color: const Color(0xFFFF9800), size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contenido.isEmpty ? 'No disponible' : contenido,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _precio(double precio) {
    final numero = precio.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (var i = 0; i < numero.length; i++) {
      buffer.write(numero[i]);
      final restantes = numero.length - i - 1;
      if (restantes > 0 && restantes % 3 == 0) buffer.write('.');
    }

    return '\$ $buffer COP';
  }

  String _fecha(DateTime? fecha) {
    if (fecha == null) return 'No disponible';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}