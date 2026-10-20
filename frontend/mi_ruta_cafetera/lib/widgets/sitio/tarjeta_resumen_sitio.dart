import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaResumenSitio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final String descripcion;

  const TarjetaResumenSitio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.descripcion,
  });

  Color get _colorIcono {
    switch (titulo.toLowerCase()) {
      case 'total':
        return AppColors.sitioPrimary;
      case 'publicadas':
        return AppColors.sitioSuccess;
      case 'en revisión':
        return AppColors.sitioWarning;
      default:
        return AppColors.sitioPrimary;
    }
  }

  Color get _fondoIcono {
    switch (titulo.toLowerCase()) {
      case 'total':
        return AppColors.sitioSurfaceGreen;
      case 'publicadas':
        return AppColors.sitioSuccessSoft;
      case 'en revisión':
        return AppColors.sitioWarningSoft;
      default:
        return AppColors.sitioSurfaceGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioStatCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioStatCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder.withValues(alpha: 0.75),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _fondoIcono,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icono,
              color: _colorIcono,
              size: AppDimensions.sitioStatIconSize,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.sitioTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.sitioTextSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}