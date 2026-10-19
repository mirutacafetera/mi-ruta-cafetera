import 'package:flutter/material.dart';

import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/favorito_service.dart';
import '../../services/ruta_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/sitio_avatar_perfil.dart';
import '../usuario/crear_avatar_screen.dart';
import '../usuario/editar_perfil_screen.dart';
import '../usuario/eliminar_cuenta_screen.dart';
import '../usuario/favoritos_usuario_screen.dart';
import '../usuario/preferencias_screen.dart';
import '../usuario/rutas_usuario_screen.dart';

class PerfilPublicoScreen extends StatelessWidget {
  const PerfilPublicoScreen({
    super.key,
  });

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
            if (sesion == null) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(
                  AppDimensions.pageHorizontal,
                ),
                child: _construirPublico(context),
              );
            }

            return _PerfilCuenta(sesion: sesion);
          },
        ),
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
// PERFIL CON SESIÓN
// ======================================================================

class _PerfilCuenta extends StatefulWidget {
  final UsuarioSesionModel sesion;

  const _PerfilCuenta({
    required this.sesion,
  });

  @override
  State<_PerfilCuenta> createState() => _PerfilCuentaState();
}

class _PerfilCuentaState extends State<_PerfilCuenta> {
  // null = cargando; -1 = no disponible (no se inventan cifras).
  int? _favoritos;
  int? _rutas;

