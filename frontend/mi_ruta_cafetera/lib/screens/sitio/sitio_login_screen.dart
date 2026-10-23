import 'package:flutter/material.dart';

import '../../services/sitio/sitio_auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/auth/boton_google_login.dart';
import '../../widgets/auth/escenario_login.dart';
import '../publico/bienvenida_screen.dart';
import 'panel_sitio_screen.dart';

class SitioLoginScreen extends StatefulWidget {
  const SitioLoginScreen({super.key});

  @override
  State<SitioLoginScreen> createState() => _SitioLoginScreenState();
}

class _SitioLoginScreenState extends State<SitioLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  final SitioAuthService _authService = SitioAuthService();

  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await _authService.iniciarSesion(
        correo: _correoController.text,
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PanelSitioScreen(),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Google: el backend valida el token y solo admite cuentas de sitio
  // que ya existen. Los errores se muestran en el botón de Google.
  Future<void> _iniciarConGoogle(String idToken) async {
    await _authService.iniciarSesionConGoogle(idToken: idToken);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PanelSitioScreen(),
      ),
    );
  }

  void _volverAlInicio() {
    if (_cargando) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const BienvenidaScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EscenarioLogin(
      titulo: 'Acceso para sitios turísticos',
      descripcion: 'Administra la información de tu sitio turístico.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =====================================================
              // CORREO
              // =====================================================

              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_cargando,
                decoration: decoracionCampoLogin(
                  etiqueta: 'Correo electrónico',
                  ayuda: 'Ingresa tu correo',
                  icono: Icons.email_outlined,
                ),
                validator: (value) {
                  final correo = value?.trim() ?? '';

                  if (correo.isEmpty) {
                    return 'Ingresa tu correo electrónico';
                  }

                  if (!correo.contains('@')) {
                    return 'Ingresa un correo válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // =====================================================
              // CONTRASEÑA
              // =====================================================

              TextFormField(
                controller: _passwordController,
                obscureText: !_mostrarPassword,
                textInputAction: TextInputAction.done,
                enabled: !_cargando,
                onFieldSubmitted: (_) {
                  if (!_cargando) {
                    _iniciarSesion();
                  }
                },
                decoration: decoracionCampoLogin(
                  etiqueta: 'Contraseña',
                  ayuda: 'Ingresa tu contraseña',
                  icono: Icons.lock_outline,
                  sufijo: IconButton(
                    tooltip: _mostrarPassword
                        ? 'Ocultar contraseña'
                        : 'Mostrar contraseña',
                    onPressed: _cargando
                        ? null
                        : () {
                            setState(() {
                              _mostrarPassword = !_mostrarPassword;
                            });
                          },
                    icon: Icon(
                      _mostrarPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // =====================================================
              // BOTON INICIAR SESION
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _iniciarSesion,
                  child: _cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              // =====================================================
              // GOOGLE
              // =====================================================
              BotonGoogleLogin(
                onIdToken: _iniciarConGoogle,
                bloqueado: _cargando,
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              // =====================================================
              // VOLVER AL INICIO
              // =====================================================

              TextButton.icon(
                onPressed: _cargando ? null : _volverAlInicio,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Volver al inicio'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

