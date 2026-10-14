import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../google/google_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class BotonGoogle extends StatelessWidget {
  final VoidCallback onPressed;
  final bool cargando;

  const BotonGoogle({
    super.key,
    required this.onPressed,
    required this.cargando,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(
                alpha: 0.16,
              ),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: crearBotonGoogleWeb(),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        elevation: AppDimensions.elevationButton,
        child: InkWell(
          onTap: cargando ? null : onPressed,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: cargando ? 0.65 : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cargando)
                  SizedBox(
                    width: AppDimensions.iconMd,
                    height: AppDimensions.iconMd,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Text(
                  cargando
                      ? 'Conectando con Google...'
                      : 'Continuar con Google',
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}