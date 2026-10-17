import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaEstadisticaSitio extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const TarjetaEstadisticaSitio({
    super.key,
    required this.titulo,
    required this.valor,
    required this.descripcion,
    required this.icono,
  });

  Color get _colorIcono {
    switch (titulo.toLowerCase()) {
      case 'visitas':
        return AppColors.sitioPrimary;
      case 'reservas':
        return AppColors.sitioInfo;
      case 'reseñas':
        return AppColors.sitioWarning;
      case 'actividades':
        return AppColors.sitioSuccess;
      default:
        return AppColors.sitioPrimary;
    }
  }

  Color get _colorFondoIcono {
    switch (titulo.toLowerCase()) {
      case 'visitas':
        return AppColors.sitioSurfaceGreen;
      case 'reservas':
        return AppColors.sitioInfoSoft;
      case 'reseñas':
        return AppColors.sitioWarningSoft;
      case 'actividades':
        return AppColors.sitioSuccessSoft;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.sitioStatIconSize + 20,
                height: AppDimensions.sitioStatIconSize + 20,
                decoration: BoxDecoration(
                  color: _colorFondoIcono,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  color: _colorIcono,
                  size: AppDimensions.sitioStatIconSize,
                ),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _colorIcono,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: const TextStyle(
                  color: AppColors.sitioTextPrimary,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
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
    );
  }
}