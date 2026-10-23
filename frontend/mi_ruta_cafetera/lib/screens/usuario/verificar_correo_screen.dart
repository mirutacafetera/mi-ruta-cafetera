import 'package:flutter/material.dart';

import '../../services/usuario/auth_usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

class VerificarCorreoScreen extends StatefulWidget {
  final String correo;

  const VerificarCorreoScreen({
    super.key,
    required this.correo,
  });

  @override
  State<VerificarCorreoScreen> createState() =>
      _VerificarCorreoScreenState();
}

class _VerificarCorreoScreenState
    extends State<VerificarCorreoScreen> {
  final codigoController = TextEditingController();

  bool cargando = false;

  @override
  void dispose() {
    codigoController.dispose();
    super.dispose();
  }

  // ============================================================
  // MOSTRAR MENSAJE
  // ============================================================

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // ============================================================
  // VERIFICAR CORREO
  // ============================================================

  Future<void> _verificarCorreo() async {
    FocusScope.of(context).unfocus();

    final codigo = codigoController.text.trim();

    if (codigo.isEmpty) {
      mostrarMensaje(
        Textos.t('Ingresa el código de verificación'),
      );
      return;
    }

    if (codigo.length != 6) {
      mostrarMensaje(
        Textos.t('El código debe tener 6 dígitos'),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado =
        await AuthUsuarioService.verificarCorreo(
      correo: widget.correo,
      codigo: codigo,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (resultado['exito'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado['mensaje'] ??
                Textos.t('Correo verificado correctamente'),
          ),
        ),
      );

      // ========================================================
      // VOLVER AL LOGIN
      // ========================================================

      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } else {
      mostrarMensaje(
        resultado['mensaje'] ??
            Textos.t('Código incorrecto'),
      );
    }
  }

  // ============================================================
  // CONSTRUCCIÓN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Tr(
          'Verificar correo',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppDimensions.spacingXxl,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: AppDimensions.spacingSection - 2,
              ),

              // ==================================================
              // ICONO
              // ==================================================

              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.secondary,
              ),

              const SizedBox(
                height: AppDimensions.spacingXl,
              ),

              // ==================================================
              // TÍTULO
              // ==================================================

              const Tr(
                'Verifica tu correo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd,
              ),

              Tr(
                'Hemos enviado un código de 6 dígitos a:\n{0}', args: [widget.correo],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingSection + 3,
              ),

              // ==================================================
              // CÓDIGO
              // ==================================================

              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: Textos.t('Código de verificación'),
                  prefixIcon: const Icon(
                    Icons.password,
                  ),
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXl + 4,
              ),

              // ==================================================
              // BOTÓN
              // ==================================================

              SizedBox(
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: cargando
                      ? null
                      : _verificarCorreo,
                  child: cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Tr(
                          'Verificar correo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingLg + 4,
              ),

              // ==================================================
              // INFORMACIÓN
              // ==================================================

              const Tr(
                'El código tiene una duración limitada. Si no lo encuentras, revisa también la carpeta de spam o correo no deseado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}