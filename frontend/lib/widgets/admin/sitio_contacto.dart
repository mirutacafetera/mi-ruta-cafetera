import 'package:flutter/material.dart';

import 'sitio_form_field.dart';
import 'sitio_section_card.dart';
import 'sitio_section_title.dart';

class SitioContacto extends StatelessWidget {
  final TextEditingController telefonoController;
  final TextEditingController correosController;
  final TextEditingController sitioWebController;

  const SitioContacto({
    super.key,
    required this.telefonoController,
    required this.correosController,
    required this.sitioWebController,
  });

  @override
  Widget build(BuildContext context) {
    return SitioSectionCard(
      child: Column(
        children: [
          const SitioSectionTitle(
            icono: Icons.contact_phone_outlined,
            titulo: 'Información de contacto',
            subtitulo: 'Datos para comunicarse con el sitio',
          ),

          SitioFormField(
            controller: telefonoController,
            label: 'Teléfono del sitio',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),

          SitioFormField(
            controller: correosController,
            label: 'Correo de contacto',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          SitioFormField(
            controller: sitioWebController,
            label: 'Sitio web',
            icon: Icons.language_rounded,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}