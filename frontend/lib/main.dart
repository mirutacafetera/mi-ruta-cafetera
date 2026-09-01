import 'package:flutter/material.dart';

import 'screens/admin/admin_screen.dart';
import 'screens/mapa_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
        ),
        useMaterial3: true,
      ),

      initialRoute: '/admin',

      routes: {
        '/admin': (context) {
          return const AdminScreen(
            nombre: 'Administrador',
            email: 'admin@mirutacafetera.com',
          );
        },

        '/mapa': (context) {
          return const MapaScreen();
        },
      },
    );
  }
}