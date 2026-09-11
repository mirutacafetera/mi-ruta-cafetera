import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const String _webClientId =
      '765107425604-urm7avuobo7fdo27l3sjrmilulgtcsjf.apps.googleusercontent.com';

  bool _initialized = false;

  GoogleSignInAccount? _usuarioActual;

  StreamSubscription<GoogleSignInAuthenticationEvent>?
      _authenticationSubscription;

  /// Inicializa Google Sign-In.
  ///
  /// En Web se utiliza clientId.
  /// En Android se utiliza serverClientId.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (kIsWeb) {
      await _googleSignIn.initialize(
        clientId: _webClientId,
      );
    } else {
      await _googleSignIn.initialize(
        serverClientId: _webClientId,
      );
    }

    _authenticationSubscription =
        _googleSignIn.authenticationEvents.listen(
      _manejarEventoAutenticacion,
      onError: _manejarErrorAutenticacion,
    );

    _initialized = true;
  }

  /// Maneja los cambios de autenticación.
  void _manejarEventoAutenticacion(
    GoogleSignInAuthenticationEvent evento,
  ) {
    if (evento is GoogleSignInAuthenticationEventSignIn) {
      _usuarioActual = evento.user;
    } else if (evento is GoogleSignInAuthenticationEventSignOut) {
      _usuarioActual = null;
    }
  }

  /// Maneja errores de autenticación.
  void _manejarErrorAutenticacion(Object error) {
    debugPrint('Error de Google Sign-In: $error');
  }

  /// Inicia sesión con Google.
  Future<GoogleSignInAccount?> iniciarSesion() async {
    await initialize();

    try {
      final usuario = await _googleSignIn.authenticate();

      _usuarioActual = usuario;

      return usuario;
    } on GoogleSignInException {
      rethrow;
    }
  }

  /// Intenta recuperar una sesión existente.
  Future<GoogleSignInAccount?> recuperarSesion() async {
    await initialize();

    try {
      final usuario =
          await _googleSignIn.attemptLightweightAuthentication();

      if (usuario != null) {
        _usuarioActual = usuario;
      }

      return usuario;
    } on GoogleSignInException {
      return null;
    }
  }

  /// Usuario actualmente autenticado.
  GoogleSignInAccount? get usuarioActual {
    return _usuarioActual;
  }

  /// Obtiene el ID Token del usuario autenticado.
  Future<String?> obtenerIdToken() async {
    final usuario = _usuarioActual;

    if (usuario == null) {
      return null;
    }

    final autenticacion = usuario.authentication;

    return autenticacion.idToken;
  }

  /// Cierra la sesión de Google.
  Future<void> cerrarSesion() async {
    await initialize();

    await _googleSignIn.signOut();

    _usuarioActual = null;
  }

  /// Indica si hay un usuario autenticado.
  bool get estaAutenticado {
    return _usuarioActual != null;
  }

  /// Libera los recursos del servicio.
  Future<void> dispose() async {
    await _authenticationSubscription?.cancel();

    _authenticationSubscription = null;
  }
}