import 'package:flutter/material.dart';

import 'screens/admin/admin_screen.dart';
import 'screens/mapa_screen_2.dart';
import 'screens/publico/bienvenida_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const MiRutaCafeteraApp(),
  );
}

class MiRutaCafeteraApp extends StatelessWidget {
  const MiRutaCafeteraApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Ruta Mágica del Café',
      debugShowCheckedModeBanner: false,

      // ======================================================
      // TEMA GLOBAL DE LA APLICACIÓN
      // ======================================================
      theme: AppTheme.light,

      // ======================================================
      // PÁGINA INICIAL
      // ======================================================
      home: const BienvenidaScreen(),

      // ======================================================
      // RUTAS
      // ======================================================
      routes: {
        // ----------------------------------------------------
        // ADMINISTRADOR
        // ----------------------------------------------------
        '/admin': (context) {
          return const AdminScreen(
            nombre: 'Administrador',
            email: 'admin@mirutacafetera.com',
          );
        },

        // ----------------------------------------------------
        // MAPA
        // ----------------------------------------------------
        '/mapa': (context) {
          return const MapaScreen2();
        },
      },
    );
  }
}