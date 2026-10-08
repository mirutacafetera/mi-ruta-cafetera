import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_dimensions.dart';

class EncabezadoFormularioSitio extends StatelessWidget {
  final bool edicion;
  final bool guardando;
  final VoidCallback onCerrar;

  const EncabezadoFormularioSitio({
    super.key,
    required this.edicion,
    required this.guardando,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXl,
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
        AppDimensions.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            AppDimensions.radiusXxl,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.secondary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edicion
                      ? 'Editar sitio turístico'
                      : 'Nuevo sitio turístico',
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  edicion
                      ? 'Actualiza la información del sitio'
                      : 'Registra un nuevo lugar turístico',
                  style: const TextStyle(
                    color: AppColors.textOnDarkSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: guardando ? null : onCerrar,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textOnDark,
              size: AppDimensions.iconMd,
            ),
          ),
        ],
      ),
    );
  }
}