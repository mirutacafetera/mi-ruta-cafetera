import 'package:flutter/material.dart';

import '../../../models/admin/cuenta_sitio_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class FormularioCuentaSitio extends StatefulWidget {
  final CuentaSitioModel? cuenta;
  final bool cargando;
  final Future<void> Function(Map<String, String> datos) onGuardar;

  const FormularioCuentaSitio({
    super.key,
    this.cuenta,
    this.cargando = false,
    required this.onGuardar,
  });

  @override
  State<FormularioCuentaSitio> createState() =>
      _FormularioCuentaSitioState();
}

class _FormularioCuentaSitioState extends State<FormularioCuentaSitio> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _correo;
  late final TextEditingController _password;
  late final TextEditingController _telefono;

  bool _ocultarPassword = true;

  bool get _editando => widget.cuenta != null;

  @override
  void initState() {
    super.initState();

    final cuenta = widget.cuenta;

    _nombre = TextEditingController(text: cuenta?.nombre ?? '');
    _apellido = TextEditingController(text: cuenta?.apellido ?? '');
    _correo = TextEditingController(text: cuenta?.correo ?? '');
    _password = TextEditingController();
    _telefono = TextEditingController(text: cuenta?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _correo.dispose();
    _password.dispose();
    _telefono.dispose();
    super.dispose();
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _campo({
    required String etiqueta,
    required IconData icono,
    required TextEditingController controller,
    required String? Function(String?) validar,
    TextInputType? teclado,
    bool oculto = false,
    Widget? sufijo,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      obscureText: oculto,
      validator: validar,
      decoration: _decoracion(etiqueta, icono).copyWith(
        suffixIcon: sufijo,
      ),
    );
  }

  String? _requerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.onGuardar({
      'nombre': _nombre.text.trim(),
      'apellido': _apellido.text.trim(),
      'correo': _correo.text.trim(),
      'password': _password.text,
      'telefono': _telefono.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editando ? 'Editar cuenta' : 'Nueva cuenta',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              _editando
                  ? 'Actualiza los datos de acceso del sitio turístico.'
                  : 'Registra los datos de acceso del responsable del sitio.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            _campo(
              etiqueta: 'Nombre',
              icono: Icons.person_outline,
              controller: _nombre,
              validar: _requerido,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _campo(
              etiqueta: 'Apellido',
              icono: Icons.person_outline,
              controller: _apellido,
              validar: _requerido,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _campo(
              etiqueta: 'Correo electrónico',
              icono: Icons.email_outlined,
              controller: _correo,
              teclado: TextInputType.emailAddress,
              validar: (valor) {
                if (_requerido(valor) != null) {
                  return 'Ingresa el correo electrónico';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                    .hasMatch(valor!.trim())) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _campo(
              etiqueta: _editando
                  ? 'Nueva contraseña (opcional)'
                  : 'Contraseña',
              icono: Icons.lock_outline,
              controller: _password,
              oculto: _ocultarPassword,
              validar: (valor) {
                if (!_editando && (valor == null || valor.isEmpty)) {
                  return 'Ingresa una contraseña';
                }
                if (valor != null &&
                    valor.isNotEmpty &&
                    valor.length < 6) {
                  return 'Debe tener al menos 6 caracteres';
                }
                return null;
              },
              sufijo: IconButton(
                onPressed: () {
                  setState(() {
                    _ocultarPassword = !_ocultarPassword;
                  });
                },
                icon: Icon(
                  _ocultarPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _campo(
              etiqueta: 'Teléfono',
              icono: Icons.phone_outlined,
              controller: _telefono,
              teclado: TextInputType.phone,
              validar: _requerido,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: widget.cargando ? null : _guardar,
                icon: widget.cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  widget.cargando
                      ? 'Guardando...'
                      : _editando
                          ? 'Guardar cambios'
                          : 'Crear cuenta',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}