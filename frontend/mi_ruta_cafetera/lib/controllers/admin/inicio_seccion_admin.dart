import 'package:flutter/material.dart';

import '../../services/admin/admin_servicio_autenticacion.dart';

class InicioSesionAdmin extends ChangeNotifier {
  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool cargando = false;
  bool mostrarPassword = false;

  Future<Map<String, dynamic>> iniciarSesion() async {
    if (correoController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      throw Exception('Completa todos los campos.');
    }

    cargando = true;
    notifyListeners();

    try {
      return await AdminServicioAutenticacion.iniciarSesion(
        correo: correoController.text.trim(),
        password: passwordController.text,
      );
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void cambiarPassword() {
    mostrarPassword = !mostrarPassword;
    notifyListeners();
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}