import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminProximamente extends StatelessWidget {
  final String nombre;

  const AdminProximamente({
    super.key,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 60,
            color: AppColors.textLight,
          ),

          const SizedBox(
            height: AppDimensions.spacingMd + 3,
          ),

          Text(
            '$nombre\nPróximamente',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}