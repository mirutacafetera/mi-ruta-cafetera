import 'package:flutter/material.dart';

class SitioSectionTitle extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;

  const SitioSectionTitle({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
  });

  static const Color verdePrincipal = Color(0xFF31572C);
  static const Color verdeOscuro = Color(0xFF1B4332);
  static const Color grisTexto = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: verdePrincipal.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icono,
              color: verdePrincipal,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: verdeOscuro,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: grisTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}