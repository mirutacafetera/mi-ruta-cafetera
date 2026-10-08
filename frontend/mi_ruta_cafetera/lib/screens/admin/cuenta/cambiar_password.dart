import 'package:flutter/material.dart';

import '../../../services/admin/admin_servicio_autenticacion.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/cuenta/cambiar_password/boton_password.dart';
import '../../../widgets/admin/cuenta/cambiar_password/campo_password.dart';
import '../../../widgets/admin/cuenta/cambiar_password/pasos_cambio_password.dart';

class CambiarPassword extends StatefulWidget {
  final String correo;

  const CambiarPassword({
    super.key,
    required this.correo,
  });

  @override
  State<CambiarPassword> createState() => _CambiarPasswordState();
}

class _CambiarPasswordState extends State<CambiarPassword> {
  final TextEditingController codigoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmarPasswordController =
      TextEditingController();

  bool codigoEnviado = false;
  bool verificandoCodigo = false;
  bool cambiandoPassword = false;
  bool mostrarPassword = false;
  bool mostrarConfirmarPassword = false;

  String? tokenRecuperacion;

  Future<void> _enviarCodigo() async {
    setState(() {
      verificandoCodigo = true;
    });

    try {
      await AdminServicioAutenticacion.solicitarRecuperacion(
        correo: widget.correo,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        codigoEnviado = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Código de recuperación enviado a tu correo.',
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
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          verificandoCodigo = false;
        });
      }
    }
  }

  Future<void> _verificarCodigo() async {
    if (codigoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa el código de recuperación.',
          ),
        ),
      );
      return;
    }

    setState(() {
      verificandoCodigo = true;
    });

    try {
      final token =
          await AdminServicioAutenticacion
              .verificarCodigoRecuperacion(
        correo: widget.correo,
        codigo: codigoController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        tokenRecuperacion = token;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Código verificado correctamente.',
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
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          verificandoCodigo = false;
        });
      }
    }
  }

  Future<void> _cambiarPassword() async {
    if (tokenRecuperacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero debes verificar el código.',
          ),
        ),
      );
      return;
    }

    if (passwordController.text.isEmpty ||
        confirmarPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa los campos de contraseña.',
          ),
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener mínimo 6 caracteres.',
          ),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmarPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas no coinciden.',
          ),
        ),
      );
      return;
    }

    setState(() {
      cambiandoPassword = true;
    });

    try {
      await AdminServicioAutenticacion.restablecerPassword(
        tokenRecuperacion: tokenRecuperacion!,
        nuevaPassword: passwordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contraseña cambiada correctamente.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cambiandoPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int pasoActual = tokenRecuperacion != null
        ? 3
        : codigoEnviado
            ? 2
            : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cambiar contraseña',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppDimensions.spacingXl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar contraseña',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingSm,
            ),
            Text(
              'Enviaremos un código de recuperación a ${widget.correo}.',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingXl,
            ),
            PasosCambioPassword(
              pasoActual: pasoActual,
            ),
            const SizedBox(
              height: AppDimensions.spacingXl,
            ),
            BotonPassword(
              texto: 'Enviar código',
              icono: Icons.email_outlined,
              cargando: verificandoCodigo && !codigoEnviado,
              onPressed: _enviarCodigo,
            ),
            if (codigoEnviado) ...[
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Código de recuperación',
                  prefixIcon: const Icon(
                    Icons.pin_outlined,
                    color: AppColors.secondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                    borderSide: const BorderSide(
                      color: AppColors.borderDark,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              BotonPassword(
                texto: 'Verificar código',
                icono: Icons.verified_outlined,
                cargando: verificandoCodigo &&
                    tokenRecuperacion == null,
                onPressed: tokenRecuperacion != null
                    ? null
                    : _verificarCodigo,
              ),
            ],
            if (tokenRecuperacion != null) ...[
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              CampoPassword(
                controller: passwordController,
                etiqueta: 'Nueva contraseña',
                visible: mostrarPassword,
                onCambiarVisibilidad: () {
                  setState(() {
                    mostrarPassword =
                        !mostrarPassword;
                  });
                },
              ),
              const SizedBox(
                height: AppDimensions.spacingMd,
              ),
              CampoPassword(
                controller: confirmarPasswordController,
                etiqueta: 'Confirmar contraseña',
                visible: mostrarConfirmarPassword,
                onCambiarVisibilidad: () {
                  setState(() {
                    mostrarConfirmarPassword =
                        !mostrarConfirmarPassword;
                  });
                },
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              BotonPassword(
                texto: 'Cambiar contraseña',
                icono: Icons.lock_reset_outlined,
                cargando: cambiandoPassword,
                onPressed: _cambiarPassword,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    codigoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();

    super.dispose();
  }
}