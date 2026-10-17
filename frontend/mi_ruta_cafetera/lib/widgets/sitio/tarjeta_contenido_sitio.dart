
import 'package:flutter/material.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaContenidoSitio extends StatelessWidget {
  final SitioContenidoModel contenido;
  final VoidCallback onEditar;
  final VoidCallback onEnviarRevision;
  final VoidCallback onEliminar;

  const TarjetaContenidoSitio({
    super.key,
    required this.contenido,
    required this.onEditar,
    required this.onEnviarRevision,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final estado = contenido.estadoPublicacion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirEncabezado(),
          if (contenido.imagenes.isNotEmpty ||
              contenido.audioGuias.isNotEmpty) ...[
            const SizedBox(height: 18),
            _construirRecursos(),
          ],
          if (contenido.motivoRechazo.isNotEmpty &&
              estado == 'rechazado') ...[
            const SizedBox(height: 18),
            _construirMotivoRechazo(),
          ],
          const SizedBox(height: 20),
          _construirAcciones(),
        ],
      ),
    );
  }

  Widget _construirEncabezado() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 420;

        if (esMovil) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirImagenPrincipal(),
              const SizedBox(height: 16),
              _construirInformacion(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirImagenPrincipal(),
            const SizedBox(width: 16),
            Expanded(
              child: _construirInformacion(),
            ),
          ],
        );
      },
    );
  }

  Widget _construirInformacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contenido.titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.sitioTextPrimary,
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          contenido.descripcion,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.sitioTextSecondary,
            fontSize: 13,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 14),
        _construirEstadoChip(contenido.estadoPublicacion),
      ],
    );
  }

  Widget _construirImagenPrincipal() {
    if (contenido.imagenPrincipal.trim().isEmpty) {
      return _marcoImagen(
        icono: Icons.image_outlined,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.sitioItemImageRadius,
      ),
      child: Image.network(
        contenido.imagenPrincipal,
        width: AppDimensions.sitioItemImageWidth,
        height: AppDimensions.sitioItemImageHeight,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _marcoImagen(
            icono: Icons.broken_image_outlined,
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return _marcoImagen(
            icono: Icons.image_outlined,
            mostrarCarga: true,
          );
        },
      ),
    );
  }

  Widget _marcoImagen({
    required IconData icono,
    bool mostrarCarga = false,
  }) {
    return Container(
      width: AppDimensions.sitioItemImageWidth,
      height: AppDimensions.sitioItemImageHeight,
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceGreen,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioItemImageRadius,
        ),
      ),
      child: mostrarCarga
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.sitioPrimary,
              ),
            )
          : Icon(
              icono,
              color: AppColors.sitioPrimary,
              size: 34,
            ),
    );
  }

  Widget _construirEstadoChip(String estado) {
    late final String texto;
    late final IconData icono;
    late final Color color;
    late final Color fondo;

    switch (estado) {
      case 'aprobado':
        texto = 'Aprobado';
        icono = Icons.check_circle_rounded;
        color = AppColors.sitioSuccess;
        fondo = AppColors.sitioSuccessSoft;
        break;
      case 'pendiente_revision':
        texto = 'Pendiente de revisión';
        icono = Icons.hourglass_top_rounded;
        color = AppColors.sitioWarning;
        fondo = AppColors.sitioWarningSoft;
        break;
      case 'rechazado':
        texto = 'Rechazado';
        icono = Icons.cancel_rounded;
        color = AppColors.sitioError;
        fondo = AppColors.sitioErrorSoft;
        break;
      default:
        texto = 'Borrador';
        icono = Icons.edit_note_rounded;
        color = AppColors.sitioPrimary;
        fondo = AppColors.sitioSurfaceGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sitioStatusHorizontalPadding,
        vertical: AppDimensions.sitioStatusVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioStatusRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirRecursos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sitioDivider,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (contenido.imagenes.isNotEmpty)
            _construirChipRecurso(
              icono: Icons.photo_library_outlined,
              texto: '${contenido.imagenes.length} imágenes',
              color: AppColors.sitioPrimary,
              fondo: AppColors.sitioSurfaceGreen,
            ),
          if (contenido.audioGuias.isNotEmpty)
            _construirChipRecurso(
              icono: Icons.headphones_rounded,
              texto: '${contenido.audioGuias.length} audioguías',
              color: AppColors.sitioAccent,
              fondo: AppColors.sitioWarningSoft,
            ),
        ],
      ),
    );
  }

  Widget _construirChipRecurso({
    required IconData icono,
    required String texto,
    required Color color,
    required Color fondo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioStatusRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            texto,
            style: TextStyle(
              color: AppColors.sitioTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirMotivoRechazo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sitioErrorSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
        border: Border.all(
          color: AppColors.sitioError.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.sitioError,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Motivo del rechazo',
                  style: TextStyle(
                    color: AppColors.sitioError,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  contenido.motivoRechazo,
                  style: const TextStyle(
                    color: AppColors.sitioTextPrimary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAcciones() {
    final pendienteRevision =
        contenido.estadoPublicacion == 'pendiente_revision';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: pendienteRevision ? null : onEditar,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sitioPrimary,
            side: const BorderSide(
              color: AppColors.sitioBorder,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Editar'),
        ),
        if (!pendienteRevision)
          ElevatedButton.icon(
            onPressed: onEnviarRevision,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.send_rounded, size: 17),
            label: const Text('Enviar a revisión'),
          ),
        OutlinedButton.icon(
          onPressed: onEliminar,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sitioError,
            side: BorderSide(
              color: AppColors.sitioError.withValues(alpha: 0.35),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('Eliminar'),
        ),
      ],
    );
  }
}
