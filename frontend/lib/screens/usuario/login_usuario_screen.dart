import 'package:flutter/material.dart';

import '../../services/usuario/auth_usuario_service.dart';
import 'recuperar_password_screen.dart';
import 'registro_usuario_screen.dart';
import 'home_usuario_screen.dart';

class LoginUsuarioScreen extends StatefulWidget {
  const LoginUsuarioScreen({
    super.key,
  });

  @override
  State<LoginUsuarioScreen> createState() =>
      _LoginUsuarioScreenState();
}

class _LoginUsuarioScreenState
    extends State<LoginUsuarioScreen> {
  // ============================================================
  // CONTROLADORES
  // ============================================================

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool cargando = false;

  bool ocultarPassword = true;

  // ============================================================
  // INICIAR SESIÓN
  // ============================================================

  Future<void> _iniciarSesion() async {
    final correo =
        correoController.text.trim();

    final password =
        passwordController.text;

    if (correo.isEmpty) {
      _mostrarMensaje(
        'Ingresa tu correo electrónico',
      );

      return;
    }

    if (password.isEmpty) {
      _mostrarMensaje(
        'Ingresa tu contraseña',
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado =
        await AuthUsuarioService.iniciarSesion(
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
      final usuario =
          resultado['usuario'];

      final token =
          resultado['token'];

      if (usuario == null || token == null) {
        _mostrarMensaje(
          'El servidor no devolvió los datos de usuario',
        );

        return;
      }

      // ========================================================
      // ENTRAR AL HOME
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeUsuarioScreen(
            usuario: usuario,
            token: token,
          ),
        ),
      );
    } else {
      _mostrarMensaje(
        resultado['mensaje'] ??
            'No fue posible iniciar sesión',
      );
    }
  }

  // ============================================================
  // MOSTRAR MENSAJE
  // ============================================================

  void _mostrarMensaje(
    String mensaje,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // ============================================================
  // LIBERAR CONTROLADORES
  // ============================================================

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // ==================================================
                  // ICONO
                  // ==================================================

                  const Icon(
                    Icons.local_cafe,
                    size: 80,
                    color: Colors.brown,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // TÍTULO
                  // ==================================================

                  const Text(
                    'Mi Ruta Mágica del Café',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Descubre Huila, sus paisajes '
                    'y la magia del café',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  // ==================================================
                  // CORREO
                  // ==================================================

                  TextField(
                    controller:
                        correoController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Correo electrónico',
                      hintText:
                          'Ingresa tu correo',
                      prefixIcon:
                          Icon(
                        Icons.email_outlined,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // CONTRASEÑA
                  // ==================================================

                  TextField(
                    controller:
                        passwordController,
                    obscureText:
                        ocultarPassword,
                    decoration:
                        InputDecoration(
                      labelText:
                          'Contraseña',
                      hintText:
                          'Ingresa tu contraseña',
                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon:
                          IconButton(
                        icon: Icon(
                          ocultarPassword
                              ? Icons
                                  .visibility_off
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

                  const SizedBox(
                    height: 25,
                  ),

                  // ==================================================
                  // BOTÓN INICIAR SESIÓN
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        ElevatedButton(
                      onPressed:
                          cargando
                              ? null
                              : _iniciarSesion,
                      child: cargando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Text(
                              'Iniciar sesión',
                              style:
                                  TextStyle(
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ==================================================
                  // RECUPERAR CONTRASEÑA
                  // ==================================================

                  TextButton(
                    onPressed:
                        cargando
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                      context,
                                    ) =>
                                        const RecuperarPasswordScreen(),
                                  ),
                                );
                              },
                    child:
                        const Text(
                      '¿Olvidaste tu contraseña?',
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 10,
                  ),

                  // ==================================================
                  // REGISTRO
                  // ==================================================

                  const Text(
                    '¿Aún no tienes una cuenta?',
                    style:
                        TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 48,
                    child:
                        OutlinedButton(
                      onPressed:
                          cargando
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                        context,
                                      ) =>
                                          const RegistroUsuarioScreen(),
                                    ),
                                  );
                                },
                      child:
                          const Text(
                        'Crear una cuenta',
                        style:
                            TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}