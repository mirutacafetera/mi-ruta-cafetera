import 'package:flutter/material.dart';

import '../../services/usuario/auth_usuario_service.dart';
import 'verificar_correo_screen.dart';

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
        'Completa todos los campos',
      );
      return;
    }

    if (password.length < 6) {
      mostrarMensaje(
        'La contraseña debe tener mínimo 6 caracteres',
      );
      return;
    }

    if (password != confirmarPassword) {
      mostrarMensaje(
        'Las contraseñas no coinciden',
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
          builder: (context) =>
              VerificarCorreoScreen(
            correo: correo,
          ),
        ),
      );
    } else {
      mostrarMensaje(
        resultado['mensaje'] ??
            'No fue posible crear la cuenta',
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
        title: const Text(
          'Crear cuenta',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // ==================================================
              // TÍTULO
              // ==================================================

              const Icon(
                Icons.person_add_alt_1,
                size: 70,
                color: Colors.brown,
              ),

              const SizedBox(height: 20),

              const Text(
                'Crea tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Regístrate para comenzar a descubrir '
                'la Ruta Mágica del Café.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // NOMBRE
              // ==================================================

              TextField(
                controller: nombreController,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon:
                      Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // APELLIDO
              // ==================================================

              TextField(
                controller: apellidoController,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon:
                      Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // CORREO
              // ==================================================

              TextField(
                controller: correoController,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon:
                      Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // CONTRASEÑA
              // ==================================================

              TextField(
                controller: passwordController,
                obscureText: ocultarPassword,
                textInputAction:
                    TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon:
                      const Icon(Icons.lock_outline),
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
                  border:
                      const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

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
                      'Confirmar contraseña',
                  prefixIcon:
                      const Icon(Icons.lock_outline),
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
                  border:
                      const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // BOTÓN REGISTRAR
              // ==================================================

              SizedBox(
                height: 52,
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
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // VOLVER AL LOGIN
              // ==================================================

              TextButton(
                onPressed: cargando
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text(
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