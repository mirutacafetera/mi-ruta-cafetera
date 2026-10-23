import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// PREFERENCIAS DE LA APLICACIÓN
// ============================================================
//
// * Tamaño de texto (pequeño / normal / grande): se aplica con
//   MediaQuery.textScaler desde main.dart.
// * Tipo de letra (predeterminada / Lora / Poppins / Nunito): se aplica al tema
//   completo (AppTheme.construir) desde main.dart.
//
// * Idioma (Español / English): lo consume lib/l10n/textos.dart mediante
//   IdiomaScope (main.dart); se aplica al instante, sin reiniciar.
//
// Todas se guardan en el dispositivo (SharedPreferences), de forma
// independiente, y se restauran al abrir la aplicación.
// ============================================================

enum TamanoTexto {
  pequeno('pequeno', 'Pequeño', 0.9),
  normal('normal', 'Normal', 1.0),
  grande('grande', 'Grande', 1.15);

  const TamanoTexto(this.id, this.etiqueta, this.factor);

  final String id;
  final String etiqueta;
  final double factor;

  static TamanoTexto desdeId(String? id) {
    return TamanoTexto.values.firstWhere(
      (t) => t.id == id,
      orElse: () => TamanoTexto.normal,
    );
  }
}

/// Tipo de letra de la aplicación.
///
/// [familia] es el nombre declarado en pubspec.yaml (Lora, Poppins y
/// Nunito se incluyen como archivos locales, por lo que funcionan sin
/// conexión).
/// La fuente predeterminada conserva 'Roboto', la que ya usa el tema.
/// Si [id] se guardó con una fuente que ya no existe, [desdeId] vuelve
/// a la predeterminada.
enum FuenteApp {
  predeterminada('predeterminada', 'Predeterminada', 'Roboto'),
  lora('lora', 'Lora (con serifa)', 'Lora'),
  poppins('poppins', 'Poppins (moderna)', 'Poppins'),
  nunito('nunito', 'Nunito (redondeada)', 'Nunito');

  const FuenteApp(this.id, this.etiqueta, this.familia);

  final String id;
  final String etiqueta;
  final String familia;

  static FuenteApp desdeId(String? id) {
    return FuenteApp.values.firstWhere(
      (f) => f.id == id,
      orElse: () => FuenteApp.predeterminada,
    );
  }
}

/// Idioma de la interfaz. [codigo] es el código ISO 639-1 y [etiqueta]
/// el nombre del idioma escrito en su propio idioma.
enum IdiomaApp {
  es('es', 'Español', '🇨🇴'),
  en('en', 'English', '🇺🇸');

  const IdiomaApp(this.codigo, this.etiqueta, this.bandera);

  final String codigo;
  final String etiqueta;
  final String bandera;

  /// Un valor guardado desconocido o ausente vuelve a español.
  static IdiomaApp desdeCodigo(String? codigo) {
    return IdiomaApp.values.firstWhere(
      (i) => i.codigo == codigo,
      orElse: () => IdiomaApp.es,
    );
  }
}

class PreferenciasService {
  PreferenciasService._();

  static final PreferenciasService instance = PreferenciasService._();

  static const String _claveTamanoTexto = 'preferencia_tamano_texto';
  static const String _claveFuente = 'preferencia_fuente';
  static const String _claveIdioma = 'preferencia_idioma';

  final ValueNotifier<TamanoTexto> tamanoTexto = ValueNotifier<TamanoTexto>(
    TamanoTexto.normal,
  );

  final ValueNotifier<FuenteApp> fuente = ValueNotifier<FuenteApp>(
    FuenteApp.predeterminada,
  );

  final ValueNotifier<IdiomaApp> idioma = ValueNotifier<IdiomaApp>(
    IdiomaApp.es,
  );

  // Se llama una vez en main() antes de runApp().
  Future<void> restaurar() async {
    try {
      final preferencias = await SharedPreferences.getInstance();

      tamanoTexto.value = TamanoTexto.desdeId(
        preferencias.getString(_claveTamanoTexto),
      );

      fuente.value = FuenteApp.desdeId(preferencias.getString(_claveFuente));
      idioma.value = IdiomaApp.desdeCodigo(
        preferencias.getString(_claveIdioma),
      );
    } catch (e) {
      debugPrint('No se pudieron restaurar las preferencias: $e');
    }
  }

  Future<void> cambiarTamanoTexto(TamanoTexto nuevo) async {
    tamanoTexto.value = nuevo;

    try {
      final preferencias = await SharedPreferences.getInstance();

      await preferencias.setString(_claveTamanoTexto, nuevo.id);
    } catch (e) {
      debugPrint('No se pudo guardar la preferencia: $e');
    }
  }

  Future<void> cambiarFuente(FuenteApp nueva) async {
    fuente.value = nueva;

    try {
      final preferencias = await SharedPreferences.getInstance();

      await preferencias.setString(_claveFuente, nueva.id);
    } catch (e) {
      debugPrint('No se pudo guardar la fuente: $e');
    }
  }

  Future<void> cambiarIdioma(IdiomaApp nuevo) async {
    idioma.value = nuevo;

    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(_claveIdioma, nuevo.codigo);
    } catch (e) {
      debugPrint('No se pudo guardar el idioma: $e');
    }
  }
}
