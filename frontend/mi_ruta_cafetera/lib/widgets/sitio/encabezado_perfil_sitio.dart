import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class EncabezadoPerfilSitio extends StatelessWidget {
  final bool editando;
  final VoidCallback onEditar;

  const EncabezadoPerfilSitio({
    super.key,
    required this.editando,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Mi sitio',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXs,
              ),

              Text(
                'Administra la información que los visitantes encontrarán sobre tu experiencia.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),

        if (!editando)
          ElevatedButton.icon(
            onPressed: onEditar,
            icon: const Icon(
              Icons.edit_rounded,
            ),
            label: const Text(
              'Editar',
            ),
          ),
      ],
    );
  }
}