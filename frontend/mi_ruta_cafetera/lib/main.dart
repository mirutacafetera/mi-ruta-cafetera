
import 'package:flutter/material.dart';

import 'screens/admin/pantalla_administrador.dart';
import 'screens/mapa_screen_2.dart';
import 'screens/publico/bienvenida_screen.dart';
import 'screens/sitio/sitio_login_screen.dart';
import 'screens/usuario/login_usuario_screen.dart';
import 'screens/usuario/registro_usuario_screen.dart';
import 'services/admin/admin_servicio_autenticacion.dart';
import 'services/google_auth_service.dart';
import 'services/usuario/preferencias_service.dart';
import 'services/usuario/usuario_sesion_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GoogleAuthService.instance.initialize();
  await AdminServicioAutenticacion.cargarToken();
  await UsuarioSesionService.instance.restaurar();
  await PreferenciasService.instance.restaurar();

  runApp(const MiRutaCafeteraApp());
}

class MiRutaCafeteraApp extends StatelessWidget {
  const MiRutaCafeteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FuenteApp>(
      valueListenable: PreferenciasService.instance.fuente,
      builder: (context, fuente, _) {
        return _construirApp(fuente);
      },
    );
  }

  Widget _construirApp(FuenteApp fuente) {
    return MaterialApp(
      title: 'Mi Ruta Cafetera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.construir(fontFamily: fuente.familia),

      builder: (context, child) {
        return ValueListenableBuilder<TamanoTexto>(
          valueListenable: PreferenciasService.instance.tamanoTexto,
          builder: (context, tamano, _) {
            final media = MediaQuery.of(context);
            final escalaSistema = media.textScaler.scale(1.0);

            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  (escalaSistema * tamano.factor)
                      .clamp(0.8, 1.8)
                      .toDouble(),
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },

      initialRoute: '/',

      routes: {
        // PRIMERA PANTALLA DE LA APLICACIÓN
        '/': (context) => const BienvenidaScreen(),

        // ADMINISTRADOR
        '/admin': (context) {
          return const PantallaAdministrador(
            nombre: 'Administrador',
            email: 'admin@mirutacafetera.com',
          );
        },

        // INICIO DE SESIÓN DEL SITIO TURÍSTICO
        '/sitio-login': (context) {
          return const SitioLoginScreen();
        },

        // MAPA GENERAL: exclusivo de usuarios con sesión
        '/mapa': (context) {
          if (UsuarioSesionService.instance.sesionActual.value == null) {
            return const LoginUsuarioScreen();
          }

          return const MapaScreen2();
        },

        // INICIO DE SESIÓN DEL USUARIO
        '/login-usuario': (context) {
          return const LoginUsuarioScreen();
        },

        // REGISTRO DE USUARIO
        '/registro-usuario': (context) {
          return const RegistroUsuarioScreen();
        },
      },
    );
  }
}
