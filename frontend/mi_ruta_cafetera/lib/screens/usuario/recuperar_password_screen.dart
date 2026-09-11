import 'package:flutter/material.dart';

import '../../services/usuario/auth_usuario_service.dart';

class RecuperarPasswordScreen
    extends StatefulWidget {
  const RecuperarPasswordScreen({
    super.key,
  });

  @override
  State<RecuperarPasswordScreen> createState() =>
      _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState
    extends State<RecuperarPasswordScreen> {
  // ============================================================
  // CONTROLADORES
  // ============================================================

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController codigoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController
      confirmarPasswordController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  int pasoActual = 1;

  bool cargando = false;

  bool ocultarPassword = true;

  bool ocultarConfirmacion = true;

  String tokenRecuperacion = '';

  // ============================================================
  // PASO 1 - ENVIAR CÓDIGO
  // ============================================================

  Future<void> _enviarCodigo() async {
    final correo =
        correoController.text.trim();

    if (correo.isEmpty) {
      _mostrarMensaje(
        'Ingresa tu correo electrónico',
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado =
        await AuthUsuarioService.recuperarPassword(
      correo: correo,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      cargando = false;
    });

    if (resultado['exito'] == true) {
      _mostrarMensaje(
        resultado['mensaje'],
      );

      setState(() {
        pasoActual = 2;
      });
    } else {
      _mostrarMensaje(
        resultado['mensaje'],
      );
    }
  }

  // ============================================================
  // PASO 2 - VERIFICAR CÓDIGO
  // ============================================================

  Future<void> _verificarCodigo() async {
    final correo =
        correoController.text.trim();

    final codigo =
        codigoController.text.trim();

    if (codigo.isEmpty) {
      _mostrarMensaje(
        'Ingresa el código recibido',
      );

      return;
    }

    if (codigo.length != 6) {
      _mostrarMensaje(
        'El código debe tener 6 dígitos',
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado =
        await AuthUsuarioService
            .verificarCodigoRecuperacion(
      correo: correo,
      codigo: codigo,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      cargando = false;
    });

    if (resultado['exito'] == true) {
      tokenRecuperacion =
          resultado['tokenRecuperacion'] ??
              '';

      _mostrarMensaje(
        resultado['mensaje'],
      );

      setState(() {
        pasoActual = 3;
      });
    } else {
      _mostrarMensaje(
        resultado['mensaje'],
      );
    }
  }

  // ============================================================
  // PASO 3 - CAMBIAR CONTRASEÑA
  // ============================================================

  Future<void> _cambiarPassword() async {
    final password =
        passwordController.text;

    final confirmar =
        confirmarPasswordController.text;

    if (password.isEmpty ||
        confirmar.isEmpty) {
      _mostrarMensaje(
        'Completa todos los campos',
      );

      return;
    }

    if (password != confirmar) {
      _mostrarMensaje(
        'Las contraseñas no coinciden',
      );

      return;
    }

    if (password.length < 6) {
      _mostrarMensaje(
        'La contraseña debe tener mínimo 6 caracteres',
      );

      return;
    }

    if (tokenRecuperacion.isEmpty) {
      _mostrarMensaje(
        'El proceso de recuperación no es válido',
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado =
        await AuthUsuarioService
            .restablecerPassword(
      tokenRecuperacion:
          tokenRecuperacion,
      nuevaPassword:
          password,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      cargando = false;
    });

    if (resultado['exito'] == true) {
      _mostrarMensaje(
        resultado['mensaje'],
      );

      Navigator.pop(context);
    } else {
      _mostrarMensaje(
        resultado['mensaje'],
      );
    }
  }

  // ============================================================
  // MOSTRAR MENSAJE
  // ============================================================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // ============================================================
  // PASOS
  // ============================================================

  Widget _contenidoPaso() {
    switch (pasoActual) {
      case 1:
        return _pasoCorreo();

      case 2:
        return _pasoCodigo();

      case 3:
        return _pasoNuevaPassword();

      default:
        return _pasoCorreo();
    }
  }

  // ============================================================
  // PASO 1 - CORREO
  // ============================================================

  Widget _pasoCorreo() {
    return Column(
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 70,
          color: Colors.brown,
        ),

        const SizedBox(
          height: 20,
        ),

        const Text(
          '¿Olvidaste tu contraseña?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        const Text(
          'Ingresa tu correo y te enviaremos '
          'un código para recuperar tu cuenta.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
          ),
        ),

        const SizedBox(
          height: 30,
        ),

        TextField(
          controller:
              correoController,
          keyboardType:
              TextInputType.emailAddress,
          decoration:
              const InputDecoration(
            labelText:
                'Correo electrónico',
            hintText:
                'Ingresa tu correo',
            prefixIcon:
                Icon(
              Icons.email_outlined,
            ),
            border:
                OutlineInputBorder(),
          ),
        ),

        const SizedBox(
          height: 25,
        ),

        _boton(
          texto: 'Enviar código',
          onPressed: _enviarCodigo,
        ),
      ],
    );
  }

  // ============================================================
  // PASO 2 - CÓDIGO
  // ============================================================

  Widget _pasoCodigo() {
    return Column(
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 70,
          color: Colors.brown,
        ),

        const SizedBox(
          height: 20,
        ),

        const Text(
          'Verifica tu código',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          'Enviamos un código de 6 dígitos a\n'
          '${correoController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),

        const SizedBox(
          height: 30,
        ),

        TextField(
          controller:
              codigoController,
          keyboardType:
              TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration:
              const InputDecoration(
            labelText: 'Código',
            hintText: '000000',
            prefixIcon:
                Icon(
              Icons.pin_outlined,
            ),
            border:
                OutlineInputBorder(),
          ),
        ),

        const SizedBox(
          height: 15,
        ),

        _boton(
          texto: 'Verificar código',
          onPressed:
              _verificarCodigo,
        ),

        const SizedBox(
          height: 10,
        ),

        TextButton(
          onPressed: cargando
              ? null
              : _enviarCodigo,
          child: const Text(
            'Enviar código nuevamente',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PASO 3 - NUEVA CONTRASEÑA
  // ============================================================

  Widget _pasoNuevaPassword() {
    return Column(
      children: [
        const Icon(
          Icons.lock_reset_outlined,
          size: 70,
          color: Colors.brown,
        ),

        const SizedBox(
          height: 20,
        ),

        const Text(
          'Nueva contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        const Text(
          'Crea una nueva contraseña para '
          'volver a acceder a tu cuenta.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
          ),
        ),

        const SizedBox(
          height: 30,
        ),

        TextField(
          controller:
              passwordController,
          obscureText:
              ocultarPassword,
          decoration:
              InputDecoration(
            labelText:
                'Nueva contraseña',
            prefixIcon:
                const Icon(
              Icons.lock_outline,
            ),
            suffixIcon:
                IconButton(
              icon: Icon(
                ocultarPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  ocultarPassword =
                      !ocultarPassword;
                });
              },
            ),
            border:
                const OutlineInputBorder(),
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        TextField(
          controller:
              confirmarPasswordController,
          obscureText:
              ocultarConfirmacion,
          decoration:
              InputDecoration(
            labelText:
                'Confirmar contraseña',
            prefixIcon:
                const Icon(
              Icons.lock_outline,
            ),
            suffixIcon:
                IconButton(
              icon: Icon(
                ocultarConfirmacion
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  ocultarConfirmacion =
                      !ocultarConfirmacion;
                });
              },
            ),
            border:
                const OutlineInputBorder(),
          ),
        ),

        const SizedBox(
          height: 25,
        ),

        _boton(
          texto:
              'Cambiar contraseña',
          onPressed:
              _cambiarPassword,
        ),
      ],
    );
  }

  // ============================================================
  // BOTÓN
  // ============================================================

  Widget _boton({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            cargando
                ? null
                : onPressed,
        child: cargando
            ? const SizedBox(
                width: 24,
                height: 24,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(
                texto,
                style:
                    const TextStyle(
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // INDICADOR DE PASO
  // ============================================================

  Widget _indicadorPaso(int paso) {
    final activo =
        pasoActual >= paso;

    return CircleAvatar(
      radius: 18,
      backgroundColor:
          activo
              ? Colors.brown
              : Colors.grey.shade300,
      child: Text(
        '$paso',
        style: TextStyle(
          color: activo
              ? Colors.white
              : Colors.black54,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // LÍNEA ENTRE PASOS
  // ============================================================

  Widget _lineaPaso() {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey.shade300,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    correoController.dispose();
    codigoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recuperar contraseña',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                children: [
                  // ==============================================
                  // INDICADOR DE PASOS
                  // ==============================================

                  Row(
                    children: [
                      _indicadorPaso(1),

                      _lineaPaso(),

                      _indicadorPaso(2),

                      _lineaPaso(),

                      _indicadorPaso(3),
                    ],
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  _contenidoPaso(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}