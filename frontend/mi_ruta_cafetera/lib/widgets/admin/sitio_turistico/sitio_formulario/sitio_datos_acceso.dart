import 'package:flutter/material.dart';

import 'campo_formulario_sitio.dart';
import 'contenedor_seccion_sitio.dart';
import 'titulo_seccion_sitio.dart';

class SitioDatosAcceso extends StatelessWidget {
  final bool esEdicion;
  final TextEditingController controladorNombre;
  final TextEditingController controladorApellido;
  final TextEditingController controladorCorreo;
  final TextEditingController controladorContrasena;
  final TextEditingController controladorTelefono;

  const SitioDatosAcceso({
    super.key,
    required this.esEdicion,
    required this.controladorNombre,
    required this.controladorApellido,
    required this.controladorCorreo,
    required this.controladorContrasena,
    required this.controladorTelefono,
  });

  @override
  Widget build(BuildContext context) {
    return ContenedorSeccionSitio(
      contenido: Column(
        children: [
          TituloSeccionSitio(
            icono: Icons.person_outline_rounded,
            titulo: 'Datos de acceso',
            subtitulo: esEdicion
                ? 'Información del responsable'
                : 'Cuenta que administrará este sitio',
          ),
          CampoFormularioSitio(
            controlador: controladorNombre,
            etiqueta: 'Nombre del responsable',
            icono: Icons.person_rounded,
            obligatorio: !esEdicion,
          ),
          CampoFormularioSitio(
            controlador: controladorApellido,
            etiqueta: 'Apellido del responsable',
            icono: Icons.person_outline_rounded,
            obligatorio: !esEdicion,
          ),
          CampoFormularioSitio(
            controlador: controladorCorreo,
            etiqueta: 'Correo de acceso',
            icono: Icons.email_rounded,
            tipoTeclado: TextInputType.emailAddress,
            obligatorio: !esEdicion,
          ),
          CampoFormularioSitio(
            controlador: controladorContrasena,
            etiqueta: esEdicion
                ? 'Nueva contraseña (opcional)'
                : 'Contraseña',
            icono: Icons.lock_rounded,
            ocultarTexto: true,
            obligatorio: !esEdicion,
          ),
          CampoFormularioSitio(
            controlador: controladorTelefono,
            etiqueta: 'Teléfono de la cuenta',
            icono: Icons.phone_rounded,
            tipoTeclado: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}