import 'package:flutter/material.dart';

import '../../services/usuario/auth_usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'verificar_correo_screen.dart';
import 'login_usuario_screen.dart';
import '../../l10n/textos.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({
    super.key,
  });

  @override
  State<RegistroUsuarioScreen> createState() =>
      _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState
    extends State<RegistroUsuarioScreen> {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController =
      TextEditingController();

  bool cargando = false;
  bool ocultarPassword = true;
  bool ocultarConfirmarPassword = true;

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // MOSTRAR MENSAJE
  // ============================================================

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // ============================================================
  // REGISTRAR USUARIO
  // ============================================================

  Future<void> _registrarUsuario() async {
    FocusScope.of(context).unfocus();

    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text;
    final confirmarPassword =
        confirmarPasswordController.text;

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        confirmarPassword.isEmpty) {
      mostrarMensaje(
        Textos.t('Completa todos los campos'),
      );
      return;
    }

    if (password.length < 6) {
      mostrarMensaje(
        Textos.t('La contraseña debe tener mínimo 6 caracteres'),
      );
      return;
    }

    if (password != confirmarPassword) {
      mostrarMensaje(
        Textos.t('Las contraseñas no coinciden'),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado =
        await AuthUsuarioService.registrarUsuario(
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (resultado['exito'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificarCorreoScreen(
            correo: correo,
          ),
        ),
      );
    } else {
      mostrarMensaje(
        resultado['mensaje'] ??
            Textos.t('No fue posible crear la cuenta'),
      );
    }
  }

  // ============================================================
  // CONSTRUCCIÓN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Tr(
          'Crear cuenta',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppDimensions.spacingXxl,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: AppDimensions.spacingLg + 4,
              ),

              // ==================================================
              // TÍTULO
              // ==================================================

              const Icon(
                Icons.person_add_alt_1,
                size: 70,
                color: AppColors.secondary,
              ),

              const SizedBox(
                height: AppDimensions.spacingLg + 4,
              ),

              const Tr(
                'Crea tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingSm,
              ),

              const Tr(
                'Regístrate para comenzar a descubrir Mi Ruta Cafetera',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXl + 10,
              ),

              // ==================================================
              // NOMBRE
              // ==================================================

              TextField(
                controller: nombreController,
                textInputAction:
                    TextInputAction.next,
                decoration: InputDecoration(
                  labelText: Textos.t('Nombre'),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd + 4,
              ),

              // ==================================================
              // APELLIDO
              // ==================================================

              TextField(
                controller: apellidoController,
                textInputAction:
                    TextInputAction.next,
                decoration: InputDecoration(
                  labelText: Textos.t('Apellido'),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd + 4,
              ),

              // ==================================================
              // CORREO
              // ==================================================

              TextField(
                controller: correoController,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                decoration: InputDecoration(
                  labelText: Textos.t('Correo electrónico'),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd + 4,
              ),

              // ==================================================
              // CONTRASEÑA
              // ==================================================

              TextField(
                controller: passwordController,
                obscureText: ocultarPassword,
                textInputAction:
                    TextInputAction.next,
                decoration: InputDecoration(
                  labelText: Textos.t('Contraseña'),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarPassword =
                            !ocultarPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd + 4,
              ),

              // ==================================================
              // CONFIRMAR CONTRASEÑA
              // ==================================================

              TextField(
                controller:
                    confirmarPasswordController,
                obscureText:
                    ocultarConfirmarPassword,
                textInputAction:
                    TextInputAction.done,
                onSubmitted: (_) {
                  if (!cargando) {
                    _registrarUsuario();
                  }
                },
                decoration: InputDecoration(
                  labelText:
                      Textos.t('Confirmar contraseña'),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarConfirmarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarConfirmarPassword =
                            !ocultarConfirmarPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXl + 4,
              ),

              // ==================================================
              // BOTÓN REGISTRAR
              // ==================================================

              SizedBox(
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: cargando
                      ? null
                      : _registrarUsuario,
                  child: cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Tr(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingLg + 4,
              ),

              // ==================================================
              // VOLVER AL LOGIN
              // ==================================================

              TextButton(
                onPressed: cargando
                    ? null
                    : () {
                      Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginUsuarioScreen()),
                  );
                      },
                child: const Tr(
                  'Ya tengo una cuenta',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}