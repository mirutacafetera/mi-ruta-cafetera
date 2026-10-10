import 'package:flutter/material.dart';

import 'screens/admin/pantalla_administrador.dart';
import 'screens/mapa_screen_2.dart';
import 'screens/publico/bienvenida_screen.dart';
import 'screens/sitio/sitio_login_screen.dart';
import 'screens/usuario/login_usuario_screen.dart';
import 'screens/usuario/registro_usuario_screen.dart';
import 'services/admin/admin_servicio_autenticacion.dart';
import 'services/google_auth_service.dart';
import 'services/usuario/usuario_sesion_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GoogleAuthService.instance.initialize();
  await AdminServicioAutenticacion.cargarToken();
  await UsuarioSesionService.instance.restaurar();

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
      title: 'Mi Ruta Cafetera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BienvenidaScreen(),
      routes: {
        '/admin': (context) {
          return const PantallaAdministrador(
            nombre: 'Administrador',
            email: 'admin@mirutacafetera.com',
          );
        },

        '/sitio-login': (context) {
          return const SitioLoginScreen();
        },

        // MAPA GENERAL: exclusivo de usuarios con sesión.
        '/mapa': (context) {
          if (UsuarioSesionService.instance.sesionActual.value ==
              null) {
            return const LoginUsuarioScreen();
          }

          return const MapaScreen2();
        },

        // USUARIO
        '/login-usuario': (context) {
          return const LoginUsuarioScreen();
        },

        '/registro-usuario': (context) {
          return const RegistroUsuarioScreen();
        },
      },
    );
  }
}
