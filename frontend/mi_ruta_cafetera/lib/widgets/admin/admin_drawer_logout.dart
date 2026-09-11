import 'package:flutter/material.dart';

class AdminDrawerLogout extends StatelessWidget {
  final Function(String) onOpcionSeleccionada;

  const AdminDrawerLogout({
    super.key,
    required this.onOpcionSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}