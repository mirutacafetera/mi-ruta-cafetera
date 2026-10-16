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

  @override
  Widget build(BuildContext context) {
    final tieneCuenta = cuenta != null;
    final activa = cuenta?.activo ?? false;

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
        vertical: AppDimensions.spacingXs,
      ),
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        side: BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: sitio.imagen.isNotEmpty
                      ? Image.network(
                          sitio.imagen,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _iconoSitio(),
                        )
                      : _iconoSitio(),
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        sitio.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingXs,
                      ),
                      Text(
                        '${sitio.ciudad}, ${sitio.departamento}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          textoEstado,
                          style: TextStyle(
                            color: colorEstado,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (tieneCuenta)
                  PopupMenuButton<String>(
                    tooltip: 'Acciones',
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
                            style: TextStyle(
                              color: AppColors.error,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (tieneCuenta) ...[
              const Divider(
                height: AppDimensions.spacingXl,
              ),
              _dato(
                Icons.person_outline,
                cuenta!.nombreCompleto,
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              _dato(
                Icons.email_outlined,
                cuenta!.correo,
              ),
              if (cuenta!.telefono.isNotEmpty) ...[
                const SizedBox(
                  height: AppDimensions.spacingSm,
                ),
                _dato(
                  Icons.phone_outlined,
                  cuenta!.telefono,
                ),
              ],
            ] else ...[
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              const Text(
                'Este sitio todavía no tiene una cuenta de acceso.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onCrearCuenta,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Crear cuenta'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String texto) {
    return Row(
      children: [
        Icon(
          icono,
          size: AppDimensions.iconSm,
          color: AppColors.textSecondary,
        ),
        const SizedBox(
          width: AppDimensions.spacingSm,
        ),
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

  Widget _iconoSitio() {
    return Container(
      width: 76,
      height: 76,
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(
        Icons.landscape_outlined,
        size: 34,
        color: AppColors.primary,
      ),
    );
  }
}