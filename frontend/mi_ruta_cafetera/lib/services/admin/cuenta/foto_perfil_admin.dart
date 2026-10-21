
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FotoPerfilAdmin {
  static const String _claveFoto = 'foto_perfil_admin';
  static const String _nombreArchivo = 'foto_perfil_admin.jpg';

  static Future<String?> obtenerRuta() async {
    final preferencias = await SharedPreferences.getInstance();
    final ruta = preferencias.getString(_claveFoto);

    if (ruta == null || ruta.isEmpty) {
      return null;
    }

    if (!await File(ruta).exists()) {
      await preferencias.remove(_claveFoto);
      return null;
    }

    return ruta;
  }

  static Future<String?> seleccionarYGuardar() async {
    try {
      final imagen = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
      );

      if (imagen == null) {
        return null;
      }

      final directorio = await getApplicationDocumentsDirectory();
      final rutaDestino = '${directorio.path}/$_nombreArchivo';

      final archivo = await File(imagen.path).copy(rutaDestino);

      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(_claveFoto, archivo.path);

      return archivo.path;
    } catch (e) {
      debugPrint('Error al seleccionar la foto: $e');
      rethrow;
    }
  }

  static Future<void> eliminarFoto() async {
    final preferencias = await SharedPreferences.getInstance();
    final ruta = preferencias.getString(_claveFoto);

    await preferencias.remove(_claveFoto);

    if (ruta != null) {
      final archivo = File(ruta);

      if (await archivo.exists()) {
        await archivo.delete();
      }
    }
  }
}
