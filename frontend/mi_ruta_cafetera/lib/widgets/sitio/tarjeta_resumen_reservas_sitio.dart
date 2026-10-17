
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class TarjetaResumenReservasSitio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final String descripcion;

  const TarjetaResumenReservasSitio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.descripcion,
  });

  Color get _colorIcono {
    switch (titulo.toLowerCase()) {
      case 'pendientes':
        return AppColors.sitioWarning;
      case 'confirmadas':
        return AppColors.sitioSuccess;
      default:
        return AppColors.sitioPrimary;
    }
  }

  Color get _fondoIcono {
    switch (titulo.toLowerCase()) {
      case 'pendientes':
        return AppColors.sitioWarningSoft;
      case 'confirmadas':
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
          color: AppColors.sitioBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.sitioHeaderIconSize,
            height: AppDimensions.sitioHeaderIconSize,
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
          const SizedBox(
            width: AppDimensions.sitioPanelCardGap,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.sitioTextSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  valor,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.sitioTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  descripcion,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.sitioTextSecondary,
                        height: 1.35,
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
