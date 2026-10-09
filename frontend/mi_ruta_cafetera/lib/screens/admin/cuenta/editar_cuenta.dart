import 'package:flutter/material.dart';

import '../../../controllers/admin/cuenta/cuenta_admin_controlador.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/cuenta/editar_cuenta/boton_guardar_cuenta.dart';
import '../../../widgets/admin/cuenta/editar_cuenta/campo_editar_cuenta.dart';
import '../../../widgets/admin/cuenta/editar_cuenta/seccion_editar_cuenta.dart';
import '../../../widgets/admin/sitio_turistico/sitio_formulario/boton_cancelar_sitio.dart';

class EditarCuenta extends StatefulWidget {
  final CuentaAdminController controller;

  const EditarCuenta({
    super.key,
    required this.controller,
  });

  @override
  State<EditarCuenta> createState() => _EditarCuentaState();
}

class _EditarCuentaState extends State<EditarCuenta> {
  late final TextEditingController nombreController;
  late final TextEditingController apellidoController;
  late final TextEditingController correoController;
  late final TextEditingController telefonoController;

  @override
  void initState() {
    super.initState();

    final cuenta = widget.controller.cuenta;

    nombreController = TextEditingController(
      text: cuenta?.nombre ?? '',
    );

    apellidoController = TextEditingController(
      text: cuenta?.apellido ?? '',
    );

    correoController = TextEditingController(
      text: cuenta?.correo ?? '',
    );

    telefonoController = TextEditingController(
      text: cuenta?.telefono ?? '',
    );
  }

  Future<void> _guardar() async {
    final cuenta = widget.controller.cuenta;

    if (cuenta == null) {
      return;
    }

    if (nombreController.text.trim().isEmpty ||
        apellidoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nombre y apellido son obligatorios.',
          ),
        ),
      );
      return;
    }

    final actualizado =
        await widget.controller.actualizarCuenta(
      idAdministrador: cuenta.id,
      nombre: nombreController.text,
      apellido: apellidoController.text,
      telefono: telefonoController.text,
    );

    if (!mounted) {
      return;
    }

    if (actualizado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Información actualizada correctamente.',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.error ??
                'No fue posible actualizar la información.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuenta = widget.controller.cuenta;

    if (cuenta == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No hay información de la cuenta.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar información',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.spacingXl,
            ),
            child: Column(
              children: [
                SeccionEditarCuenta(
                  titulo: 'Información personal',
                  icono: Icons.person_outline,
                  child: Column(
                    children: [
                      CampoEditarCuenta(
                        controller: nombreController,
                        etiqueta: 'Nombre',
                        icono: Icons.person_outline,
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      CampoEditarCuenta(
                        controller: apellidoController,
                        etiqueta: 'Apellido',
                        icono: Icons.person_outline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingLg,
                ),
                SeccionEditarCuenta(
                  titulo: 'Información de contacto',
                  icono: Icons.contact_mail_outlined,
                  child: Column(
                    children: [
                      CampoEditarCuenta(
                        controller: correoController,
                        etiqueta: 'Correo',
                        icono: Icons.email_outlined,
                        soloLectura: true,
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingMd,
                      ),
                      CampoEditarCuenta(
                        controller: telefonoController,
                        etiqueta: 'Teléfono',
                        icono: Icons.phone_outlined,
                        tipoTeclado: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXl,
                ),
                BotonGuardarCuenta(
                  guardando: widget.controller.guardando,
                  onPressed: _guardar,
                ),
                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),
                BotonCancelarSitio(
                  deshabilitado: widget.controller.guardando,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    telefonoController.dispose();

    super.dispose();
  }
}