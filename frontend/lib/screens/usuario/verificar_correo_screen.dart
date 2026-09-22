import 'package:flutter/material.dart';

import '../../services/usuario/auth_usuario_service.dart';

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

    final codigo =
        codigoController.text.trim();

    if (codigo.isEmpty) {
      mostrarMensaje(
        'Ingresa el código de verificación',
      );
      return;
    }

    if (codigo.length != 6) {
      mostrarMensaje(
        'El código debe tener 6 dígitos',
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
                'Correo verificado correctamente',
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
            'Código incorrecto',
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
        title: const Text(
          'Verificar correo',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              // ==================================================
              // ICONO
              // ==================================================

              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Colors.brown,
              ),

              const SizedBox(height: 24),

              // ==================================================
              // TÍTULO
              // ==================================================

              const Text(
                'Verifica tu correo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Hemos enviado un código de 6 dígitos '
                'a:\n${widget.correo}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // CÓDIGO
              // ==================================================

              TextField(
                controller: codigoController,
                keyboardType:
                    TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  labelText:
                      'Código de verificación',
                  prefixIcon:
                      Icon(Icons.password),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // BOTÓN
              // ==================================================

              SizedBox(
                height: 52,
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
                      : const Text(
                          'Verificar correo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // INFORMACIÓN
              // ==================================================

              const Text(
                'El código tiene una duración limitada. '
                'Si no lo encuentras, revisa también '
                'la carpeta de spam o correo no deseado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}