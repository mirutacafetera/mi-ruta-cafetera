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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(ruta),
                fit: BoxFit.contain,
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
        final existeFoto =
            ruta != null && File(ruta).existsSync();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: existeFoto
                  ? () => _verFoto(context, ruta)
                  : null,
              child: CircleAvatar(
                radius: radio,
                backgroundColor: AppColors.cream,
                backgroundImage: existeFoto
                    ? FileImage(File(ruta))
                    : null,
                child: existeFoto
                    ? null
                    : Icon(
                        Icons.admin_panel_settings,
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