  static const int _noDisponible = -1;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  @override
  void didUpdateWidget(covariant _PerfilCuenta oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sesion.id != widget.sesion.id) {
      _cargarResumen();
    }
  }

  // ============================================================
  // RESUMEN (datos reales)
  // ============================================================

  Future<void> _cargarResumen() async {
    final sesion = widget.sesion;

    setState(() {
      _favoritos = null;
      _rutas = null;
    });

    final resultados = await Future.wait<int>([
      _contarFavoritos(sesion),
      _contarRutas(sesion),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _favoritos = resultados[0];
      _rutas = resultados[1];
    });
  }

  Future<int> _contarFavoritos(UsuarioSesionModel sesion) async {
    try {
      final lista = await FavoritoService.instance.obtenerFavoritos(
        sesion.id,
        token: sesion.token,
      );

      return lista.length;
    } catch (_) {
      return _noDisponible;
    }
  }

  // Mismo criterio que "Mis rutas": personalizadas y activas.
  Future<int> _contarRutas(UsuarioSesionModel sesion) async {
    try {
      final lista = await RutaService().obtenerRutasPorUsuario(
        sesion.id,
        token: sesion.token,
      );

      return lista
          .where((r) => r.tipo == 'personalizada' && r.activa)
          .length;
    } catch (_) {
      return _noDisponible;
    }
  }

  // ============================================================
  // NAVEGACIÓN
  // ============================================================

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );

    if (mounted) {
      // Favoritos y rutas pueden haber cambiado.
      _cargarResumen();
    }
  }

  Future<void> _abrirFavoritos() {
    return _abrir(
      FavoritosUsuarioScreen(
        usuarioId: widget.sesion.id,
        token: widget.sesion.token,
      ),
    );
  }

  Future<void> _abrirRutas() {
    return _abrir(
      RutasUsuarioScreen(
        usuarioId: widget.sesion.id,
        token: widget.sesion.token,
      ),
    );
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> _cerrarSesion() async {
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
    // También cierra Google Sign-In. El Shell escucha el cambio de
    // sesión, descarta las pantallas privadas y vuelve al Inicio.
    await UsuarioSesionService.instance.cerrarSesionCompleta();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final sesion = widget.sesion;

    final nombre = sesion.nombreCompleto.isEmpty
        ? 'Viajero'
        : sesion.nombreCompleto;

    return RefreshIndicator(
      onRefresh: _cargarResumen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.pageHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _construirCabecera(sesion, nombre),
            const SizedBox(
              height: AppDimensions.spacingLg,
            ),
            Row(
              children: [
                Expanded(
                  child: _TarjetaResumen(
                    icono: Icons.favorite_rounded,
                    titulo: 'Favoritos',
                    valor: _favoritos,
                    onTap: _abrirFavoritos,
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Expanded(
                  child: _TarjetaResumen(
                    icono: Icons.route_rounded,
                    titulo: 'Rutas creadas',
                    valor: _rutas,
                    onTap: _abrirRutas,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppDimensions.sectionGap,
            ),
            const _TituloSeccion('Mi cuenta'),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            _OpcionCuenta(
              icono: Icons.favorite_rounded,
              titulo: 'Mis favoritos',
              descripcion: 'Los lugares que guardaste.',
              onTap: _abrirFavoritos,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            _OpcionCuenta(
              icono: Icons.route_rounded,
              titulo: 'Mis rutas',
              descripcion: 'Tus recorridos por el Huila.',
              onTap: _abrirRutas,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            _OpcionCuenta(
              icono: Icons.edit_rounded,
              titulo: 'Editar perfil',
              descripcion: 'Nombre, teléfono y ciudad.',
              onTap: () => _abrir(const EditarPerfilScreen()),
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            _OpcionCuenta(
              icono: Icons.face_retouching_natural_rounded,
              titulo: 'Mi avatar cafetero',
              descripcion: 'Crea y personaliza tu avatar.',
              onTap: () => _abrir(const CrearAvatarScreen()),
            ),
            const SizedBox(
              height: AppDimensions.sectionGap,
            ),
            const _TituloSeccion('Aplicación'),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            _OpcionCuenta(
              icono: Icons.text_fields_rounded,
              titulo: 'Preferencias',
              descripcion: 'Tamaño del texto.',
              onTap: () => _abrir(const PreferenciasScreen()),
            ),
            const SizedBox(
              height: AppDimensions.sectionGap,
            ),
            SizedBox(
              height: AppDimensions.buttonHeightLarge,
              child: OutlinedButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(
                  Icons.logout_rounded,
                ),
                label: const Text(
                  'Cerrar sesión',
                ),
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            TextButton.icon(
              onPressed: () => _abrir(const EliminarCuentaScreen()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
              label: const Text(
                'Eliminar mi cuenta',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CABECERA CON AVATAR
  // ============================================================
  //
  // Prioridad: avatar cafetero (si el usuario lo activó) →
  // foto de Google → ícono de persona.
  // ============================================================

  Widget _construirCabecera(
    UsuarioSesionModel sesion,
    String nombre,
  ) {
    const radio = AppDimensions.profileAvatarSize / 2;

    return Container(
      width: double.infinity,
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
          GestureDetector(
            onTap: () => _abrir(const CrearAvatarScreen()),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: SitioAvatarPerfil(
                    fotoPerfil: sesion.fotoPerfil,
                    avatar: sesion.avatar,
                    nombre: sesion.nombreCompleto,
                    radio: radio,
                    colorFondo: AppColors.cream,
                    colorIcono: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingXs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceGreen,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: AppDimensions.iconSm,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}

// ======================================================================
// TÍTULO DE SECCIÓN
// ======================================================================

class _TituloSeccion extends StatelessWidget {
  final String texto;

  const _TituloSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ======================================================================
// TARJETA DE RESUMEN
// ======================================================================
//
// valor == null  → cargando
// valor < 0      → dato no disponible (se muestra "—")
// ======================================================================

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final int? valor;
  final VoidCallback onTap;

  const _TarjetaResumen({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget contenido;

    if (valor == null) {
      contenido = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    } else {
      contenido = Text(
        valor! < 0 ? '—' : '$valor',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      );
    }

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
          child: Column(
            children: [
              Icon(
                icono,
                color: AppColors.secondary,
                size: AppDimensions.iconLg,
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              SizedBox(
                height: 32,
                child: Center(child: contenido),
              ),
              const SizedBox(
                height: AppDimensions.spacingXs,
              ),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
