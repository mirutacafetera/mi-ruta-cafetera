
import 'package:flutter/material.dart';

import '../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/admin/cuenta/foto_perfil.dart';
import '../../widgets/admin/fondo_admin.dart';

class AdminInicio extends StatelessWidget {
  final String nombre;
  final String email;
  final FotoPerfilAdminControlador fotoPerfilControlador;
  final VoidCallback onAbrirMapa;
  final VoidCallback onGestionarSitios;
  final VoidCallback onGestionarUsuarios;
  final VoidCallback onAbrirCuenta;

  const AdminInicio({
    super.key,
    required this.nombre,
    required this.email,
    required this.fotoPerfilControlador,
    required this.onAbrirMapa,
    required this.onGestionarSitios,
    required this.onGestionarUsuarios,
    required this.onAbrirCuenta,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final fondoTarjeta =
        oscuro ? colores.surface : AppColors.creamLight;

    return FondoAdmin(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pageHorizontalSmall,
          AppDimensions.spacingLg,
          AppDimensions.pageHorizontalSmall,
          AppDimensions.spacingXxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _encabezado(),
            const SizedBox(height: AppDimensions.sectionGap),

            _tituloSeccion(
              colorTexto: colores.onSurface,
              colorSecundario: colores.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            _tarjetaOpcion(
              context: context,
              fondo: fondoTarjeta,
              icono: Icons.map_outlined,
              titulo: 'Mapa turístico',
              descripcion: 'Explora los destinos de la ruta cafetera.',
              color: AppColors.primary,
              fondoIcono: AppColors.sitioSurfaceGreen,
              onTap: onAbrirMapa,
            ),

            _tarjetaOpcion(
              context: context,
              fondo: fondoTarjeta,
              icono: Icons.place_outlined,
              titulo: 'Gestionar sitios',
              descripcion: 'Administra los sitios turísticos.',
              color: AppColors.cafeOscuro,
              fondoIcono: AppColors.orangeSoft,
              onTap: onGestionarSitios,
            ),

            _tarjetaOpcion(
              context: context,
              fondo: fondoTarjeta,
              icono: Icons.people_outline_rounded,
              titulo: 'Gestionar usuarios',
              descripcion: 'Consulta los usuarios registrados.',
              color: AppColors.nature,
              fondoIcono: AppColors.sitioSurfaceGreen,
              onTap: onGestionarUsuarios,
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.adminBorder.withValues(alpha: 0.7),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                  ),
                  child: Icon(
                    Icons.coffee_rounded,
                    color: AppColors.tertiary,
                    size: AppDimensions.iconSm,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.adminBorder.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            _tarjetaCuenta(
              fondo: fondoTarjeta,
              colorTexto: colores.onSurface,
              colorSecundario: colores.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    final primerNombre = nombre.trim().isEmpty
        ? 'Administrador'
        : nombre.trim().split(RegExp(r'\s+')).first;

    const cafe = Color(0xFF795548);
    const cafeOscuro = Color(0xFF4E342E);
    const crema = Color(0xFFFFF4E5);


    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            crema,
            Color.fromARGB(255, 251, 233, 211),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: cafe.withValues(alpha: 0.75),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: cafe.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '¡Hola, $primerNombre!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: cafeOscuro,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
             const Icon(
  Icons.coffee_rounded,
  color: cafeOscuro,
  size: 27,
),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            'Bienvenido al panel de administración '
            'de Mi Ruta Cafetera.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cafe,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSeccion({
    required Color colorTexto,
    required Color colorSecundario,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos rápidos',
          style: TextStyle(
            color: colorTexto,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          '¿Qué deseas administrar hoy?',
          style: TextStyle(
            color: colorSecundario,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _tarjetaOpcion({
    required BuildContext context,
    required Color fondo,
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    required Color fondoIcono,
    required VoidCallback onTap,
  }) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.adminBorder.withValues(alpha: 0.85),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.3),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingLg,
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: fondoIcono,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: AppDimensions.iconLg,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          color: colores.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        descripcion,
                        style: TextStyle(
                          color: colores.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color,
                  size: AppDimensions.iconLg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaCuenta({
    required Color fondo,
    required Color colorTexto,
    required Color colorSecundario,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.adminBorder,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: InkWell(
          onTap: onAbrirCuenta,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 1.7,
                    ),
                  ),
                  child: ClipOval(
                    child: FotoPerfil(
                      controlador: fotoPerfilControlador,
                      radio: AppDimensions.profileAvatarSmall / 2,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre.trim().isEmpty
                            ? 'Administrador'
                            : nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorTexto,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorSecundario,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Ver mi cuenta',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: AppDimensions.iconLg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
