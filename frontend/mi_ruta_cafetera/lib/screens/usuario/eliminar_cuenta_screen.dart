import 'package:flutter/material.dart';

import '../../services/google_auth_service.dart';
import '../../services/usuario/perfil_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

// ============================================================
// ELIMINAR CUENTA
// ============================================================
//
// El backend elimina la cuenta de forma definitiva:
//  - Borra tus reseñas, favoritos, rutas, notificaciones,
//    reportes de ayuda, visitas y mapas sin conexión.
//  - Si tienes reservas activas o próximas (HTTP 409) NO la
//    elimina y no toca nada: hay que cancelarlas primero.
//  - Las reservas pasadas se conservan sin datos personales.
//
// Identidad:
//  - Cuenta con contraseña → se pide la contraseña.
//  - Cuenta de Google      → se confirma de nuevo con Google.
// ============================================================

class EliminarCuentaScreen extends StatefulWidget {
  const EliminarCuentaScreen({
    super.key,
  });

  @override
  State<EliminarCuentaScreen> createState() =>
      _EliminarCuentaScreenState();
}

class _EliminarCuentaScreenState extends State<EliminarCuentaScreen> {
  final _passwordController = TextEditingController();

  bool _cargando = true;
  bool _cuentaGoogle = false;
  bool _comprendo = false;
  bool _ocultar = true;
  bool _eliminando = false;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarTipoCuenta();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _cargarTipoCuenta() async {
    final resultado = await PerfilUsuarioService.obtenerPerfil();

    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = false;

      if (resultado['exito'] == true) {
        _cuentaGoogle = resultado['cuentaGoogle'] == true;
        _errorCarga = null;
      } else {
        _errorCarga = (resultado['mensaje'] ?? '').toString();

        if (_errorCarga!.isEmpty) {
          _errorCarga = Textos.t('No fue posible verificar tu cuenta.');
        }
      }
    });
  }

  // ============================================================
  // ELIMINAR
  // ============================================================

  Future<void> _eliminar() async {
    if (_eliminando || !_comprendo) {
      return;
    }

    String? password;
    String? idToken;

    if (_cuentaGoogle) {
      try {
        // Se pide a Google una confirmación reciente: el backend
        // rechaza tokens de más de 10 minutos.
        final cuenta = await GoogleAuthService.instance.iniciarSesion();

        if (cuenta == null) {
          return;
        }

        idToken = await GoogleAuthService.instance.obtenerIdToken();
      } catch (_) {
        _mostrar(
          Textos.t('No se pudo confirmar tu identidad con Google.'),
          error: true,
        );
        return;
      }

      if (idToken == null || idToken.isEmpty) {
        _mostrar(
          Textos.t('Google no proporcionó una confirmación válida.'),
          error: true,
        );
        return;
      }
    } else {
      password = _passwordController.text;

      if (password.isEmpty) {
        _mostrar(Textos.t('Escribe tu contraseña para continuar.'), error: true);
        return;
      }
    }

    final confirmado = await _confirmarDefinitivo();

    if (confirmado != true || !mounted) {
      return;
    }

    setState(() => _eliminando = true);

    final resultado = await PerfilUsuarioService.eliminarCuenta(
      password: password,
      idToken: idToken,
    );

    if (!mounted) {
      return;
    }

    if (resultado['exito'] == true) {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      await UsuarioSesionService.instance.cerrarSesion();

      try {
        await GoogleAuthService.instance.cerrarSesion();
      } catch (_) {
        // Si no había sesión de Google, se ignora.
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Tr('Tu cuenta fue eliminada.'),
        ),
      );

      // Mi perfil vuelve solo a su versión pública al quedar
      // sin sesión.
      navigator.pop();
      return;
    }

    setState(() => _eliminando = false);

    final mensaje = (resultado['mensaje'] ?? '').toString();

    // Reservas activas o próximas: se explica en un diálogo.
    if (resultado['codigo'] == 409) {
      await _avisarReservasActivas(mensaje);
      return;
    }

    _mostrar(
      mensaje.isEmpty ? Textos.t('No fue posible eliminar la cuenta.') : mensaje,
      error: true,
    );
  }

  Future<void> _avisarReservasActivas(String mensaje) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Tr('Aún no puedes eliminar tu cuenta'),
          content: Text(
            mensaje.isEmpty
                ? Textos.t('Tienes reservas activas o próximas. Cancélalas o espera a que se completen y vuelve a intentarlo.')
                : mensaje,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Tr('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmarDefinitivo() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Tr('¿Eliminar tu cuenta?'),
          content: const Tr(
            'Se borrarán tu cuenta, tus reseñas y tus datos. Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Tr('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Tr('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrar(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? AppColors.error : null,
        content: Text(mensaje),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Tr('Eliminar cuenta'),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _errorCarga != null
                ? _construirError()
                : _construirContenido(),
      ),
    );
  }

  Widget _construirError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorCarga!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _cargando = true;
                  _errorCarga = null;
                });
                _cargarTipoCuenta();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Tr('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingXl),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(
                AppDimensions.cardRadius,
              ),
              border: Border.all(color: AppColors.error),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: AppDimensions.iconLg,
                    ),
                    SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Tr(
                        'Esta acción es definitiva',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingMd),
                Tr(
                  'Dejarás de poder entrar y tus datos personales (nombre, correo, teléfono, ciudad y avatar) se borrarán.\n\nSe eliminarán de forma definitiva tus reseñas y comentarios, favoritos, rutas, notificaciones, reportes de ayuda y mapas sin conexión.\n\nSi tienes reservas activas o próximas no podrás eliminar la cuenta hasta cancelarlas o completarlas. Las reservas anteriores se conservan como registro, sin tus datos personales.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sectionGap),
          CheckboxListTile(
            value: _comprendo,
            onChanged: _eliminando
                ? null
                : (v) => setState(() => _comprendo = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            title: const Tr(
              'Entiendo que no podré recuperar mi cuenta.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          if (_cuentaGoogle)
            const Tr(
              'Tu cuenta usa Google. Para continuar te pediremos confirmar tu identidad con Google.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            )
          else
            TextField(
              controller: _passwordController,
              obscureText: _ocultar,
              enabled: !_eliminando,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: Textos.t('Contraseña'),
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                  icon: Icon(
                    _ocultar
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              onSubmitted: (_) => _eliminar(),
            ),
          const SizedBox(height: AppDimensions.sectionGap),
          SizedBox(
            height: AppDimensions.buttonHeightLarge,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: (_comprendo && !_eliminando) ? _eliminar : null,
              icon: _eliminando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever_rounded),
              label: Text(
                _eliminando ? Textos.t('Eliminando…') : Textos.t('Eliminar mi cuenta'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
