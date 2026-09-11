import 'package:flutter/material.dart';

import '../../services/admin/admin_auth_service.dart';
import '../../screens/admin/admin_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _correoController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  // INICIAR SESIÓN
  // =====================================================

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final resultado =
          await AdminAuthService.iniciarSesion(
        correo: _correoController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final administrador =
          resultado['administrador']
              as Map<String, dynamic>;

      final nombre =
          administrador['nombre']?.toString() ??
              'Administrador';

      final correo =
          administrador['correo']?.toString() ??
              _correoController.text.trim();

      // =================================================
      // ACCESO AL PANEL
      // =================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminScreen(
            nombre: nombre,
            email: correo,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String mensaje = e.toString();

      if (mensaje.startsWith('Exception: ')) {
        mensaje =
            mensaje.substring('Exception: '.length);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
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

  // =====================================================
  // VOLVER
  // =====================================================

  void _volver() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade800,
              Colors.brown.shade500,
              Colors.brown.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Card(
                  elevation: 10,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          // =================================================
                          // ICONO
                          // =================================================

                          Container(
                            width: 82,
                            height: 82,
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.brown.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons
                                  .admin_panel_settings,
                              size: 48,
                              color:
                                  Colors.brown.shade800,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // =================================================
                          // TÍTULO
                          // =================================================

                          Text(
                            'Acceso de administrador',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Colors.brown.shade900,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            'Ingresa con una cuenta de administrador autorizada.',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // =================================================
                          // CORREO
                          // =================================================

                          TextFormField(
                            controller:
                                _correoController,
                            keyboardType:
                                TextInputType
                                    .emailAddress,
                            textInputAction:
                                TextInputAction
                                    .next,
                            enabled: !_cargando,
                            decoration:
                                InputDecoration(
                              labelText: 'Correo',
                              hintText:
                                  'admin@ejemplo.com',
                              prefixIcon:
                                  const Icon(
                                Icons.email_outlined,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                              ),
                            ),
                            validator: (value) {
                              final correo =
                                  value?.trim() ??
                                      '';

                              if (correo.isEmpty) {
                                return 'Ingresa tu correo';
                              }

                              if (!correo
                                  .contains('@')) {
                                return 'Ingresa un correo válido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // =================================================
                          // CONTRASEÑA
                          // =================================================

                          TextFormField(
                            controller:
                                _passwordController,
                            obscureText:
                                !_mostrarPassword,
                            enabled: !_cargando,
                            textInputAction:
                                TextInputAction
                                    .done,
                            onFieldSubmitted:
                                (_) {
                              if (!_cargando) {
                                _iniciarSesion();
                              }
                            },
                            decoration:
                                InputDecoration(
                              labelText:
                                  'Contraseña',
                              prefixIcon:
                                  const Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon:
                                  IconButton(
                                onPressed:
                                    _cargando
                                        ? null
                                        : () {
                                            setState(
                                              () {
                                                _mostrarPassword =
                                                    !_mostrarPassword;
                                              },
                                            );
                                          },
                                icon: Icon(
                                  _mostrarPassword
                                      ? Icons
                                          .visibility_off
                                      : Icons
                                          .visibility,
                                ),
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 26,
                          ),

                          // =================================================
                          // BOTÓN LOGIN
                          // =================================================

                          SizedBox(
                            width:
                                double.infinity,
                            height: 52,
                            child:
                                ElevatedButton(
                              onPressed:
                                  _cargando
                                      ? null
                                      : _iniciarSesion,
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.brown
                                        .shade800,
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                ),
                              ),
                              child: _cargando
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2.5,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Icon(
                                          Icons
                                              .login,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Iniciar sesión',
                                          style:
                                              TextStyle(
                                            fontSize:
                                                16,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // =================================================
                          // VOLVER
                          // =================================================

                          TextButton.icon(
                            onPressed:
                                _cargando
                                    ? null
                                    : _volver,
                            icon:
                                const Icon(
                              Icons.arrow_back,
                            ),
                            label:
                                const Text(
                              'Volver',
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
        ),
      ),
    );
  }
}