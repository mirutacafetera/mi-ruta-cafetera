
import 'package:flutter/material.dart';

class SitioAvatarPerfil extends StatelessWidget {
  final String? fotoPerfil;
  final String nombre;
  final double radio;
  final Color colorFondo;
  final Color colorIcono;

  const SitioAvatarPerfil({
    super.key,
    required this.fotoPerfil,
    required this.nombre,
    this.radio = 24,
    this.colorFondo = const Color(0xFF194F3A),
    this.colorIcono = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final foto = fotoPerfil?.trim();

    final uri = foto == null ? null : Uri.tryParse(foto);
    final fotoValida = uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    return CircleAvatar(
      radius: radio,
      backgroundColor: colorFondo,
      child: ClipOval(
        child: SizedBox(
          width: radio * 2,
          height: radio * 2,
          child: fotoValida
              ? Image.network(
                  foto!,
                  width: radio * 2,
                  height: radio * 2,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return Center(
                      child: SizedBox(
                        width: radio * 0.7,
                        height: radio * 0.7,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorIcono,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _iconoPerfil();
                  },
                )
              : _iconoPerfil(),
        ),
      ),
    );
  }

  Widget _iconoPerfil() {
    return Center(
      child: Tooltip(
        message: nombre.isEmpty ? 'Perfil de usuario' : nombre,
        child: Icon(
          Icons.person_rounded,
          size: radio * 1.15,
          color: colorIcono,
        ),
      ),
    );
  }
}
