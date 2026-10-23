
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../../theme/app_colors.dart';

class FotoPerfil extends StatelessWidget {
  final FotoPerfilAdminControlador controlador;
  final double radio;
  final bool editable;
  final VoidCallback? onTap;

  const FotoPerfil({
    super.key,
    required this.controlador,
    this.radio = 45,
    this.editable = false,
    this.onTap,
  });

  void _verFoto(BuildContext context, String ruta) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(ruta),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 60,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (context, _) {
        final ruta = controlador.rutaFoto;
        final archivo = ruta != null ? File(ruta) : null;
        final existeFoto =
            archivo != null && archivo.existsSync();

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: existeFoto
                  ? () => _verFoto(context, ruta!)
                  : null,
              child: CircleAvatar(
                key: ValueKey(ruta),
                radius: radio,
                backgroundColor: AppColors.cream,
                foregroundImage:
                    existeFoto ? FileImage(archivo) : null,
                onForegroundImageError: (error, stackTrace) {
                  debugPrint(
                    'Error al mostrar la foto del administrador: $error',
                  );
                },
                child: existeFoto
                    ? null
                    : Icon(
                        Icons.admin_panel_settings_rounded,
                        size: radio * 1.1,
                        color: AppColors.primary,
                      ),
              ),
            ),
            if (editable)
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: controlador.cargando ? null : onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: controlador.cargando
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 17,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
