import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SeccionFormularioSitio extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final List<Widget> campos;

  const SeccionFormularioSitio({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.campos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder.withValues(alpha: 0.75),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icono,
                  color: AppColors.sitioPrimary,
                  size: AppDimensions.sitioActionIconSize + 4,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppColors.sitioTextPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.sitioSectionGapCompact,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppDimensions.sitioPanelCardGap,
            ),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceSoft,
              borderRadius: BorderRadius.circular(
                AppDimensions.sitioFormRadius,
              ),
              border: Border.all(
                color: AppColors.sitioDivider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _separarCampos(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _separarCampos() {
    final resultado = <Widget>[];

    for (int i = 0; i < campos.length; i++) {
      resultado.add(campos[i]);

      if (i < campos.length - 1) {
        resultado.add(
          const SizedBox(
            height: AppDimensions.sitioFormFieldGap,
          ),
        );
      }
    }

    return resultado;
  }
}