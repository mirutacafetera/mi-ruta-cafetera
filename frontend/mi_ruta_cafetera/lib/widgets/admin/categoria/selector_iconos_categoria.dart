
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class SelectorIconosCategoria extends StatelessWidget {
  final Map<String, IconData> iconos;
  final Map<String, Color> colores;
  final String seleccionado;
  final ValueChanged<String> onSeleccionar;
  final bool habilitado;

  const SelectorIconosCategoria({
    super.key,
    required this.iconos,
    required this.colores,
    required this.seleccionado,
    required this.onSeleccionar,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona un icono',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Wrap(
          spacing: AppDimensions.spacingSm,
          runSpacing: AppDimensions.spacingSm,
          children: iconos.entries.map((entrada) {
            final seleccionadoActual =
                seleccionado == entrada.key;
            final color =
                colores[entrada.key] ?? AppColors.primary;

            return InkWell(
              onTap: habilitado
                  ? () => onSeleccionar(entrada.key)
                  : null,
              borderRadius: BorderRadius.circular(
                AppDimensions.categoryRadius,
              ),
              child: Container(
                width: AppDimensions.categoryIconContainer,
                height: AppDimensions.categoryIconContainer,
                decoration: BoxDecoration(
                  color: seleccionadoActual
                      ? color.withValues(alpha: 0.15)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.categoryRadius,
                  ),
                  border: Border.all(
                    color: seleccionadoActual
                        ? color
                        : AppColors.border,
                    width: seleccionadoActual ? 2 : 1,
                  ),
                ),
                child: Icon(
                  entrada.value,
                  color: color,
                  size: AppDimensions.categoryIcon,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
