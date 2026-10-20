
import 'package:flutter/material.dart';

import '../../../models/admin/mensaje_chatbot.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class TarjetaMensajeChatbot extends StatelessWidget {
  final MensajeChatbot mensaje;

  const TarjetaMensajeChatbot({
    super.key,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.esUsuario;
    final esError = mensaje.esError;

    final colorFondo = esError
        ? AppColors.error.withValues(alpha: 0.08)
        : esUsuario
            ? AppColors.orangeSoft
            : AppColors.surface;

    final colorTexto = esError
        ? AppColors.error
        : AppColors.textPrimary;

    final colorIcono = esError
        ? AppColors.error
        : AppColors.primary;

    final hora = TimeOfDay.fromDateTime(
      mensaje.fecha,
    ).format(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: esUsuario
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!esUsuario) ...[
            Container(
              width: AppDimensions.circularButtonSmall,
              height: AppDimensions.circularButtonSmall,
              decoration: BoxDecoration(
                color: colorIcono.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                esError
                    ? Icons.error_outline_rounded
                    : Icons.smart_toy_rounded,
                color: colorIcono,
                size: AppDimensions.iconMd,
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingSm,
            ),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              padding: const EdgeInsets.all(
                AppDimensions.spacingLg,
              ),
              decoration: BoxDecoration(
                color: colorFondo,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(
                    AppDimensions.radiusLg,
                  ),
                  topRight: const Radius.circular(
                    AppDimensions.radiusLg,
                  ),
                  bottomLeft: Radius.circular(
                    esUsuario
                        ? AppDimensions.radiusLg
                        : AppDimensions.radiusSm,
                  ),
                  bottomRight: Radius.circular(
                    esUsuario
                        ? AppDimensions.radiusSm
                        : AppDimensions.radiusLg,
                  ),
                ),
                border: Border.all(
                  color: esError
                      ? AppColors.error.withValues(alpha: 0.25)
                      : esUsuario
                          ? AppColors.secondary.withValues(
                              alpha: 0.25,
                            )
                          : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esError
                        ? 'Aviso'
                        : esUsuario
                            ? 'Tú'
                            : 'Chatbot IA',
                    style: TextStyle(
                      color: colorIcono,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingXs,
                  ),
                  SelectableText(
                    mensaje.contenido,
                    style: TextStyle(
                      color: colorTexto,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      hora,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (esUsuario) ...[
            const SizedBox(
              width: AppDimensions.spacingSm,
            ),
            Container(
              width: AppDimensions.circularButtonSmall,
              height: AppDimensions.circularButtonSmall,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: AppDimensions.iconMd,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
