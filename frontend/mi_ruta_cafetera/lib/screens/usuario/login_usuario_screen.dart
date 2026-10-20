import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../google/google_button.dart';
import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/google_auth_service.dart';
import '../../services/usuario/auth_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../publico/public_shell_screen.dart';
import 'recuperar_password_screen.dart';
import 'registro_usuario_screen.dart';

class LoginUsuarioScreen extends StatefulWidget {
  const LoginUsuarioScreen({super.key});

  @override
  State<LoginUsuarioScreen> createState() => _LoginUsuarioScreenState();
}

class _LoginUsuarioScreenState extends State<LoginUsuarioScreen> {
  // ============================================================
  // RECURSOS
  // ============================================================

  static const String _assetFondo = 'assets/img/fondo-i-sesion.png';
  static const String _assetLogo = 'assets/img/iconoia.png';

  // ============================================================
  // CONTROLADORES
  // ============================================================

  final TextEditingController correoController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool cargando = false;
  bool ocultarPassword = true;
  bool _iniciandoGoogle = false;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleWebSub;

  bool get _ocupado => cargando || _iniciandoGoogle;

  @override
  void initState() {
    super.initState();

    // En Web el botón oficial de Google inicia el proceso y el
    // resultado llega por authenticationEvents (igual que en la
    // pantalla de bienvenida).
    if (kIsWeb) {
      _googleWebSub = GoogleSignIn.instance.authenticationEvents.listen(
        _manejarEventoGoogleWeb,
        onError: (Object error) {
          debugPrint('Error de Google Sign-In Web: $error');

          if (!mounted) return;

          setState(() => _iniciandoGoogle = false);
          _mostrarMensaje('No fue posible iniciar sesión con Google.');
        },
      );
    }
  }

  // ============================================================
  // INICIAR SESIÓN (CORREO Y CONTRASEÑA)
  // ============================================================

  Future<void> _iniciarSesion() async {
    if (_ocupado) {
      return;
    }

    final correo = correoController.text.trim();
    final password = passwordController.text;

    if (correo.isEmpty) {
      _mostrarMensaje('Ingresa tu correo electrónico');
      return;
    }

    if (password.isEmpty) {
      _mostrarMensaje('Ingresa tu contraseña');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      cargando = true;
    });

