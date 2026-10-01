import 'package:flutter/material.dart';

import '../../services/sitio/sitio_auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pageHorizontal,
              vertical: AppDimensions.spacingXl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // =====================================================
                    // ICONO
                    // =====================================================

                    Icon(
                      Icons.storefront_rounded,
                      size: 70,
                      color: AppColors.primary,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),

                    // =====================================================
                    // TITULO
                    // =====================================================

                    Text(
                      'Acceso para sitios turísticos',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingSm,
                    ),

                    // =====================================================
                    // DESCRIPCION
                    // =====================================================

                    Text(
                      'Administra la información de tu sitio turístico.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingXl,
                    ),

                    // =====================================================
                    // CORREO
                    // =====================================================

                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
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

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    // =====================================================
                    // CONTRASEÑA
                    // =====================================================

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_mostrarPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _iniciarSesion(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _cargando
                              ? null
                              : () {
                                  setState(() {
                                    _mostrarPassword =
                                        !_mostrarPassword;
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

                    const SizedBox(
                      height: AppDimensions.spacingLg,
                    ),

                    // =====================================================
                    // BOTON INICIAR SESION
                    // =====================================================

                    SizedBox(
                      height: AppDimensions.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: _cargando
                            ? null
                            : _iniciarSesion,
                        child: _cargando
                            ? const SizedBox(
                                width: AppDimensions.iconMd,
                                height: AppDimensions.iconMd,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    // =====================================================
                    // VOLVER AL INICIO
                    // =====================================================

                    TextButton.icon(
                      onPressed: _cargando
                          ? null
                          : _volverAlInicio,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                      label: const Text(
                        'Volver al inicio',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}