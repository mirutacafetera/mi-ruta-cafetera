import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class EncabezadoLista extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String textoNuevo;
  final int cantidad;
  final bool cargando;
  final VoidCallback onActualizar;
  final VoidCallback onNuevo;

  const EncabezadoLista({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.textoNuevo,
    required this.cantidad,
    required this.cargando,
    required this.onActualizar,
    required this.onNuevo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  '$cantidad $descripcion',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : onActualizar,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),

          const SizedBox(width: AppDimensions.spacingXs),

          FilledButton.icon(
            onPressed: onNuevo,
            icon: const Icon(Icons.add),
            label: Text(textoNuevo),
          ),
        ],
      ),
    );
  }
}
