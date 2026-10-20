
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class CampoMensajeChatbot extends StatelessWidget {
  final TextEditingController controller;
  final bool cargando;
  final ValueChanged<String> onEnviar;

  const CampoMensajeChatbot({
    super.key,
    required this.controller,
    required this.cargando,
    required this.onEnviar,
  });

  void _enviar() {
    final mensaje = controller.text.trim();

    if (mensaje.isEmpty || cargando) return;

    onEnviar(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !cargando,
                minLines: 1,
                maxLines: 5,
                textCapitalization:
                    TextCapitalization.sentences,
                onSubmitted: (_) => _enviar(),
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingLg,
                    vertical: AppDimensions.spacingMd,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusXl,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusXl,
                    ),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusXl,
                    ),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingSm,
            ),
            SizedBox(
              width: AppDimensions.circularButtonSize,
              height: AppDimensions.circularButtonSize,
              child: FilledButton(
                onPressed: cargando ? null : _enviar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: cargando
                    ? const SizedBox(
                        width: AppDimensions.iconMd,
                        height: AppDimensions.iconMd,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        size: AppDimensions.iconMd,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
