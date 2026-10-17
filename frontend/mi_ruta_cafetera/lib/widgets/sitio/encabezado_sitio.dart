
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class EncabezadoSitio extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onCerrarSesion;
  final VoidCallback? onMenu;
  final bool mostrarMenu;

  const EncabezadoSitio({
    super.key,
    required this.titulo,
    required this.icono,
    required this.onCerrarSesion,
    this.onMenu,
    this.mostrarMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esMovil = ancho < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.sitioPrimary,
        boxShadow: [
          BoxShadow(
            color: AppColors.sitioPrimaryDark.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            esMovil
                ? AppDimensions.sitioPagePadding
                : AppDimensions.spacingXl,
            AppDimensions.spacingMd,
            esMovil
                ? AppDimensions.sitioPagePadding
                : AppDimensions.spacingXl,
            AppDimensions.spacingMd,
          ),
          child: Row(
            children: [
              if (mostrarMenu) ...[
                _botonIcono(
                  icono: Icons.menu_rounded,
                  tooltip: 'Abrir menú',
                  onTap: onMenu,
                  esMovil: esMovil,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
              ],

              Container(
                width: esMovil ? 44 : 50,
                height: esMovil ? 44 : 50,
                decoration: BoxDecoration(
                  color: AppColors.sitioTextOnPrimary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                  border: Border.all(
                    color: AppColors.sitioTextOnPrimary.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                child: Icon(
                  icono,
                  color: AppColors.sitioTextOnPrimary,
                  size: esMovil
                      ? AppDimensions.iconMd
                      : AppDimensions.iconLg,
                ),
              ),

              const SizedBox(width: AppDimensions.spacingMd),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.sitioTextOnPrimary,
                            fontSize: esMovil ? 18 : 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      'Gestiona tu experiencia turística',
                      maxLines: esMovil ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.sitioTextOnPrimary.withValues(
                              alpha: 0.78,
                            ),
                            fontSize: 12,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.spacingSm),

              _botonIcono(
                icono: Icons.logout_rounded,
                tooltip: 'Cerrar sesión',
                onTap: onCerrarSesion,
                esMovil: esMovil,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonIcono({
    required IconData icono,
    required String tooltip,
    required VoidCallback? onTap,
    required bool esMovil,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.sitioTextOnPrimary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: SizedBox(
            width: AppDimensions.sitioButtonHeight,
            height: AppDimensions.sitioButtonHeight,
            child: Icon(
              icono,
              color: AppColors.sitioTextOnPrimary,
              size: AppDimensions.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
