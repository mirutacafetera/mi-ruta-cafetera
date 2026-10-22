import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/sitio/sitio_recuperacion_password_service.dart';

class SitioRecuperarPasswordScreen extends StatefulWidget {
  const SitioRecuperarPasswordScreen({super.key});

  @override
  State<SitioRecuperarPasswordScreen> createState() =>
      _SitioRecuperarPasswordScreenState();
}

class _SitioRecuperarPasswordScreenState
    extends State<SitioRecuperarPasswordScreen> {
  final _servicio = SitioRecuperacionPasswordService();
  final _formKey = GlobalKey<FormState>();

  final _correoController = TextEditingController();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  int _paso = 0;
  bool _cargando = false;
  bool _mostrarPassword = false;
  bool _mostrarConfirmacion = false;

  String? _tokenRecuperacion;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _codigoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> _ejecutar(
    Future<void> Function() accion,
  ) async {
    if (_cargando) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await accion();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _solicitarCodigo() async {
    if (!_formKey.currentState!.validate()) return;

    await _ejecutar(() async {
      await _servicio.solicitarCodigo(
        correo: _correoController.text,
      );

      if (!mounted) return;

      setState(() {
        _paso = 1;
      });

      _mostrarMensaje(
        'Si el correo es válido, recibirás las instrucciones de recuperación.',
      );
    });
  }

  Future<void> _verificarCodigo() async {
    if (!_formKey.currentState!.validate()) return;

    await _ejecutar(() async {
      final token = await _servicio.verificarCodigo(
        correo: _correoController.text,
        codigo: _codigoController.text,
      );

      if (!mounted) return;

      setState(() {
        _tokenRecuperacion = token;
        _paso = 2;
      });
    });
  }

  Future<void> _restablecerPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final token = _tokenRecuperacion;

    if (token == null || token.isEmpty) {
      setState(() {
        _error = 'Debes verificar primero el código de recuperación.';
      });
      return;
    }

    await _ejecutar(() async {
      await _servicio.restablecerPassword(
        tokenRecuperacion: token,
        nuevaPassword: _passwordController.text,
      );

      if (!mounted) return;

      _mostrarMensaje('Tu contraseña se restableció correctamente.');

      Navigator.of(context).pop();
    });
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.sitioPrimary,
        ),
      );
  }

  String? _validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
      return 'Ingresa un correo electrónico válido.';
    }

    return null;
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLength: maxLength,
      enabled: !_cargando,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
        suffixIcon: suffixIcon,
        counterText: '',
        filled: true,
        fillColor: AppColors.sitioSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  String get _tituloPaso {
    switch (_paso) {
      case 1:
        return 'Verifica tu correo';
      case 2:
        return 'Crea una contraseña nueva';
      default:
        return 'Recuperar contraseña';
    }
  }

  String get _descripcionPaso {
    switch (_paso) {
      case 1:
        return 'Ingresa el código de seis dígitos que recibiste por correo.';
      case 2:
        return 'Elige una contraseña nueva para volver a acceder a tu cuenta.';
      default:
        return 'Te ayudaremos a recuperar el acceso a tu cuenta de sitio turístico.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sitioBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sitioBackground,
        foregroundColor: AppColors.sitioTextPrimary,
        elevation: 0,
        title: const Text('Cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.sitioPagePadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: AppColors.sitioSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioPanelCardRadius,
                  ),
                  side: const BorderSide(
                    color: AppColors.sitioBorder,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.sitioSurfaceGreen,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLg,
                            ),
                          ),
                          child: Icon(
                            _paso == 2
                                ? Icons.lock_reset_rounded
                                : _paso == 1
                                    ? Icons.mark_email_read_rounded
                                    : Icons.lock_outline_rounded,
                            color: AppColors.sitioPrimary,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _tituloPaso,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.sitioTextPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _descripcionPaso,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.sitioTextSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (_paso == 0) ...[
                          _campo(
                            controller: _correoController,
                            label: 'Correo electrónico',
                            icono: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validarCorreo,
                          ),
                          const SizedBox(height: 20),
                          _boton(
                            texto: 'Enviar código',
                            icono: Icons.send_rounded,
                            onPressed: _solicitarCodigo,
                          ),
                        ] else if (_paso == 1) ...[
                          _campo(
                            controller: _codigoController,
                            label: 'Código de verificación',
                            icono: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            validator: (valor) {
                              if (valor == null || valor.trim().length != 6) {
                                return 'Ingresa el código completo de seis dígitos.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _boton(
                            texto: 'Verificar código',
                            icono: Icons.verified_user_rounded,
                            onPressed: _verificarCodigo,
                          ),
                          TextButton(
                            onPressed: _cargando
                                ? null
                                : () {
                                    setState(() {
                                      _paso = 0;
                                      _error = null;
                                    });
                                  },
                            child: const Text('Cambiar correo'),
                          ),
                        ] else ...[
                          _campo(
                            controller: _passwordController,
                            label: 'Nueva contraseña',
                            icono: Icons.lock_outline_rounded,
                            obscureText: !_mostrarPassword,
                            suffixIcon: IconButton(
                              tooltip: _mostrarPassword
                                  ? 'Ocultar contraseña'
                                  : 'Mostrar contraseña',
                              onPressed: () {
                                setState(() {
                                  _mostrarPassword = !_mostrarPassword;
                                });
                              },
                              icon: Icon(
                                _mostrarPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _campo(
                            controller: _confirmarPasswordController,
                            label: 'Confirmar contraseña',
                            icono: Icons.lock_reset_rounded,
                            obscureText: !_mostrarConfirmacion,
                            suffixIcon: IconButton(
                              tooltip: _mostrarConfirmacion
                                  ? 'Ocultar contraseña'
                                  : 'Mostrar contraseña',
                              onPressed: () {
                                setState(() {
                                  _mostrarConfirmacion =
                                      !_mostrarConfirmacion;
                                });
                              },
                              icon: Icon(
                                _mostrarConfirmacion
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            validator: (valor) {
                              if (valor != _passwordController.text) {
                                return 'Las contraseñas no coinciden.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _boton(
                            texto: 'Restablecer contraseña',
                            icono: Icons.check_circle_outline_rounded,
                            onPressed: _restablecerPassword,
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.sitioErrorSoft,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppColors.sitioError,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                        if (_cargando) ...[
                          const SizedBox(height: 20),
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.sitioPrimary,
                            ),
                          ),
                        ],
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

  Widget _boton({
    required String texto,
    required IconData icono,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: AppDimensions.sitioButtonHeight,
      child: ElevatedButton.icon(
        onPressed: _cargando ? null : onPressed,
        icon: Icon(icono),
        label: Text(texto),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sitioPrimary,
          foregroundColor: AppColors.sitioTextOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioFormRadius,
            ),
          ),
        ),
      ),
    );
  }
}
