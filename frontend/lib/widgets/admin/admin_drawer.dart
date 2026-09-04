import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final String nombre;
  final String email;
  final void Function(String) onOpcionSeleccionada;

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
          // =====================================================
          // INFORMACIÓN DEL ADMINISTRADOR
          // =====================================================

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

          // =====================================================
          // INICIO
          // =====================================================

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Inicio'),
            onTap: () {
              onOpcionSeleccionada('inicio');
              Navigator.pop(context);
            },
          ),

          // =====================================================
          // ESTADÍSTICAS
          // =====================================================

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Estadísticas'),
            onTap: () {
              onOpcionSeleccionada('estadisticas');
              Navigator.pop(context);
            },
          ),

          // =====================================================
          // SITIOS TURÍSTICOS
          // =====================================================

          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Sitios turísticos'),
            onTap: () {
              onOpcionSeleccionada('sitios');
              Navigator.pop(context);
            },
          ),

          // =====================================================
          // CATEGORÍAS
          // =====================================================

          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () {
              onOpcionSeleccionada('categorias');
              Navigator.pop(context);
            },
          ),

          // =====================================================
          // CONTENIDO
          // =====================================================

          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Contenido'),
            onTap: () {
              onOpcionSeleccionada('contenido');
              Navigator.pop(context);
            },
          ),

          // =====================================================
          // RESEÑAS
          // =====================================================

          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Reseñas'),
            onTap: () {
              onOpcionSeleccionada('resenas');
              Navigator.pop(context);
            },
          ),

          // =====================================================
          // USUARIOS
          // =====================================================

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Usuarios'),
            onTap: () {
              onOpcionSeleccionada('usuarios');
              Navigator.pop(context);
            },
          ),

          const Divider(),

          // =====================================================
          // MI CUENTA
          // =====================================================

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi cuenta'),
            onTap: () {
              onOpcionSeleccionada('perfil');
              Navigator.pop(context);
            },
          ),

          // =====================================================
          // ESPACIO
          // =====================================================

          const Spacer(),

          // =====================================================
          // CERRAR SESIÓN
          // =====================================================

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