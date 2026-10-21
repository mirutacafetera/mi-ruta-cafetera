import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class PasosCambioPassword extends StatelessWidget {
  final int pasoActual;

  const PasosCambioPassword({
    super.key,
    required this.pasoActual,
  });

  @override
  Widget build(BuildContext context) {
    final pasos = [
      (
        icono: Icons.email_outlined,
        titulo: 'Enviar código',
      ),
      (
        icono: Icons.pin_outlined,
        titulo: 'Verificar código',
      ),
      (
        icono: Icons.lock_outline_rounded,
        titulo: 'Nueva contraseña',
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 350,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              pasos.length,
              (index) {
                final paso = index + 1;
                final activo = paso <= pasoActual;
                final completado = paso < pasoActual;

                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: activo
                                ? AppColors.secondary
                                : AppColors.cream,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: activo
                                  ? AppColors.secondary
                                  : const Color(0xFFB58A70),
                              width: 1.6,
                            ),
                          ),
                          child: Icon(
                            pasos[index].icono,
                            size: 25,
                            color: activo
                                ? AppColors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(
                          width: AppDimensions.spacingLg,
                        ),
                        Expanded(
                          child: Text(
                            pasos[index].titulo,
                            style: TextStyle(
                              color: activo
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: activo
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (completado)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                    if (index < pasos.length - 1)
                      SizedBox(
                        height: 42,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 2.5,
                            height: 42,
                            margin: const EdgeInsets.only(
                              left: 26,
                            ),
                            decoration: BoxDecoration(
                              color: pasoActual > paso
                                  ? AppColors.primary
                                  : const Color(0xFFB58A70),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}