import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class OpcionCuenta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback? onTap;

  const OpcionCuenta({
    super.key,
    required this.icono,
    required this.titulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: const Color(0xFFB58A70),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(
              alpha: 0.08,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                    border: Border.all(
                      color: const Color(0xFFB58A70),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    icono,
                    color: AppColors.secondary,
                    size: AppDimensions.iconLg,
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondary,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}