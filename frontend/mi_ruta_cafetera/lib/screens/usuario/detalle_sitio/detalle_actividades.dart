import 'package:flutter/material.dart';

import '../../../../models/sitio/sitio_actividad_model.dart';
import '../../../../theme/app_dimensions.dart';

class DetalleActividades extends StatelessWidget {
  final List<SitioActividadModel> actividades;
  final bool cargando;
  final ValueChanged<SitioActividadModel> onSeleccionar;

  const DetalleActividades({
    super.key,
    required this.actividades,
    this.cargando = false,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (cargando) {
      return Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividades para disfrutar',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: AppDimensions.spacingMd),

          if (actividades.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_activity_outlined,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    'Próximamente nuevas experiencias',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    'Estamos preparando actividades para que '
                    'disfrutes aún más tu visita a este lugar.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: actividades.length,
                separatorBuilder: (_, _) =>
                    SizedBox(width: AppDimensions.spacingMd),
                itemBuilder: (context, index) {
                  final actividad = actividades[index];

                  return SizedBox(
                    width: 240,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => onSeleccionar(actividad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: actividad.imagenPrincipal.isNotEmpty
                                    ? Image.network(
                                        actividad.imagenPrincipal,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Icon(
                                            Icons.local_activity,
                                            size: 48,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.local_activity,
                                          size: 48,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                AppDimensions.spacingMd,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    actividad.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  SizedBox(
                                    height: AppDimensions.spacingSm,
                                  ),
                                  Text(
                                    actividad.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}