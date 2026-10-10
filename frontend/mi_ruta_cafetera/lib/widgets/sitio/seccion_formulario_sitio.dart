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
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.55,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coffeeDark.withValues(
              alpha: 0.05,
            ),
            blurRadius: AppDimensions.elevationFloating,
            offset: const Offset(0, 3),
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: Icon(
                  icono,
                  color: AppColors.white,
                  size: AppDimensions.iconLg,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingXs,
                    ),
                    Text(
                      subtitulo,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppDimensions.spacingLg,
          ),
          ..._separarCampos(),
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
            height: AppDimensions.spacingMd,
          ),
        );
      }
    }

    return resultado;
  }
}