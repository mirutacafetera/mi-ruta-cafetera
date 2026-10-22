
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

  static const Color _bordeCafe = Color(0xFFB58A70);
  static const Color _verde = AppColors.primary;
  static const Color _naranja = AppColors.secondary;

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
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icono, color: _naranja),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: const BorderSide(color: _bordeCafe),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: const BorderSide(color: _bordeCafe, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: const BorderSide(color: _bordeCafe, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
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
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
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

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 21,
            decoration: BoxDecoration(
              color: _verde,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              decoration: BoxDecoration(
                color: _verde.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius,
                ),
                border: Border.all(color: _bordeCafe, width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _naranja.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _naranja.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      _editando
                          ? Icons.manage_accounts_outlined
                          : Icons.person_add_alt_1_rounded,
                      color: _naranja,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editando ? 'Editar cuenta' : 'Nueva cuenta',
                          style: texto.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _editando
                              ? 'Actualiza los datos del responsable.'
                              : 'Registra al responsable del sitio turístico.',
                          style: texto.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            _seccion('Información personal'),
            _campo(
              etiqueta: 'Nombre',
              icono: Icons.person_outline_rounded,
              controller: _nombre,
              validar: _requerido,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _campo(
              etiqueta: 'Apellido',
              icono: Icons.person_outline_rounded,
              controller: _apellido,
              validar: _requerido,
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
            _seccion('Datos de acceso'),
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
              icono: Icons.lock_outline_rounded,
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
                tooltip: _ocultarPassword
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                onPressed: () {
                  setState(() {
                    _ocultarPassword = !_ocultarPassword;
                  });
                },
                icon: Icon(
                  _ocultarPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _naranja,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: widget.cargando ? null : _guardar,
                icon: widget.cargando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
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
                  backgroundColor: _verde,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      _verde.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius,
                    ),
                    side: const BorderSide(color: _bordeCafe),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
        ),
      ),
    );
  }
}
