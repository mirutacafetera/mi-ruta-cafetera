import 'package:flutter/material.dart';

import 'sitio_form_field.dart';
import 'sitio_section_card.dart';
import 'sitio_section_title.dart';

class SitioDatosAcceso extends StatelessWidget {
  final bool esEdicion;

  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController correoController;
  final TextEditingController passwordController;
  final TextEditingController telefonoController;

  const SitioDatosAcceso({
    super.key,
    required this.esEdicion,
    required this.nombreController,
    required this.apellidoController,
    required this.correoController,
    required this.passwordController,
    required this.telefonoController,
  });

  @override
  Widget build(BuildContext context) {
    return SitioSectionCard(
      child: Column(
        children: [
          SitioSectionTitle(
            icono: Icons.person_outline_rounded,
            titulo: 'Datos de acceso',
            subtitulo: esEdicion
                ? 'Información del responsable'
                : 'Cuenta que administrará este sitio',
          ),

          SitioFormField(
            controller: nombreController,
            label: 'Nombre del responsable',
            icon: Icons.person_rounded,
            obligatorio: !esEdicion,
          ),

          SitioFormField(
            controller: apellidoController,
            label: 'Apellido del responsable',
            icon: Icons.person_outline_rounded,
            obligatorio: !esEdicion,
          ),

          SitioFormField(
            controller: correoController,
            label: 'Correo de acceso',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            obligatorio: !esEdicion,
          ),

          SitioFormField(
            controller: passwordController,
            label: esEdicion
                ? 'Nueva contraseña (opcional)'
                : 'Contraseña',
            icon: Icons.lock_rounded,
            obscureText: true,
            obligatorio: !esEdicion,
          ),

          SitioFormField(
            controller: telefonoController,
            label: 'Teléfono de la cuenta',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}