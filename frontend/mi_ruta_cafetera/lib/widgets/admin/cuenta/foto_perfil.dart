
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

  void _verFoto(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () => Navigator.pop(dialogContext),
            child: InteractiveViewer(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                ),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 60,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (context, _) {
        final String? url = controlador.rutaFoto;
        final bool tieneFoto =
            url != null && url.trim().isNotEmpty;
        final double diametro = radio * 2;

        return SizedBox(
          width: diametro,
          height: diametro,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Material(
                  color: AppColors.cream,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: tieneFoto
                        ? () => _verFoto(context, url)
                        : null,
                    child: tieneFoto
                        ? Image.network(
                            url,
                            width: diametro,
                            height: diametro,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Icon(
                                Icons.admin_panel_settings_rounded,
                                size: radio * 1.1,
                                color: AppColors.primary,
                              );
                            },
                          )
                        : Icon(
                            Icons.admin_panel_settings_rounded,
                            size: radio * 1.1,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              ),
              if (editable)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: controlador.cargando ? null : onTap,
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: controlador.cargando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
