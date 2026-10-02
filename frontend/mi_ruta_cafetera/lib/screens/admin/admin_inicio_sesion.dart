import 'package:flutter/material.dart';

import '../../controllers/admin/inicio_seccion_admin.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
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

      final admin = resultado['administrador'] as Map<String, dynamic>;

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
              padding: const EdgeInsets.all(
                AppDimensions.pageHorizontal,
              ),
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
                          size: AppDimensions.categoryIconLarge,
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
                          height: AppDimensions.spacingSection,
                        ),
                        TextFormField(
                          controller: controlador.correoController,
                          enabled: !controlador.cargando,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
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
                          controller: controlador.passwordController,
                          enabled: !controlador.cargando,
                          obscureText: !controlador.mostrarPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),
                            suffixIcon: IconButton(
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
                        const SizedBox(
                          height: AppDimensions.spacingSection,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightLarge,
                          child: ElevatedButton(
                            onPressed: controlador.cargando
                                ? null
                                : _iniciarSesion,
                            child: controlador.cargando
                                ? const SizedBox(
                                    width: AppDimensions.iconLg,
                                    height: AppDimensions.iconLg,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                    ),
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
                          height: AppDimensions.spacingSm,
                        ),
                        TextButton.icon(
                          onPressed: controlador.cargando
                              ? null
                              : () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                          ),
                          label: const Text(
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
    );
  }

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();
    super.dispose();
  }
}