    final resultado = await AuthUsuarioService.iniciarSesion(
      correo: correo,
      password: password,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      cargando = false;
    });

    if (resultado['exito'] == true) {
      final usuario = resultado['usuario'];
      final token = resultado['token'];

      if (usuario is! Map || token == null) {
        _mostrarMensaje('El servidor no devolvió los datos de usuario');
        return;
      }

      final sesion = UsuarioSesionModel.fromRespuesta(
        token: token.toString(),
        usuario: Map<String, dynamic>.from(usuario),
      );

      await UsuarioSesionService.instance.guardarSesion(sesion);

      if (!mounted) {
        return;
      }

      _irAlInicio();
    } else {
      _mostrarMensaje(resultado['mensaje'] ?? 'No fue posible iniciar sesión');
    }
  }

  // Con la sesión guardada, el Shell muestra el menú de 5
  // opciones. Se limpia la pila para que "atrás" no regrese
  // al login ni al registro.
  void _irAlInicio() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PublicShellScreen()),
      (ruta) => false,
    );
  }

  // ============================================================
  // GOOGLE → BACKEND → SESIÓN
  // ============================================================
  //
  // Reutiliza el flujo existente: GoogleAuthService obtiene el
  // idToken y AuthUsuarioService lo valida contra
  // POST /api/usuarios/login-google. Devuelve true si guardó sesión.
  // ============================================================

  Future<bool> _autenticarConBackend() async {
    final idToken = await GoogleAuthService.instance.obtenerIdToken();
    debugPrint('[LoginGoogle] idToken obtenido: ${idToken != null && idToken.isNotEmpty}');

    if (idToken == null || idToken.isEmpty) {
      if (mounted) {
        _mostrarMensaje('No se pudo obtener el token de Google.');
      }
      return false;
    }

    final resultado = await AuthUsuarioService.iniciarSesionConGoogle(
      idToken: idToken,
    );

    debugPrint('[LoginGoogle] respuesta backend: exito=${resultado['exito']} mensaje=${resultado['mensaje']}');

    if (resultado['exito'] != true ||
        resultado['usuario'] is! Map ||
        resultado['token'] == null) {
      if (mounted) {
        _mostrarMensaje(
          resultado['mensaje']?.toString() ??
              'No fue posible iniciar sesión con Google.',
        );
      }
      return false;
    }

    await UsuarioSesionService.instance.guardarSesion(
      UsuarioSesionModel.fromRespuesta(
        token: resultado['token'].toString(),
        usuario: Map<String, dynamic>.from(resultado['usuario'] as Map),
      ),
    );

    return true;
  }

  // Android / iOS
  Future<void> _iniciarSesionConGoogle() async {
    debugPrint('[LoginGoogle] toque. web=$kIsWeb ocupado=$_ocupado');

    if (kIsWeb || _ocupado) {
      return;
    }

    setState(() => _iniciandoGoogle = true);

    try {
      debugPrint('[LoginGoogle] abriendo Google...');
      final cuenta = await GoogleAuthService.instance.iniciarSesion();
      debugPrint('[LoginGoogle] Google respondió: ${cuenta?.email}');

      if (!mounted) return;

      if (cuenta == null) {
        setState(() => _iniciandoGoogle = false);
        _mostrarMensaje('Google no devolvió ninguna cuenta.');
        return;
      }

      final autenticado = await _autenticarConBackend();
      debugPrint('[LoginGoogle] backend autenticó: $autenticado');

      if (!mounted) return;

      setState(() => _iniciandoGoogle = false);

      if (autenticado) {
        _irAlInicio();
      }
    } on GoogleSignInException catch (e) {
      debugPrint('[LoginGoogle] GoogleSignInException: ${e.code} ${e.description}');

      if (!mounted) return;

      setState(() => _iniciandoGoogle = false);

      // Si la persona cierra la ventana de Google no es un error.
      if (e.code.name == 'canceled') {
        return;
      }

      _mostrarMensaje(
        'No fue posible iniciar sesión con Google: '
        '${e.description ?? e.code.name}',
      );
    } catch (e) {
      debugPrint('[LoginGoogle] error inesperado: $e');

      if (!mounted) return;

      setState(() => _iniciandoGoogle = false);
      _mostrarMensaje('No fue posible iniciar sesión con Google.');
    }
  }

  // Web
  Future<void> _manejarEventoGoogleWeb(
    GoogleSignInAuthenticationEvent evento,
  ) async {
    if (evento is! GoogleSignInAuthenticationEventSignIn) {
      return;
    }

    // Si otra pantalla (p. ej. la de bienvenida) ya atendió este mismo
    // evento y guardó la sesión, no se repite la validación.
    if (!mounted ||
        _iniciandoGoogle ||
        UsuarioSesionService.instance.sesionActual.value != null) {
      return;
    }

    setState(() => _iniciandoGoogle = true);

    GoogleAuthService.instance.registrarUsuario(evento.user);

    final autenticado = await _autenticarConBackend();

    if (!mounted) return;

    setState(() => _iniciandoGoogle = false);

    if (autenticado) {
      _irAlInicio();
    }
  }

  // ============================================================
  // MOSTRAR MENSAJE
  // ============================================================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ============================================================
  // LIBERAR CONTROLADORES
  // ============================================================

  @override
  void dispose() {
    _googleWebSub?.cancel();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // El fondo ocupa siempre la pantalla completa (no se encoge ni se
    // reescala cuando aparece el teclado).
    final altoPantalla = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==================================================
          // FONDO DIFUMINADO (assets/img/fondo-i-sesion.png)
          // ==================================================
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: altoPantalla,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                  child: Image.asset(
                    _assetFondo,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(color: AppColors.primaryDark);
                    },
                  ),
                ),

                // Capa verde oscuro translúcida: mantiene la identidad
                // y la legibilidad sin ocultar la fotografía.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryDark.withValues(alpha: 0.40),
                        AppColors.primaryDark.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(child: _construirFormulario()),
        ],
      ),
    );
  }

  InputDecoration _decoracionCampo({
    required String etiqueta,
    required String ayuda,
    required IconData icono,
    Widget? sufijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      prefixIcon: Icon(icono),
      suffixIcon: sufijo,
      filled: true,
      fillColor: AppColors.white.withValues(alpha: 0.78),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    );
  }

  Widget _construirFormulario() {
    return Center(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          // Tarjeta beige translúcida con efecto de cristal esmerilado.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingXl),
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================
                      Center(
                        child: Image.asset(
                          _assetLogo,
                          height: 96,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          semanticLabel: 'Logo de Mi Ruta Cafetera',
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(height: 96);
                          },
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingLg),

                      // ==================================================
                      // TÍTULO
                      // ==================================================
                      const Text(
                        'Mi Ruta Cafetera',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      const Text(
                        'Descubre la Ruta cafetera del Huila',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXl + 8),

                      // ==================================================
                      // CORREO
                      // ==================================================
                      TextField(
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        enabled: !_ocupado,
                        decoration: _decoracionCampo(
                          etiqueta: 'Correo electrónico',
                          ayuda: 'Ingresa tu correo',
                          icono: Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingLg),

                      // ==================================================
                      // CONTRASEÑA
                      // ==================================================
                      TextField(
                        controller: passwordController,
                        obscureText: ocultarPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enabled: !_ocupado,
                        onSubmitted: (_) => _iniciarSesion(),
                        decoration: _decoracionCampo(
                          etiqueta: 'Contraseña',
                          ayuda: 'Ingresa tu contraseña',
                          icono: Icons.lock_outline,
                          sufijo: IconButton(
                            tooltip: ocultarPassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            icon: Icon(
                              ocultarPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                ocultarPassword = !ocultarPassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXl),

                      // ==================================================
                      // BOTÓN INICIAR SESIÓN
                      // ==================================================
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeightLarge,
                        child: ElevatedButton(
                          onPressed: _ocupado ? null : _iniciarSesion,
                          child: cargando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXs),

                      // ==================================================
                      // RECUPERAR CONTRASEÑA
                      // ==================================================
                      TextButton(
                        onPressed: _ocupado
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecuperarPasswordScreen(),
                                  ),
                                );
                              },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),

                      // ==================================================
                      // DIVISOR "o" + GOOGLE
                      // ==================================================
                      _divisorO(),

                      const SizedBox(height: AppDimensions.spacingMd),

                      _botonGoogle(),

                      const SizedBox(height: AppDimensions.spacingLg),

                      const Divider(),

                      const SizedBox(height: AppDimensions.spacingSm + 2),

                      // ==================================================
                      // REGISTRO
                      // ==================================================
                      const Text(
                        '¿Aún no tienes una cuenta?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXs + 1),

                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: OutlinedButton(
                          onPressed: _ocupado
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistroUsuarioScreen(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Crear una cuenta',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divisorO() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
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
    );
  }

  // ============================================================
  // BOTÓN DE GOOGLE
  // ============================================================
  //
  // Web: botón oficial de Google (lib/google/google_button.dart).
  // Android/iOS: botón propio que usa GoogleAuthService.
  // ============================================================

  Widget _botonGoogle() {
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
        child: _iniciandoGoogle
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
        onPressed: _ocupado ? null : _iniciarSesionConGoogle,
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
            if (_iniciandoGoogle)
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
              _iniciandoGoogle
                  ? 'Conectando con Google...'
                  : 'Continuar con Google',
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
