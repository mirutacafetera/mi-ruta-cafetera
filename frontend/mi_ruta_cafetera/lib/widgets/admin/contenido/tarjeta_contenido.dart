import 'package:flutter/material.dart';
import '../../../../models/admin/admin_contenido_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../producto/estado_producto.dart';

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

  @override
  Widget build(BuildContext context) {
    final estado = contenido.estadoPublicacion;
    final pendiente = estado == 'pendiente_revision';
    final aprobado = estado == 'aprobado';

    final totalImagenes = contenido.imagenes.length +
        (contenido.imagenPrincipal.trim().isNotEmpty ? 1 : 0);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      elevation: seleccionado ? 3 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: seleccionado
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onSeleccionar ?? onVer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagen(contenido.imagenPrincipal.trim()),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          EstadoProducto(estado: estado),
                          if (aprobado)
                            PopupMenuButton<String>(
                              enabled: !procesando,
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
                                  'editar',
                                  'Editar',
                                  Icons.edit_outlined,
                                ),
                                _opcion(
                                  'estado',
                                  contenido.activo ? 'Desactivar' : 'Activar',
                                  contenido.activo
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                _opcion(
                                  'eliminar',
                                  'Eliminar',
                                  Icons.delete_outline,
                                  rojo: true,
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        contenido.descripcion.isEmpty
                            ? 'Sin descripción'
                            : contenido.descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      if (contenido.sitioNombre.isNotEmpty) _filaSitio(),
                      if (contenido.ciudad.isNotEmpty ||
                          contenido.departamento.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        _fila(
                          Icons.location_city_outlined,
                          [
                            contenido.ciudad,
                            contenido.departamento,
                          ]
                              .where((dato) => dato.trim().isNotEmpty)
                              .join(', '),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.spacingMd),
                      Wrap(
                        spacing: AppDimensions.spacingSm,
                        runSpacing: AppDimensions.spacingXs,
                        children: [
                          _etiqueta(
                            Icons.photo_library_outlined,
                            '$totalImagenes imágenes',
                          ),
                          _etiqueta(
                            Icons.headphones_outlined,
                            '${contenido.audioGuias.length} audios',
                          ),
                        ],
                      ),
                      if (estado == 'rechazado' &&
                          contenido.motivoRechazo.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingMd),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Motivo del rechazo: ${contenido.motivoRechazo}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      if (contenido.createdAt != null) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                if (pendiente)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: procesando ? null : onRechazar,
                          icon: const Icon(Icons.close),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: procesando ? null : onAprobar,
                          icon: const Icon(Icons.check),
                          label: const Text('Aprobar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (procesando) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaSitio() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.place_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              contenido.sitioNombre,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _opcion(
    String valor,
    String texto,
    IconData icono, {
    bool rojo = false,
  }) {
    return PopupMenuItem<String>(
      value: valor,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icono,
          color: rojo ? Colors.red : null,
        ),
        title: Text(
          texto,
          style: TextStyle(
            color: rojo ? Colors.red : null,
          ),
        ),
      ),
    );
  }

  Widget _imagen(String url) {
    if (url.isEmpty) return _imagenVacia();

    return Image.network(
      url,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stack) => _imagenVacia(),
    );
  }

  Widget _imagenVacia() {
    return Container(
      height: 150,
      width: double.infinity,
      alignment: Alignment.center,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _fila(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icono,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _fecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}