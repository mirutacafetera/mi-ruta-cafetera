import 'package:flutter/material.dart';

import 'screens/admin/admin_screen.dart';

void main() {
  runApp(const MiRutaCafeteraApp());
}

class MiRutaCafeteraApp extends StatelessWidget {
  const MiRutaCafeteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Ruta Cafetera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
        ),
        useMaterial3: true,
      ),
      home: const AdminScreen(
        nombre: 'Administrador',
        email: 'admin@mirutacafetera.com',
      ),
    );
  }
}