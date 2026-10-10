import 'package:flutter/material.dart';

import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/google_auth_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../usuario/favoritos_usuario_screen.dart';
import '../usuario/rutas_usuario_screen.dart';

class PerfilPublicoScreen extends StatelessWidget {
  const PerfilPublicoScreen({
    super.key,
  });

  // ============================================================
  // ABRIR FAVORITOS
  // ============================================================

  void _abrirFavoritos(
    BuildContext context,
    UsuarioSesionModel sesion,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritosUsuarioScreen(
          usuarioId: sesion.id,
          token: sesion.token,
        ),
      ),
    );
  }

  // ============================================================
  // ABRIR RUTAS
  // ============================================================

  void _abrirRutas(
    BuildContext context,
    UsuarioSesionModel sesion,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RutasUsuarioScreen(
          usuarioId: sesion.id,
          token: sesion.token,
        ),
      ),
    );
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> _cerrarSesion(
    BuildContext context,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cerrar sesión',
          ),
          content: const Text(
            '¿Deseas cerrar tu sesión?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Cerrar sesión',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    // Al limpiar la sesión, esta pantalla vuelve sola a
    // su versión pública gracias a sesionActual.
    await UsuarioSesionService.instance.cerrarSesion();

    try {
      await GoogleAuthService.instance.cerrarSesion();
    } catch (_) {
      // Si no había sesión de Google, se ignora.
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Mi perfil',
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<UsuarioSesionModel?>(
          valueListenable:
              UsuarioSesionService.instance.sesionActual,
          builder: (context, sesion, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.pageHorizontal,
              ),
              child: sesion == null
                  ? _construirPublico(context)
                  : _construirCuenta(context, sesion),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PERFIL CON SESIÓN
  // ============================================================

  Widget _construirCuenta(
    BuildContext context,
    UsuarioSesionModel sesion,
  ) {
    final nombre = sesion.nombreCompleto.isEmpty
        ? 'Viajero'
        : sesion.nombreCompleto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(
            AppDimensions.spacingXxl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceGreen,
            borderRadius: BorderRadius.circular(
              AppDimensions.heroRadius,
            ),
          ),
          child: Column(
            children: [
              _construirAvatar(sesion),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              Text(
                nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXs,
              ),
              Text(
                sesion.correo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textOnDarkSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: AppDimensions.sectionGap,
        ),
        const Text(
          'Mi cuenta',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        _OpcionCuenta(
          icono: Icons.favorite_rounded,
          titulo: 'Mis favoritos',
          descripcion: 'Los lugares que guardaste.',
          onTap: () => _abrirFavoritos(context, sesion),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        _OpcionCuenta(
          icono: Icons.route_rounded,
          titulo: 'Mis rutas',
          descripcion: 'Tus recorridos por el Huila.',
          onTap: () => _abrirRutas(context, sesion),
        ),
        const SizedBox(
          height: AppDimensions.sectionGap,
        ),
        SizedBox(
          height: AppDimensions.buttonHeightLarge,
          child: OutlinedButton.icon(
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(
              Icons.logout_rounded,
            ),
            label: const Text(
              'Cerrar sesión',
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================
  //
  // Usa la foto de perfil (Google) si existe. Si no carga,
  // por ejemplo por CORS en Web, muestra el icono.
  // ============================================================

  Widget _construirAvatar(
    UsuarioSesionModel sesion,
  ) {
    const icono = Icon(
      Icons.person_rounded,
      size: 48,
      color: AppColors.primary,
    );

    return Container(
      width: AppDimensions.profileAvatarSize,
      height: AppDimensions.profileAvatarSize,
      decoration: BoxDecoration(
        color: AppColors.cream,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: sesion.fotoPerfil.isEmpty
          ? icono
          : Image.network(
              sesion.fotoPerfil,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => icono,
            ),
    );
  }

  // ============================================================
  // PERFIL SIN SESIÓN (SE CONSERVA EL DISEÑO ACTUAL)
  // ============================================================

  Widget _construirPublico(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(
            AppDimensions.spacingXxl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceGreen,
            borderRadius: BorderRadius.circular(
              AppDimensions.heroRadius,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: AppDimensions.profileAvatarSize,
                height: AppDimensions.profileAvatarSize,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              const Text(
                'Tu perfil de viajero',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              const Text(
                'Inicia sesión para disfrutar '
                'una experiencia personalizada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textOnDarkSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: AppDimensions.sectionGap,
        ),
        const Text(
          'Accede a tu cuenta',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingSm,
        ),
        const Text(
          'Guarda tus experiencias y disfruta '
          'tu recorrido por el Huila.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingXl,
        ),
        SizedBox(
          height: AppDimensions.buttonHeightLarge,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/login-usuario',
              );
            },
            icon: const Icon(
              Icons.login_rounded,
            ),
            label: const Text(
              'Iniciar sesión',
            ),
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        SizedBox(
          height: AppDimensions.buttonHeightLarge,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/registro-usuario',
              );
            },
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
            ),
            label: const Text(
              'Crear una cuenta',
            ),
          ),
        ),
        const SizedBox(
          height: AppDimensions.sectionGap,
        ),
        Container(
          padding: const EdgeInsets.all(
            AppDimensions.spacingXl,
          ),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.explore_rounded,
                color: AppColors.secondary,
                size: AppDimensions.iconLg,
              ),
              SizedBox(
                width: AppDimensions.spacingMd,
              ),
              Expanded(
                child: Text(
                  'Explora lugares, descubre nuevas '
                  'experiencias y construye tu propia '
                  'ruta por el Huila.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// OPCIÓN DE CUENTA
// ======================================================================

class _OpcionCuenta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _OpcionCuenta({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(
        AppDimensions.cardRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            AppDimensions.spacingLg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icono,
                color: AppColors.secondary,
                size: AppDimensions.iconLg,
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
                      titulo,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacingXs,
                    ),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}