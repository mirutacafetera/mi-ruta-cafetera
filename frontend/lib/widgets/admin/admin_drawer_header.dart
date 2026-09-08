import 'package:flutter/material.dart';

class AdminDrawerHeader extends StatelessWidget {
  final String nombre;
  final String email;

  const AdminDrawerHeader({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
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
    );
  }
}