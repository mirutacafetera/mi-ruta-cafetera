
import 'package:flutter/material.dart';

import '../../../models/admin/sitio_admin_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class SelectorSitioCuenta extends StatelessWidget {
  final List<SitioAdminModel> sitios;

  const SelectorSitioCuenta({
    super.key,
    required this.sitios,
  });

  static Future<SitioAdminModel?> mostrar({
    required BuildContext context,
    required List<SitioAdminModel> sitios,
  }) {
    return showDialog<SitioAdminModel>(
      context: context,
      builder: (_) => SelectorSitioCuenta(sitios: sitios),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: const BorderSide(color: Color(0xFFB58A70)),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.landscape_rounded,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              'Seleccionar sitio',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: sitios.isEmpty
            ? Text(
                'No hay sitios disponibles.',
                style: theme.textTheme.bodyMedium,
              )
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sitios.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sitio = sitios[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: AppDimensions.spacingXs,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        child: sitio.imagen.trim().isNotEmpty
                            ? Image.network(
                                sitio.imagen,
                                width: 54,
                                height: 54,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _iconoSitio(sitio),
                              )
                            : _iconoSitio(sitio),
                      ),
                      title: Text(
                        sitio.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        sitio.ciudad,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.secondary,
                      ),
                      onTap: () => Navigator.pop(context, sitio),
                    );
                  },
                ),
              ),
      ),
      actions: [
  TextButton(
    onPressed: () => Navigator.pop(context),
    style: TextButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
      ),
    ),
    child: const Text(
      'Cancelar',
      style: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
],
    );
  }

  Widget _iconoSitio(SitioAdminModel sitio) {
    final categoria = sitio.categoria;
    final color = AppColors.getIconColorForCategory(categoria?.nombre);

    return Container(
      width: 54,
      height: 54,
      color: color.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        AppColors.getIconForCategory(categoria?.nombre),
        color: color,
        size: 28,
      ),
    );
  }
}
