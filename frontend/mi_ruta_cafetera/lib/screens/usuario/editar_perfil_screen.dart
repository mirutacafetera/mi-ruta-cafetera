import 'package:flutter/material.dart';

import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/usuario/perfil_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

// ============================================================
// EDITAR PERFIL
// ============================================================
//
// Nombre, apellido, teléfono y ciudad. El correo se muestra pero
// no se puede cambiar (el backend lo ignora). La foto de Google
// no se toca desde aquí.
//
// Las reglas replican las del backend (usuario.controller.js).
// ============================================================

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({
    super.key,
  });

  @override
  State<EditarPerfilScreen> createState() =>
      _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _telefono;
  late final TextEditingController _ciudad;

  late final String _correo;

  bool _guardando = false;

  static final RegExp _regexTelefono = RegExp(r'^[0-9+()\-\s]{7,20}$');

  @override
  void initState() {
    super.initState();

    final UsuarioSesionModel? sesion =
        UsuarioSesionService.instance.sesionActual.value;

    _nombre = TextEditingController(text: sesion?.nombre ?? '');
    _apellido = TextEditingController(text: sesion?.apellido ?? '');
    _telefono = TextEditingController(text: sesion?.telefono ?? '');
    _ciudad = TextEditingController(text: sesion?.ciudad ?? '');
    _correo = sesion?.correo ?? '';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _telefono.dispose();
    _ciudad.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDACIONES
  // ============================================================

  String? _validarObligatorio(String? valor, String campo) {
    final texto = (valor ?? '').trim();

    if (texto.isEmpty) {
      return Textos.t('Escribe tu {0}', [Textos.t(campo)]);
    }

    if (texto.length > 60) {
      return Textos.t('Máximo 60 caracteres');
    }

    return null;
  }

  String? _validarTelefono(String? valor) {
    final texto = (valor ?? '').trim();

    if (texto.isEmpty) {
      return null;
    }

    if (!_regexTelefono.hasMatch(texto)) {
      return Textos.t('Usa solo números, espacios, + ( ) y - (7 a 20 caracteres)');
    }

    return null;
  }

  String? _validarCiudad(String? valor) {
    if ((valor ?? '').trim().length > 60) {
      return Textos.t('Máximo 60 caracteres');
    }

    return null;
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void> _guardar() async {
    if (_guardando) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _guardando = true);

    final resultado = await PerfilUsuarioService.actualizarDatos(
      nombre: _nombre.text,
      apellido: _apellido.text,
      telefono: _telefono.text,
      ciudad: _ciudad.text,
    );

    if (!mounted) {
      return;
    }

    setState(() => _guardando = false);

    final mensaje = (resultado['mensaje'] ?? '').toString();

    if (resultado['exito'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensaje.isEmpty ? Textos.t('Perfil actualizado.') : mensaje,
          ),
        ),
      );

      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(
          mensaje.isEmpty
              ? Textos.t('No fue posible guardar los cambios.')
              : mensaje,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Tr('Editar perfil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: Textos.t('Nombre'),
                    prefixIcon: const Icon(Icons.person_rounded),
                  ),
                  validator: (v) => _validarObligatorio(v, 'nombre'),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  controller: _apellido,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: Textos.t('Apellido'),
                    prefixIcon: const Icon(Icons.badge_rounded),
                  ),
                  validator: (v) => _validarObligatorio(v, 'apellido'),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  controller: _telefono,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: Textos.t('Teléfono (opcional)'),
                    prefixIcon: const Icon(Icons.phone_rounded),
                  ),
                  validator: _validarTelefono,
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  controller: _ciudad,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: Textos.t('Ciudad (opcional)'),
                    prefixIcon: const Icon(Icons.location_city_rounded),
                  ),
                  validator: _validarCiudad,
                  onFieldSubmitted: (_) => _guardar(),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  initialValue: _correo,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: Textos.t('Correo'),
                    helperText: Textos.t('El correo no se puede modificar.'),
                    prefixIcon: const Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionGap),
                SizedBox(
                  height: AppDimensions.buttonHeightLarge,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _guardando ? Textos.t('Guardando…') : Textos.t('Guardar cambios'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
