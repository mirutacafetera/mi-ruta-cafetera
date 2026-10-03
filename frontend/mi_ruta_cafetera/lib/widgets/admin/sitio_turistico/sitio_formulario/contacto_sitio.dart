import 'package:flutter/material.dart';

import 'campo_formulario_sitio.dart';
import 'contenedor_seccion_sitio.dart';
import 'titulo_seccion_sitio.dart';

class ContactoSitio extends StatelessWidget {
  final TextEditingController controladorTelefono;
  final TextEditingController controladorCorreos;
  final TextEditingController controladorSitioWeb;

  const ContactoSitio({
    super.key,
    required this.controladorTelefono,
    required this.controladorCorreos,
    required this.controladorSitioWeb,
  });

  @override
  Widget build(BuildContext context) {
    return ContenedorSeccionSitio(
      contenido: Column(
        children: [
          const TituloSeccionSitio(
            icono: Icons.contact_phone_outlined,
            titulo: 'Información de contacto',
            subtitulo: 'Datos para comunicarse con el sitio',
          ),
          CampoFormularioSitio(
            controlador: controladorTelefono,
            etiqueta: 'Teléfono del sitio',
            icono: Icons.phone_rounded,
            tipoTeclado: TextInputType.phone,
          ),
          CampoFormularioSitio(
            controlador: controladorCorreos,
            etiqueta: 'Correo de contacto',
            icono: Icons.email_outlined,
            tipoTeclado: TextInputType.emailAddress,
          ),
          CampoFormularioSitio(
            controlador: controladorSitioWeb,
            etiqueta: 'Sitio web',
            icono: Icons.language_rounded,
            tipoTeclado: TextInputType.url,
          ),
        ],
      ),
    );
  }
}