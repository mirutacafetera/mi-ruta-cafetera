
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class VerificarCodigoCuentaSitio extends StatefulWidget {
  final String correo;
  final String titulo;
  final String descripcion;
  final String textoBoton;
  final Future<void> Function(String codigo) onVerificar;

  const VerificarCodigoCuentaSitio({
    super.key,
    required this.correo,
    required this.onVerificar,
    this.titulo = 'Verificar correo',
    this.descripcion =
        'Hemos enviado un código de verificación al correo electrónico del sitio.',
    this.textoBoton = 'Verificar correo',
  });

  @override
  State<VerificarCodigoCuentaSitio> createState() =>
      _VerificarCodigoCuentaSitioState();
}

class _VerificarCodigoCuentaSitioState
    extends State<VerificarCodigoCuentaSitio> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();

  bool _verificando = false;
  String? _error;

  static const Color _bordeCafe = Color(0xFFB58A70);
  static const Color _fondoCampo = Color(0xFFFFFBF6);
  static const Color _verde = AppColors.primary;
  static const Color _naranja = AppColors.secondary;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _verificar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _verificando = true;
      _error = null;
    });

    try {
      await widget.onVerificar(_codigoController.text.trim());

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _verificando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.creamLight,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: const BorderSide(
          color: _bordeCafe,
          width: 1.2,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _naranja.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _naranja.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: _naranja,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.correo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.bold,
                letterSpacing: 9,
              ),
              decoration: InputDecoration(
                labelText: 'Código de verificación',
                hintText: '000000',
                counterText: '',
                filled: true,
                fillColor: _fondoCampo,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: _naranja,
                ),
                labelStyle: const TextStyle(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  borderSide: const BorderSide(color: _bordeCafe),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  borderSide: const BorderSide(
                    color: _bordeCafe,
                    width: 1.6,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  borderSide: const BorderSide(
                    color: _bordeCafe,
                    width: 1.2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa el código recibido';
                }

                if (valor.trim().length != 6) {
                  return 'El código debe tener 6 dígitos';
                }

                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'El código tiene una vigencia de 10 minutos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _verificando
              ? null
              : () => Navigator.pop(context, false),
          child: const Text(
            'Ahora no',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _verificando ? null : _verificar,
          icon: _verificando
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.verified_outlined),
          label: Text(
            _verificando ? 'Verificando...' : widget.textoBoton,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _verde,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _verde.withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.cardRadius,
              ),
              side: const BorderSide(color: _bordeCafe),
            ),
          ),
        ),
      ],
    );
  }
}
