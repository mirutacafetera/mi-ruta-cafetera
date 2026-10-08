import 'package:flutter/material.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaContenidoSitio extends StatelessWidget {
  final SitioContenidoModel contenido;
  final VoidCallback onEditar;
  final VoidCallback onEnviarRevision;
  final VoidCallback onCambiarEstado;

  const TarjetaContenidoSitio({
    super.key,
    required this.contenido,
    required this.onEditar,
    required this.onEnviarRevision,
    required this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final estado = contenido.estadoPublicacion;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(
              alpha: 0.08,
            ),
            blurRadius: AppDimensions.elevationFloating * 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirEncabezado(),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            _construirRecursos(),
            if (contenido.motivoRechazo.isNotEmpty &&
                estado == 'rechazado') ...[
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              _construirMotivoRechazo(),
            ],
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            _construirAcciones(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget _construirEncabezado() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 560;

        if (esMovil) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirImagenPrincipal(),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              _construirInformacion(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirImagenPrincipal(),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: _construirInformacion(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // INFORMACIÓN
  // ============================================================

  Widget _construirInformacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contenido.titulo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingSm,
        ),
        Text(
          contenido.descripcion,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        _construirEstadoChip(
          contenido.estadoPublicacion,
        ),
      ],
    );
  }

  // ============================================================
  // IMAGEN PRINCIPAL
  // ============================================================

  Widget _construirImagenPrincipal() {
    if (contenido.imagenPrincipal.isEmpty) {
      return _marcoImagen(
        icono: Icons.image_outlined,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: Image.network(
        contenido.imagenPrincipal,
        width: 132,
        height: 108,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _marcoImagen(
            icono: Icons.broken_image_outlined,
          );
        },
      ),
    );
  }

  Widget _marcoImagen({
    required IconData icono,
  }) {
    return Container(
      width: 132,
      height: 108,
      decoration: BoxDecoration(
        color: AppColors.surfaceGreen,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: Icon(
        icono,
        color: AppColors.primary,
        size: AppDimensions.iconLg,
      ),
    );
  }

  // ============================================================
  // ESTADO
  // ============================================================

  Widget _construirEstadoChip(String estado) {
    late String texto;
    late IconData icono;

    switch (estado) {
      case 'aprobado':
        texto = 'Aprobado';
        icono = Icons.check_circle_outline;
        break;

      case 'pendiente_revision':
        texto = 'Pendiente de revisión';
        icono = Icons.hourglass_top_outlined;
        break;

      case 'rechazado':
        texto = 'Rechazado';
        icono = Icons.cancel_outlined;
        break;

      default:
        texto = 'Borrador';
        icono = Icons.edit_note_outlined;
    }

    final color = _colorEstado(estado);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusPill,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: AppDimensions.iconSm,
            color: color,
          ),
          const SizedBox(
            width: AppDimensions.spacingXs,
          ),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'aprobado':
        return AppColors.primary;

      case 'pendiente_revision':
        return AppColors.orangeSoft;

      case 'rechazado':
        return AppColors.error;

      default:
        return AppColors.coffeeDark;
    }
  }

  // ============================================================
  // RECURSOS
  // ============================================================

  Widget _construirRecursos() {
    if (contenido.imagenes.isEmpty &&
        contenido.audioGuias.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        if (contenido.imagenes.isNotEmpty)
          _construirChipRecurso(
            icono: Icons.photo_library_outlined,
            texto:
                '${contenido.imagenes.length} imágenes',
          ),
        if (contenido.audioGuias.isNotEmpty)
          _construirChipRecurso(
            icono: Icons.headphones_outlined,
            texto:
                '${contenido.audioGuias.length} audio-guías',
          ),
      ],
    );
  }

  Widget _construirChipRecurso({
    required IconData icono,
    required String texto,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusPill,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: AppDimensions.iconSm,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppDimensions.spacingXs,
          ),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOTIVO DE RECHAZO
  // ============================================================

  Widget _construirMotivoRechazo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(
          alpha: 0.07,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.error,
          ),
          const SizedBox(
            width: AppDimensions.spacingSm,
          ),
          Expanded(
            child: Text(
              'Motivo del rechazo: '
              '${contenido.motivoRechazo}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================

  Widget _construirAcciones() {
    final pendienteRevision =
        contenido.estadoPublicacion ==
            'pendiente_revision';

    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        OutlinedButton.icon(
          onPressed:
              pendienteRevision ? null : onEditar,
          icon: const Icon(
            Icons.edit_outlined,
          ),
          label: const Text(
            'Editar',
          ),
        ),
        if (!pendienteRevision)
          ElevatedButton.icon(
            onPressed: onEnviarRevision,
            icon: const Icon(
              Icons.send_outlined,
            ),
            label: const Text(
              'Enviar a revisión',
            ),
          ),
        OutlinedButton.icon(
          onPressed: onCambiarEstado,
          icon: Icon(
            contenido.activo
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          label: Text(
            contenido.activo
                ? 'Desactivar'
                : 'Activar',
          ),
        ),
      ],
    );
  }
}