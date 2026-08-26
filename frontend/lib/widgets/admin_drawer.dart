import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final String nombre;
  final String email;
  final Function(String) onOpcionSeleccionada;

  const AdminDrawer({
    super.key,
    required this.nombre,
    required this.email,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Encabezado del administrador
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                size: 35,
                color: Color(0xFF1B5E20),
              ),
            ),
            accountName: Text(
              nombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(email),
          ),

          // Inicio
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Inicio'),
            onTap: () {
              onOpcionSeleccionada('inicio');
              Navigator.pop(context);
            },
          ),

          // Estadísticas
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Estadísticas'),
            onTap: () {
              onOpcionSeleccionada('estadisticas');
              Navigator.pop(context);
            },
          ),

          // Sitios turísticos
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Sitios turísticos'),
            onTap: () {
              onOpcionSeleccionada('sitios');
              Navigator.pop(context);
            },
          ),

          // Contenido
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Contenido'),
            onTap: () {
              onOpcionSeleccionada('contenido');
              Navigator.pop(context);
            },
          ),

          // Reseñas
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Reseñas'),
            onTap: () {
              onOpcionSeleccionada('resenas');
              Navigator.pop(context);
            },
          ),

          // Usuarios
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Usuarios'),
            onTap: () {
              onOpcionSeleccionada('usuarios');
              Navigator.pop(context);
            },
          ),

          const Divider(),

          // Perfil del administrador
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi cuenta'),
            onTap: () {
              onOpcionSeleccionada('perfil');
              Navigator.pop(context);
            },
          ),

          const Spacer(),

          // Cerrar sesión
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () {
              onOpcionSeleccionada('logout');
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }
}