import 'package:flutter/material.dart';

class ControladorPantallaAdministrador extends ChangeNotifier {
  String opcion = 'inicio';

  void cambiarOpcion(String valor) {
    opcion = valor;
    notifyListeners();
  }

  String get titulo {
    switch (opcion) {
      case 'estadisticas':
        return 'Estadísticas';

      case 'sitios':
        return 'Sitios turísticos';

      case 'categorias':
        return 'Categorías';

      case 'contenido':
        return 'Contenido';

      case 'resenas':
        return 'Reseñas';

      case 'reservas':
        return 'Reservas';

      case 'reportes':
        return 'Reportes';

      case 'usuarios':
        return 'Usuarios';

      case 'perfil':
        return 'Mi cuenta';

      default:
        return 'Panel de administración';
    }
  }
}