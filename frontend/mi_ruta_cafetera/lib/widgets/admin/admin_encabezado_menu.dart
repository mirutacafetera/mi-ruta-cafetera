
import 'package:flutter/material.dart';

import '../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'cuenta/foto_perfil.dart';

class AdminEncabezadoMenu extends StatelessWidget {
  final String nombre;
  final String email;
  final FotoPerfilAdminControlador fotoPerfilControlador;

  const AdminEncabezadoMenu({
    super.key,
    required this.nombre,
    required this.email,
    required this.fotoPerfilControlador,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _FormaEncabezadoMenu(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          AppDimensions.spacingLg,
          MediaQuery.paddingOf(context).top + 12,
          AppDimensions.spacingLg,
          AppDimensions.spacingLg,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'PANEL ADMINISTRATIVO',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Icon(
                  Icons.coffee_rounded,
                  color: AppColors.cream,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                  child: FotoPerfil(
                    controlador: fotoPerfilControlador,
                    radio: 32,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.cream,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              email,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.cream,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Container(
              height: 1,
              color: AppColors.white.withValues(alpha: 0.14),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 15,
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Gestión y control de Mi Ruta Cafetera',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormaEncabezadoMenu extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radio = 26.0;
    const curvaInferior = 16.0;

    return Path()
      ..moveTo(radio, 0)
      ..lineTo(size.width - radio, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radio)
      ..lineTo(size.width, size.height - curvaInferior)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - curvaInferior,
        size.height,
      )
      ..lineTo(radio, size.height)
      ..quadraticBezierTo(
        0,
        size.height,
        0,
        size.height - radio,
      )
      ..lineTo(0, radio)
      ..quadraticBezierTo(0, 0, radio, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _FormaEncabezadoMenu oldClipper) {
    return false;
  }
}
