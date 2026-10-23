
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class EncabezadoLista extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String textoNuevo;
  final int cantidad;
  final bool cargando;
  final bool mostrarBotonNuevo;
  final VoidCallback onActualizar;
  final VoidCallback onNuevo;

  const EncabezadoLista({
    super.key,
    required this.titulo,
    required this.descripcion,
    this.textoNuevo = '',
    required this.cantidad,
    required this.cargando,
    this.mostrarBotonNuevo = false,
    required this.onActualizar,
    required this.onNuevo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pageHorizontalSmall,
        AppDimensions.spacingLg,
        AppDimensions.pageHorizontalSmall,
        AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo.isNotEmpty)
                  Text(
                    titulo,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  '$cantidad $descripcion',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : onActualizar,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: AppDimensions.iconMd,
            ),
          ),
          if (mostrarBotonNuevo && textoNuevo.trim().isNotEmpty) ...[
            const SizedBox(width: AppDimensions.spacingXs),
            FilledButton.icon(
              onPressed: onNuevo,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                elevation: 0,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusXl,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.add,
                size: AppDimensions.iconMd,
              ),
              label: Text(textoNuevo),
            ),
          ],
        ],
      ),
    );
  }
}
