import 'package:flutter/material.dart';

import '../../controllers/admin/inicio_seccion_admin.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/auth/boton_google_login.dart';
import '../../widgets/auth/escenario_login.dart';
import 'pantalla_administrador.dart';

class AdminInicioSesion extends StatefulWidget {
  const AdminInicioSesion({super.key});

  @override
  State<AdminInicioSesion> createState() => _AdminInicioSesionState();
}

class _AdminInicioSesionState extends State<AdminInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  late final InicioSesionAdmin controlador;

  @override
  void initState() {
    super.initState();
    controlador = InicioSesionAdmin()..addListener(_actualizar);
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final resultado = await controlador.iniciarSesion();

      if (!mounted) {
        return;
      }

      _abrirPanel(
        resultado['administrador'] as Map<String, dynamic>,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _abrirPanel(Map<String, dynamic> admin) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaAdministrador(
          nombre: admin['nombre']?.toString() ?? 'Administrador',
          email: admin['correo']?.toString() ??
              controlador.correoController.text.trim(),
        ),
      ),
    );
  }

  // Google: el backend valida el token y solo admite cuentas de
  // administrador que ya existen. Los errores se muestran en el
  // botón de Google.
  Future<void> _iniciarConGoogle(String idToken) async {
    final resultado = await controlador.iniciarSesionConGoogle(idToken);

    if (!mounted) {
      return;
    }

    _abrirPanel(
      resultado['administrador'] as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EscenarioLogin(
      titulo: 'Acceso de administrador',
      descripcion:
          'Esta sección está destinada únicamente a administradores autorizados.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: controlador.correoController,
                enabled: !controlador.cargando,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: decoracionCampoLogin(
                  etiqueta: 'Correo',
                  ayuda: 'Ingresa tu correo',
                  icono: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo';
                  }

                  if (!value.contains('@')) {
                    return 'Ingresa un correo válido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              TextFormField(
                controller: controlador.passwordController,
                enabled: !controlador.cargando,
                obscureText: !controlador.mostrarPassword,
                textInputAction: TextInputAction.done,
                decoration: decoracionCampoLogin(
                  etiqueta: 'Contraseña',
                  ayuda: 'Ingresa tu contraseña',
                  icono: Icons.lock_outline,
                  sufijo: IconButton(
                    tooltip: controlador.mostrarPassword
                        ? 'Ocultar contraseña'
                        : 'Mostrar contraseña',
                    onPressed: controlador.cambiarPassword,
                    icon: Icon(
                      controlador.mostrarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }

                  return null;
                },
                onFieldSubmitted: (_) {
                  if (!controlador.cargando) {
                    _iniciarSesion();
                  }
                },
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: controlador.cargando ? null : _iniciarSesion,
                  child: controlador.cargando
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
              BotonGoogleLogin(
                onIdToken: _iniciarConGoogle,
                bloqueado: controlador.cargando,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              TextButton.icon(
                onPressed: controlador.cargando
                    ? null
                    : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
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

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();
    super.dispose();
  }
}
