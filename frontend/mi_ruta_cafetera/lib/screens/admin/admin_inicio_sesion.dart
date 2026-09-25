import 'package:flutter/material.dart';

import '../../services/admin/admin_servicio_autenticacion.dart';
import '../../screens/admin/admin_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AdminInicioSesion extends StatefulWidget {
  const AdminInicioSesion({super.key});

  @override
  State<AdminInicioSesion> createState() => _AdminInicioSesionState();
}

class _AdminInicioSesionState extends State<AdminInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    FocusScope.of(context).unfocus();

    try {
      final resultado = await AdminServicioAutenticacion.iniciarSesion(
        correo: _correoController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final admin = resultado['administrador'] as Map<String, dynamic>;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminScreen(
            nombre: admin['nombre']?.toString() ?? 'Administrador',
            email: admin['correo']?.toString() ??
                _correoController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final mensaje = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.coffeeDark,
              AppColors.secondary,
              AppColors.coffeeLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingXxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingXxl,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            size: 70,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                          const Text(
                            'Acceso de administrador',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coffeeDark,
                            ),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingXl,
                          ),
                          TextFormField(
                            controller: _correoController,
                            enabled: !_cargando,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              prefixIcon: Icon(Icons.email_outlined),
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
                          const SizedBox(
                            height: AppDimensions.spacingLg,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !_cargando,
                            obscureText: !_mostrarPassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _mostrarPassword = !_mostrarPassword;
                                  });
                                },
                                icon: Icon(
                                  _mostrarPassword
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
                              if (!_cargando) _iniciarSesion();
                            },
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingXl,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: AppDimensions.buttonHeightLarge,
                            child: ElevatedButton(
                              onPressed:
                                  _cargando ? null : _iniciarSesion,
                              child: _cargando
                                  ? const CircularProgressIndicator(
                                      color: AppColors.white,
                                    )
                                  : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingMd,
                          ),
                          TextButton.icon(
                            onPressed: _cargando
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Volver'),
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