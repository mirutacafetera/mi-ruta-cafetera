
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class ResumenReporte extends StatelessWidget {
  final int total;
  final int pendientes;
  final int enRevision;
  final int resueltos;
  final String estadoSeleccionado;
  final ValueChanged<String> onEstadoSeleccionado;

  const ResumenReporte({
    super.key,
    required this.total,
    required this.pendientes,
    required this.enRevision,
    required this.resueltos,
    required this.estadoSeleccionado,
    required this.onEstadoSeleccionado,
  });

  static const Color _cafe = Color(0xFFB58A70);

  @override
  Widget build(BuildContext context) {
    final tarjetas = [
      (
        titulo: 'Total reportes',
        cantidad: total,
        estado: 'todos',
        icono: Icons.groups_rounded,
        color: const Color(0xFF315D4B),
        fondoIcono: const Color(0xFFE1E8DF),
      ),
      (
        titulo: 'Pendientes',
        cantidad: pendientes,
        estado: 'pendiente',
        icono: Icons.mark_email_unread_rounded,
        color: const Color(0xFFE58A2B),
        fondoIcono: const Color(0xFFFFEBD0),
      ),
      (
        titulo: 'En revisión',
        cantidad: enRevision,
        estado: 'en_revision',
        icono: Icons.manage_search_rounded,
        color: const Color(0xFF648B48),
        fondoIcono: const Color(0xFFE3ECDD),
      ),
      (
        titulo: 'Resueltos',
        cantidad: resueltos,
        estado: 'resuelto',
        icono: Icons.check_circle_outline_rounded,
        color: const Color(0xFF438B61),
        fondoIcono: const Color(0xFFDDEEE0),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 700 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: tarjetas.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: AppDimensions.spacingSm,
            mainAxisSpacing: AppDimensions.spacingSm,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            final tarjeta = tarjetas[index];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius,
                ),
                onTap: () {
                  onEstadoSeleccionado(tarjeta.estado);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.creamLight,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius,
                    ),
                    border: Border.all(
                      color: _cafe,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _cafe.withValues(alpha: 0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: tarjeta.fondoIcono,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tarjeta.icono,
                              color: tarjeta.color,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tarjeta.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tarjeta.cantidad}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: tarjeta.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
