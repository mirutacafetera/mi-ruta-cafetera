
import 'package:flutter/material.dart';

import '../../../models/admin/sitio_admin_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class DetalleSitioTuristico extends StatelessWidget {
  final SitioAdminModel sitio;

  const DetalleSitioTuristico({
    super.key,
    required this.sitio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.adminBorder,
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _construirImagen(context),
          Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        sitio.nombre,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      sitio.activo
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_rounded,
                      color: sitio.activo
                          ? AppColors.primary
                          : AppColors.secondary,
                      size: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _etiqueta(
                      Icons.category_outlined,
                      sitio.categoria?.nombre ?? 'Sin categoría',
                      AppColors.primary,
                    ),
                    _etiqueta(
                      Icons.location_on_outlined,
                      [
                        sitio.ciudad,
                        sitio.departamento,
                      ].where((dato) => dato.trim().isNotEmpty).join(', '),
                      AppColors.coffeeLight,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _titulo('Descripción', Icons.info_outline),
                const SizedBox(height: 8),
                Text(
                  sitio.descripcion.trim().isEmpty
                      ? 'No hay descripción disponible.'
                      : sitio.descripcion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                _titulo(
                  'Información turística',
                  Icons.explore_outlined,
                ),
                const SizedBox(height: 16),
                _dato(
                  Icons.location_on_outlined,
                  'Dirección',
                  sitio.direccion,
                ),
                _dato(
                  Icons.schedule_outlined,
                  'Horario',
                  sitio.horario,
                ),
                _dato(
                  Icons.payments_outlined,
                  'Precio desde',
                  sitio.precioDesde > 0
                      ? '\$${sitio.precioDesde.toStringAsFixed(0)} COP'
                      : 'Sin costo indicado',
                ),
                _dato(
                  Icons.phone_outlined,
                  'Teléfono',
                  sitio.telefono,
                ),
                _dato(
                  Icons.email_outlined,
                  'Correo electrónico',
                  sitio.correos,
                ),
                _dato(
                  Icons.language_outlined,
                  'Sitio web',
                  sitio.sitioWeb,
                ),
                if (sitio.etiquetas.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _titulo('Etiquetas', Icons.sell_outlined),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sitio.etiquetas
                        .map(
                          (etiqueta) => _etiqueta(
                            Icons.local_offer_outlined,
                            etiqueta,
                            AppColors.secondary,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirImagen(BuildContext context) {
    final imagenUrl = sitio.imagen.trim().isNotEmpty
        ? sitio.imagen.trim()
        : sitio.imagenes
            .where((imagen) => imagen.trim().isNotEmpty)
            .firstOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.adminBorder,
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: imagenUrl == null
                ? SizedBox(
                    height: 190,
                    child: _imagenVacia(),
                  )
                : Image.network(
                    imagenUrl,
                    width: ancho,
                    fit: BoxFit.contain,
                    frameBuilder: (context, child, frame, _) {
                      if (frame == null) {
                        return const SizedBox(
                          height: 190,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      }

                      return child;
                    },
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return SizedBox(
                        height: 190,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => SizedBox(
                      height: 190,
                      child: _imagenVacia(),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String texto, IconData icono) {
    return Row(
      children: [
        Icon(
          icono,
          color: AppColors.secondary,
          size: 22,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    if (valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: AppColors.coffeeLight,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  valor,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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

  Widget _etiqueta(
    IconData icono,
    String texto,
    Color color,
  ) {
    if (texto.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.adminBorder,
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
