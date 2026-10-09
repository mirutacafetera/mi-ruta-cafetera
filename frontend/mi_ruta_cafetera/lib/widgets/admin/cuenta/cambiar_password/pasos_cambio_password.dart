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
        icono: Icons.lock_outline,
        titulo: 'Nueva contraseña',
      ),
    ];

    return Row(
      children: List.generate(
        pasos.length,
        (index) {
          final paso = index + 1;
          final activo = paso <= pasoActual;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: activo
                            ? AppColors.secondary
                            : AppColors.borderDark,
                        child: Icon(
                          pasos[index].icono,
                          color: activo
                              ? AppColors.white
                              : AppColors.textSecondary,
                          size: AppDimensions.iconMd,
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      Text(
                        pasos[index].titulo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: activo
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: activo
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < pasos.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(
                        bottom: 28,
                      ),
                      color: paso < pasoActual
                          ? AppColors.secondary
                          : AppColors.borderDark,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}