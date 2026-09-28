import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CategoriaBadge extends StatelessWidget {
  final String categoria;
  final bool showIcon;

  const CategoriaBadge({
    super.key,
    required this.categoria,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getColorForCategory(categoria);
    final icon = AppColors.getIconForCategory(categoria);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            categoria,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}