import 'package:flutter/material.dart';

import '../../../models/admin/sitio_admin_model.dart';
import '../../../models/admin/cuenta_sitio_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class TarjetaCuentaSitio extends StatelessWidget {
  final SitioAdminModel sitio;
  final CuentaSitioModel? cuenta;
  final VoidCallback onCrearCuenta;
  final VoidCallback? onEditar;
  final VoidCallback? onCambiarEstado;
  final VoidCallback? onEliminar;

  const TarjetaCuentaSitio({
    super.key,
    required this.sitio,
    required this.cuenta,
    required this.onCrearCuenta,
    this.onEditar,
    this.onCambiarEstado,
    this.onEliminar,
  });

  static const Color _cafe = Color(0xFFB58A70);
  static const double _tamanoImagen = 104;

  @override
  Widget build(BuildContext context) {
    final tieneCuenta = cuenta != null;
    final activa = cuenta?.activo ?? false;
    final categoria = sitio.categoria;
    final colorCategoria =
        AppColors.getIconColorForCategory(categoria?.nombre);

    final colorEstado = !tieneCuenta
        ? AppColors.warning
        : activa
            ? AppColors.success
            : AppColors.error;

    final textoEstado = !tieneCuenta
        ? 'Sin cuenta'
        : activa
            ? 'Activa'
            : 'Inactiva';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingSm,
      ),
      color: AppColors.surface,
      elevation: 2,
      shadowColor: _cafe.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _cafe, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _construirImagenSitio(),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sitio.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${sitio.ciudad}, ${sitio.departamento}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (categoria?.nombre.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _obtenerIconoCategoria(categoria?.icono),
                              size: 16,
                              color: colorCategoria,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                categoria!.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colorCategoria,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colorEstado,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              textoEstado,
                              style: TextStyle(
                                color: colorEstado,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (tieneCuenta)
                  PopupMenuButton<String>(
                    tooltip: 'Acciones',
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),
                    onSelected: (accion) {
                      switch (accion) {
                        case 'editar':
                          onEditar?.call();
                          break;
                        case 'estado':
                          onCambiarEstado?.call();
                          break;
                        case 'eliminar':
                          onEliminar?.call();
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar cuenta'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'estado',
                        child: ListTile(
                          leading: Icon(
                            activa
                                ? Icons.block
                                : Icons.check_circle_outline,
                          ),
                          title: Text(
                            activa
                                ? 'Desactivar cuenta'
                                : 'Activar cuenta',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          title: Text(
                            'Eliminar sitio y cuenta',
                            style: TextStyle(color: AppColors.error),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (tieneCuenta) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                decoration: BoxDecoration(
                  color: _cafe.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _dato(
                      Icons.person_outline,
                      cuenta!.nombreCompleto,
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    _dato(
                      Icons.email_outlined,
                      cuenta!.correo,
                    ),
                    if (cuenta!.telefono.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      _dato(
                        Icons.phone_outlined,
                        cuenta!.telefono,
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: AppDimensions.spacingMd),
              const Text(
                'Este sitio todavía no tiene una cuenta de acceso.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onCrearCuenta,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Crear cuenta'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirImagenSitio() {
    if (sitio.imagen.trim().isNotEmpty) {
      return Image.network(
        sitio.imagen,
        width: _tamanoImagen,
        height: _tamanoImagen,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _iconoSitio(),
      );
    }

    return _iconoSitio();
  }

  Widget _iconoSitio() {
    final categoria = sitio.categoria;
    final color = AppColors.getIconColorForCategory(categoria?.nombre);

    return Container(
      width: _tamanoImagen,
      height: _tamanoImagen,
      color: color.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Icon(
        _obtenerIconoCategoria(categoria?.icono),
        size: 58,
        color: color,
      ),
    );
  }

  IconData _obtenerIconoCategoria(String? nombreIcono) {
    const iconos = <String, IconData>{
      'coffee_rounded': Icons.coffee_rounded,
      'local_cafe_rounded': Icons.local_cafe_rounded,
      'landscape_rounded': Icons.landscape_rounded,
      'terrain_rounded': Icons.terrain_rounded,
      'hiking_rounded': Icons.hiking_rounded,
      'park_rounded': Icons.park_rounded,
      'forest_rounded': Icons.forest_rounded,
      'nature_rounded': Icons.nature_rounded,
      'family_restroom_rounded': Icons.family_restroom_rounded,
      'photo_camera_rounded': Icons.photo_camera_rounded,
      'palette_rounded': Icons.palette_rounded,
      'museum_rounded': Icons.museum_rounded,
      'restaurant_rounded': Icons.restaurant_rounded,
      'place_rounded': Icons.place_rounded,
      'attractions_rounded': Icons.attractions_rounded,
    };

    return iconos[nombreIcono] ??
        AppColors.getIconForCategory(sitio.categoria?.nombre);
  }

  Widget _dato(IconData icono, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          size: AppDimensions.iconSm,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}