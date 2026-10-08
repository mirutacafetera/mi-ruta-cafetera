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
        bottom: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        border: Border.all(
          color: AppColors.borderDark,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: AppColors.secondary,
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}