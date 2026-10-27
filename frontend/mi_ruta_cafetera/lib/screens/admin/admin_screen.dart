
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AdminInicio extends StatelessWidget {
  final String nombre;
  final String email;
  final VoidCallback onAbrirMapa;
  final VoidCallback onGestionarSitios;
  final VoidCallback onGestionarUsuarios;
  final VoidCallback onAbrirCuenta;

  const AdminInicio({
    super.key,
    required this.nombre,
    required this.email,
    required this.onAbrirMapa,
    required this.onGestionarSitios,
    required this.onGestionarUsuarios,
    required this.onAbrirCuenta,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tarjetaCuenta(),
          const SizedBox(height: 24),
          const Text(
            'Panel de administración',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _tarjetaOpcion(
            icono: Icons.map_outlined,
            titulo: 'Mapa turístico',
            descripcion: 'Explora los sitios turísticos.',
            color: Colors.green,
            onTap: onAbrirMapa,
          ),
          _tarjetaOpcion(
            icono: Icons.place_outlined,
            titulo: 'Gestionar sitios',
            descripcion: 'Administra los sitios turísticos.',
            color: Colors.orange,
            onTap: onGestionarSitios,
          ),
          _tarjetaOpcion(
            icono: Icons.people_outline,
            titulo: 'Gestionar usuarios',
            descripcion: 'Consulta los usuarios registrados.',
            color: Colors.teal,
            onTap: onGestionarUsuarios,
          ),
        ],
      ),
    );
  }

  Widget _tarjetaCuenta() {
    return InkWell(
      onTap: onAbrirCuenta,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ver mi cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaOpcion({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icono, color: color),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(descripcion),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
