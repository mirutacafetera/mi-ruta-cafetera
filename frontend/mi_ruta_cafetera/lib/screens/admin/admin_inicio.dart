
import 'package:flutter/material.dart';

import '../../controllers/admin/cuenta/foto_perfil_admin_controlador.dart';
import '../../widgets/admin/cuenta/foto_perfil.dart';
import '../../widgets/admin/fondo_admin.dart';

class AdminInicio extends StatelessWidget {
  final String nombre;
  final String email;
  final FotoPerfilAdminControlador fotoPerfilControlador;
  final VoidCallback onAbrirMapa;
  final VoidCallback onGestionarSitios;
  final VoidCallback onGestionarUsuarios;
  final VoidCallback onAbrirCuenta;

  const AdminInicio({
    super.key,
    required this.nombre,
    required this.email,
    required this.fotoPerfilControlador,
    required this.onAbrirMapa,
    required this.onGestionarSitios,
    required this.onGestionarUsuarios,
    required this.onAbrirCuenta,
  });

  static const Color _verde = Color(0xFF174D3A);
  static const Color _crema = Color(0xFFFFF9F0);
  static const Color _cafe = Color(0xFFB58A6A);
  static const Color _naranja = Color(0xFFF47B20);
  static const Color _texto = Color(0xFF293A32);
  static const Color _gris = Color(0xFF454A45);

  @override
  Widget build(BuildContext context) {
    return FondoAdmin(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _encabezado(),
            const SizedBox(height: 25),
            _tarjetaOpcion(
              icono: Icons.map_outlined,
              titulo: 'Mapa turístico',
              descripcion: 'Explora los destinos de la ruta cafetera.',
              color: _verde,
              fondoIcono: const Color(0xFFE7F0E5),
              onTap: onAbrirMapa,
            ),
            _tarjetaOpcion(
              icono: Icons.place_outlined,
              titulo: 'Gestionar sitios',
              descripcion: 'Administra los sitios turísticos.',
              color: _naranja,
              fondoIcono: const Color(0xFFFFEEDB),
              onTap: onGestionarSitios,
            ),
            _tarjetaOpcion(
              icono: Icons.people_outline_rounded,
              titulo: 'Gestionar usuarios',
              descripcion: 'Consulta y administra los usuarios.',
              color: const Color(0xFF397C70),
              fondoIcono: const Color(0xFFE3F1EC),
              onTap: onGestionarUsuarios,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: _cafe.withValues(alpha: 0.65),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.coffee_rounded,
                    color: _cafe,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: _cafe.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _tarjetaCuenta(),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _verde,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cafe, width: 1),
            boxShadow: [
              BoxShadow(
                color: _cafe.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: _crema,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Gestión del administrador',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _verde,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Administra los mapas, sitios turísticos y usuarios '
            'de Mi Ruta Cafetera.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _gris,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaOpcion({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    required Color fondoIcono,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 105,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _cafe.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _cafe.withValues(alpha: 0.09),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: fondoIcono,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _texto,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _gris,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaCuenta() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 105),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _cafe,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _cafe.withValues(alpha: 0.1),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onAbrirCuenta,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _naranja,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _naranja.withValues(alpha: 0.10),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: FotoPerfil(
                      controlador: fotoPerfilControlador,
                      radio: 29,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _verde,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _gris,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _verde,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
