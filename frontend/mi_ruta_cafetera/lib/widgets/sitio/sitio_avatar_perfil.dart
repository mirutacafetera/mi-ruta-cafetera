import 'package:flutter/material.dart';

import '../../models/usuario/avatar_cafetero_model.dart';
import '../usuario/avatar_cafetero.dart';

class SitioAvatarPerfil extends StatelessWidget {
  final String? fotoPerfil;
  final String nombre;
  final double radio;
  final Color colorFondo;
  final Color colorIcono;

  // Avatar cafetero opcional. Solo se muestra cuando el usuario
  // lo activó (avatar.usar == true); en cualquier otro caso se
  // conserva el comportamiento anterior (foto o ícono).
  final AvatarCafeteroModel? avatar;

  const SitioAvatarPerfil({
    super.key,
    required this.fotoPerfil,
    required this.nombre,
    this.radio = 24,
    this.colorFondo = const Color(0xFF194F3A),
    this.colorIcono = Colors.white,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final avatarActivo = avatar;

    if (avatarActivo != null && avatarActivo.usar) {
      return Tooltip(
        message: nombre.isEmpty ? 'Perfil de usuario' : nombre,
        child: AvatarCafetero(
          avatar: avatarActivo,
          size: radio * 2,
        ),
      );
    }

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
