import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../google/google_button.dart';
import '../../services/google_auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

/// Recibe el idToken de Google y debe autenticar contra el backend
/// (y navegar si todo sale bien). Si falla, debe lanzar una
/// `Exception` con un mensaje claro para la persona.
typedef AutenticarConGoogle = Future<void> Function(String idToken);

/// Botón "Continuar con Google" para los accesos de administrador y de
/// sitio turístico.
///
/// Reutiliza [GoogleAuthService] (la misma integración del login de
/// usuarios) y tiene el mismo aspecto: icono de Google, borde suave y
/// divisor "o". El widget solo obtiene el idToken; la validación de la
/// identidad y del tipo de cuenta la hace siempre el backend.
///
/// - Android / iOS: botón propio que abre el selector de cuentas.
/// - Web: botón oficial de Google; el resultado llega por
///   `authenticationEvents`.
class BotonGoogleLogin extends StatefulWidget {
  final AutenticarConGoogle onIdToken;

  /// Deshabilita el botón mientras otro proceso de acceso está activo.
  final bool bloqueado;

  /// Muestra el divisor "o" encima del botón.
  final bool mostrarDivisor;

  const BotonGoogleLogin({
    super.key,
    required this.onIdToken,
    this.bloqueado = false,
    this.mostrarDivisor = true,
  });

  @override
  State<BotonGoogleLogin> createState() => _BotonGoogleLoginState();
}

class _BotonGoogleLoginState extends State<BotonGoogleLogin> {
  bool _cargando = false;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _suscripcionWeb;

  bool get _ocupado => _cargando || widget.bloqueado;

  @override
  void initState() {
    super.initState();

    // Mientras este acceso privado esté visible, el login de
    // visitantes no debe atender los eventos de Google.
    GoogleAuthService.instance.iniciarAccesoPrivado();

    if (kIsWeb) {
      _suscripcionWeb = GoogleSignIn.instance.authenticationEvents.listen(
        _manejarEventoWeb,
        onError: (Object error) {
          debugPrint('Error de Google Sign-In Web: $error');

          if (!mounted) {
            return;
          }

          _establecerCargando(false);
          _mostrarMensaje(Textos.t('No fue posible iniciar sesión con Google.'));
        },
      );
    }
  }

  @override
  void dispose() {
    _suscripcionWeb?.cancel();
    GoogleAuthService.instance.terminarAccesoPrivado();
    super.dispose();
  }

  void _establecerCargando(bool valor) {
    if (!mounted) {
      return;
    }

    setState(() => _cargando = valor);
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  String _textoError(Object error) {
    final texto = error.toString().replaceFirst('Exception: ', '');

    if (texto.startsWith('ClientException') ||
        texto.startsWith('SocketException') ||
        texto.startsWith('TimeoutException') ||
        texto.contains('XMLHttpRequest')) {
      return Textos.t('No fue posible conectarse con el servidor. Revisa tu conexión e inténtalo de nuevo.');
    }

    return texto;
  }

  // Con la sesión de Google ya iniciada: obtiene el idToken y deja
  // que la pantalla lo valide con el backend.
  Future<void> _completar() async {
    final idToken = await GoogleAuthService.instance.obtenerIdToken();

    if (idToken == null || idToken.isEmpty) {
      _mostrarMensaje(Textos.t('No se pudo obtener el token de Google.'));
      return;
    }

    try {
      await widget.onIdToken(idToken);
    } catch (error) {
      _mostrarMensaje(_textoError(error));
    } finally {
      // No se conserva la sesión de Google: así la próxima vez se
      // puede elegir otra cuenta.
      try {
        await GoogleAuthService.instance.cerrarSesion();
      } catch (_) {}
    }
  }

  // Android / iOS
  Future<void> _iniciarEnMovil() async {
    if (kIsWeb || _ocupado) {
      return;
    }

    _establecerCargando(true);

    try {
      final cuenta = await GoogleAuthService.instance.iniciarSesion();

      if (!mounted) {
        return;
      }

      if (cuenta == null) {
        _mostrarMensaje(Textos.t('Google no devolvió ninguna cuenta.'));
        return;
      }

      await _completar();
    } on GoogleSignInException catch (error) {
      debugPrint(
        'GoogleSignInException: ${error.code} ${error.description}',
      );

      // Si la persona cierra la ventana de Google no es un error.
      if (error.code.name == 'canceled') {
        return;
      }

      _mostrarMensaje(
        Textos.t('No fue posible iniciar sesión con Google: {0}', [error.description ?? error.code.name]),
      );
    } catch (error) {
      debugPrint('Error inesperado con Google: $error');
      _mostrarMensaje(Textos.t('No fue posible iniciar sesión con Google.'));
    } finally {
      _establecerCargando(false);
    }
  }

  // Web
  Future<void> _manejarEventoWeb(
    GoogleSignInAuthenticationEvent evento,
  ) async {
    if (evento is! GoogleSignInAuthenticationEventSignIn) {
      return;
    }

    if (!mounted || _ocupado) {
      return;
    }

    _establecerCargando(true);

    GoogleAuthService.instance.registrarUsuario(evento.user);

    try {
      await _completar();
    } finally {
      _establecerCargando(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.mostrarDivisor) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                ),
                child: Text(
                  'o',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
        ],
        _boton(),
      ],
    );
  }

  Widget _boton() {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: _cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : crearBotonGoogleWeb(),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: _ocupado ? null : _iniciarEnMovil,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_cargando)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const FaIcon(
                FontAwesomeIcons.google,
                size: 20,
                color: Color(0xFF4285F4),
              ),
            const SizedBox(width: AppDimensions.spacingMd),
            Text(
              _cargando
                  ? Textos.t('Conectando con Google...')
                  : Textos.t('Continuar con Google'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
