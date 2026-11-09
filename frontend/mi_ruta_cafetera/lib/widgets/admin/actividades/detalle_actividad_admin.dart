import 'package:flutter/material.dart';

import '../../../models/admin/admin_actividad_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import 'botones_navegacion_admin.dart';
import 'componentes_detalle_actividad.dart';
import 'dialogo_rechazo_actividad.dart';
import 'galeria_detalle_actividad.dart';
import 'tarjeta_principal_actividad.dart';

class DetalleActividadAdmin extends StatelessWidget {
  final ActividadAdminModel actividad;
  final VoidCallback onVolver;
  final VoidCallback onAprobar;
  final ValueChanged<String> onRechazar;
  final VoidCallback? onActualizar;
  final VoidCallback? onEliminar;
  final bool procesando;
  final Function(List<String>, int)? onMostrarGaleria;

  const DetalleActividadAdmin({
    super.key,
    required this.actividad,
    required this.onVolver,
    required this.onAprobar,
    required this.onRechazar,
    this.onActualizar,
    this.onEliminar,
    this.procesando = false,
    this.onMostrarGaleria,
  });

  static const Color _cafe = AppColors.adminBorder;
  static const Color _terracota = Color(0xFFB85C50);

  @override
  Widget build(BuildContext context) {
    final imagenes = actividad.todasLasImagenes
        .where((url) => url.trim().isNotEmpty)
        .toList();

    final pendiente =
        actividad.estadoPublicacion.toLowerCase().trim() ==
            'pendiente_revision';

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Column(
        children: [
          _encabezado(),
          Expanded(
            child: procesando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pageHorizontalSmall,
                      AppDimensions.spacingSm,
                      AppDimensions.pageHorizontalSmall,
                      AppDimensions.spacingXl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. TARJETA PRINCIPAL
                        TarjetaPrincipalActividad(
                          titulo: actividad.nombre.trim().isEmpty
                              ? 'Actividad sin nombre'
                              : actividad.nombre,
                          descripcion: actividad.descripcion,
                          imagenUrl:
                              imagenes.isNotEmpty ? imagenes.first : null,
                          estado: actividad.estadoPublicacion,
                        ),

                        const SizedBox(height: 16),

                        // 2. INFORMACIÓN TURÍSTICA
                        TarjetaDetalleActividad(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const TituloDetalleActividad(
                                  texto: 'Información turística',
                                  icono: Icons.explore_outlined,
                                ),
                                const SizedBox(height: 22),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final ancho =
                                        (constraints.maxWidth - 12) / 2;

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // COLUMNA IZQUIERDA
                                        Expanded(
                                          child: Wrap(
                                            spacing: 12,
                                            runSpacing: 20,
                                            children: [
                                              DatoDetalleActividad(
                                                ancho: ancho,
                                                icono:
                                                    Icons.storefront_outlined,
                                                titulo: 'Sitio turístico',
                                                valor: actividad.nombreSitio,
                                              ),
                                              DatoDetalleActividad(
                                                ancho: ancho,
                                                icono: Icons
                                                    .location_city_outlined,
                                                titulo: 'Ciudad',
                                                valor: actividad.ciudad,
                                              ),
                                              DatoDetalleActividad(
                                                ancho: ancho,
                                                icono: Icons.map_outlined,
                                                titulo: 'Departamento',
                                                valor:
                                                    actividad.departamento,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // LÍNEA VERTICAL DEL CENTRO
                                        Container(
                                          width: 1,
                                          height: 280,
                                          margin:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          color: AppColors.adminBorder
                                              .withValues(alpha: 0.55),
                                        ),

                                        // COLUMNA DERECHA
                                        Expanded(
                                          child: Wrap(
                                            spacing: 12,
                                            runSpacing: 20,
                                            children: [
                                              DatoDetalleActividad(
                                                ancho: ancho,
                                                icono:
                                                    Icons.payments_outlined,
                                                titulo: 'Precio',
                                                valor: actividad.precio ==
                                                        null
                                                    ? 'No disponible'
                                                    : '${actividad.precio} COP',
                                              ),
                                              DatoDetalleActividad(
                                                ancho: ancho,
                                                icono:
                                                    Icons.schedule_outlined,
                                                titulo: 'Horario',
                                                valor: actividad.horario,
                                              ),
                                              DatoDetalleActividad(
                                                ancho: ancho,
                                                icono: Icons
                                                    .hourglass_bottom_rounded,
                                                titulo: 'Duración',
                                                valor: actividad.duracion,
                                              ),
                                              if (actividad.fechaCreacion !=
                                                  null)
                                                DatoDetalleActividad(
                                                  ancho: ancho,
                                                  icono: Icons.event_outlined,
                                                  titulo: 'Fecha de creación',
                                                  valor:
                                                      FormateadorFechaActividad
                                                          .formatear(
                                                    actividad.fechaCreacion!,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 3. GALERÍA
                        GaleriaDetalleActividad(
                          imagenes: imagenes,
                          onMostrarGaleria: onMostrarGaleria,
                        ),

                        // 4. ACCIONES: SOLO SI ESTÁ PENDIENTE
                        if (pendiente) ...[
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              // RECHAZAR
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: procesando
                                      ? null
                                      : () {
                                          mostrarDialogoRechazoAdmin(
                                            context: context,
                                            onRechazar: onRechazar,
                                          );
                                        },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
                                  label: const Text('Rechazar'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _terracota,
                                    side: const BorderSide(
                                      color: _terracota,
                                      width: 1.3,
                                    ),
                                    minimumSize:
                                        const Size.fromHeight(48),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // APROBAR
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed:
                                      procesando ? null : onAprobar,
                                  icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 20,
                                  ),
                                  label: const Text('Aprobar'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    minimumSize:
                                        const Size.fromHeight(48),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // 5. ELIMINAR: ESQUINA INFERIOR DERECHA
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed:
                                (procesando || onEliminar == null)
                                    ? null
                                    : () async {
                                        final confirmar =
                                            await showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (contexto) =>
                                              AlertDialog(
                                            backgroundColor: AppColors.white,
                                            surfaceTintColor:
                                                Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            title: const Text(
                                              'Eliminar actividad',
                                              style: TextStyle(
                                                color:
                                                    AppColors.textPrimary,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            content: Text(
                                             '¿Deseas eliminar la actividad "${actividad.nombre}"? '
                                             'Esta acción no se puede deshacer.',
                                             style: const TextStyle(
                                             color: AppColors.textSecondary,
                                             fontSize: 14,
                                             height: 1.4,
                                            ),
                                          ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(contexto)
                                                        .pop(false),
                                                child: const Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              FilledButton.icon(
                                                onPressed: () =>
                                                    Navigator.of(contexto)
                                                        .pop(true),
                                                icon: const Icon(
                                                  Icons
                                                      .delete_outline_rounded,
                                                  size: 18,
                                                ),
                                                label: const Text('Eliminar'),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  foregroundColor:
                                                      AppColors.white,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmar == true) {
                                          onEliminar!.call();
                                        }
                                      },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 19,
                            ),
                            label: const Text('Eliminar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              iconColor: AppColors.error,
                              backgroundColor: AppColors.creamLight,
                              side: const BorderSide(
                                color: AppColors.adminBorder,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 20),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ENCABEZADO CONSERVADO
  Widget _encabezado() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 6,
            color: AppColors.primary,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              border: Border(
                bottom: BorderSide(
                  color: _cafe.withValues(alpha: .65),
                ),
              ),
            ),
            child: Row(
              children: [
                BotonNavegacionAdmin(
                  icono: Icons.arrow_back_rounded,
                  tooltip: 'Volver',
                  onPressed: onVolver,
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detalles de la actividad',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Información y gestión turística',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                if (onActualizar != null)
                  BotonNavegacionAdmin(
                    icono: Icons.refresh_rounded,
                    tooltip: 'Actualizar',
                    onPressed:
                        procesando ? null : () => onActualizar?.call(),
                  ),
              ],
            ),
          ),
        ],
      );
}