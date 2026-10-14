import 'package:flutter/material.dart';

import '../../../models/sitio_turistico_model.dart';
import '../../../models/sitio/sitio_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/mapa/mapa_detalle_sitio.dart';
import '../../mapa_screen_2.dart';

class DetalleSitioAcciones {
  DetalleSitioAcciones._();

  static void verMapa(BuildContext context, SitioTuristicoModel sitio) {
    if (!sitio.tieneCoordenadas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este sitio todavía no tiene una ubicación válida.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapaScreen2(sitioInicial: sitio)),
    );
  }

  static void mostrarDetalleMapa(
    BuildContext context,
    SitioTuristicoModel sitio,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapaDetalleSitio(
        sitio: sitio,
        onVerMapa: () => verMapa(context, sitio),
        onAgregarRuta: () => agregarRuta(context),
      ),
    );
  }

  static void agregarRuta(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La selección de sitios para tu ruta estará disponible aquí.',
        ),
      ),
    );
  }

  static void mostrarActividad(
    BuildContext context,
    SitioActividadModel actividad,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actividad.imagenPrincipal.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  child: Image.network(
                    actividad.imagenPrincipal,
                    width: double.infinity,
                    height: AppDimensions.featuredImageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                actividad.nombre,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                actividad.descripcion,
                style: Theme.of(sheetContext).textTheme.bodyLarge,
              ),
              if (actividad.duracion.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                Text('Duración: ${actividad.duracion}'),
              ],
              if (actividad.horario.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Text('Horario: ${actividad.horario}'),
              ],
              if (actividad.precio > 0) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Text('Precio: ${actividad.precio}'),
              ],
              const SizedBox(height: AppDimensions.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
