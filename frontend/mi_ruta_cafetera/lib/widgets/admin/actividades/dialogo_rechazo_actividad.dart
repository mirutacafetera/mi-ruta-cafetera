
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

const Color _terracotaRechazo = Color(0xFFB85C50);

/// Muestra un diálogo reutilizable para solicitar el motivo del rechazo.
Future<void> mostrarDialogoRechazoAdmin({
  required BuildContext context,
  required ValueChanged<String> onRechazar,
  String titulo = 'Motivo de rechazo *',
  String textoAyuda = 'Escribe aquí el motivo del rechazo...',
}) async {
  final controlador = TextEditingController();
  final formularioKey = GlobalKey<FormState>();

  try {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.creamLight,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: AppColors.adminBorder,
              width: 1.2,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: formularioKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.cafeOscuro,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controlador,
                      autofocus: true,
                      minLines: 4,
                      maxLines: 5,
                      maxLength: 300,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: textoAyuda,
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.all(14),
                        counterStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.secondary,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.secondary,
                            width: 1.8,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _terracotaRechazo,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _terracotaRechazo,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Escribe el motivo del rechazo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(
                                color: AppColors.secondary,
                                width: 1.2,
                              ),
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (!formularioKey.currentState!
                                  .validate()) {
                                return;
                              }

                              final motivo = controlador.text.trim();

                              Navigator.of(dialogContext).pop();
                              onRechazar(motivo);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Enviar',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  } finally {
    controlador.dispose();
  }
}
