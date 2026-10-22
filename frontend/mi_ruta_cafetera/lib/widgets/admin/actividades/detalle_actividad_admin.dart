import 'package:flutter/material.dart';

import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class DetalleActividadAdmin extends StatelessWidget {
  final ActividadAdminModel actividad;
  final VoidCallback onVolver;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback? onActualizar;
  final bool procesando;
  final Function(List<String>, int)? onMostrarGaleria;

  const DetalleActividadAdmin({
    super.key,
    required this.actividad,
    required this.onVolver,
    required this.onAprobar,
    required this.onRechazar,
    this.onActualizar,
    this.procesando = false,
    this.onMostrarGaleria,
  });

  @override
  Widget build(BuildContext context) {
    final imagenes = actividad.todasLasImagenes
        .where((url) => url.trim().isNotEmpty)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: AppDimensions.spacingXs,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Volver',
                onPressed: onVolver,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Expanded(
                child: Text(
                  'Detalles de la actividad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (onActualizar != null)
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: procesando ? null : onActualizar,
                  icon: const Icon(Icons.refresh_rounded),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.pageHorizontalSmall,
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actividad.nombre.isEmpty
                          ? 'Actividad sin nombre'
                          : actividad.nombre,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),
                    _seccion(
                      'Descripción',
                      Icons.description_outlined,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),
                    _texto(actividad.descripcion),
                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),
                    _seccion(
                      'Información turística',
                      Icons.place_outlined,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),
                    _dato('Sitio turístico', actividad.nombreSitio),
                    _dato('Ciudad', actividad.ciudad),
                    _dato('Departamento', actividad.departamento),
                    if (actividad.precio != null)
                      _dato('Precio', actividad.precio.toString()),
                    if (actividad.horario.trim().isNotEmpty)
                      _dato('Horario', actividad.horario),
                    if (actividad.duracion.trim().isNotEmpty)
                      _dato('Duración', actividad.duracion),
                    if (actividad.fechaCreacion != null)
                      _dato(
                        'Fecha de creación',
                        _formatearFecha(actividad.fechaCreacion!),
                      ),
                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),
                    _seccion(
                      'Fotografías',
                      Icons.photo_library_outlined,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),
                    if (imagenes.isEmpty)
                      _sinImagenes()
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final ancho = (constraints.maxWidth -
                                  AppDimensions.spacingSm * 2) /
                              3;

                          return Wrap(
                            spacing: AppDimensions.spacingSm,
                            runSpacing: AppDimensions.spacingSm,
                            children: List.generate(
                              imagenes.length,
                              (indice) {
                                return GestureDetector(
                                  onTap: onMostrarGaleria == null
                                      ? null
                                      : () => onMostrarGaleria!(
                                            imagenes,
                                            indice,
                                          ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd,
                                    ),
                                    child: Image.network(
                                      imagenes[indice],
                                      width: ancho,
                                      height: ancho,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: ancho,
                                          height: ancho,
                                          color: AppColors.surfaceVariant,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            color: AppColors.textSecondary,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    if (actividad.motivoRechazo.trim().isNotEmpty) ...[
                      const SizedBox(
                        height: AppDimensions.spacingLg,
                      ),
                      _seccion(
                        'Motivo del rechazo anterior',
                        Icons.info_outline_rounded,
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      _texto(actividad.motivoRechazo),
                    ],
                    const SizedBox(
                      height: AppDimensions.spacingXl,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: procesando ? null : onRechazar,
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Rechazar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: procesando ? null : onAprobar,
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                            ),
                            label: const Text('Aprobar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (procesando) ...[
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccion(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(
          icono,
          size: AppDimensions.iconMd,
          color: AppColors.primary,
        ),
        const SizedBox(
          width: AppDimensions.spacingSm,
        ),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            valor.trim().isEmpty ? 'No disponible' : valor,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _texto(String valor) {
    return Text(
      valor.trim().isEmpty ? 'No disponible' : valor,
      style: const TextStyle(
        color: AppColors.textSecondary,
        height: 1.45,
      ),
    );
  }

  Widget _sinImagenes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 36,
            color: AppColors.textSecondary,
          ),
          SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Text(
            'No hay fotografías disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}