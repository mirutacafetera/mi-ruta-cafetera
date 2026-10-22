import 'package:flutter/widgets.dart';

import '../services/usuario/preferencias_service.dart';
import 'textos_en.dart';

// ============================================================
// TEXTOS TRADUCIBLES (ES / EN)
// ============================================================
//
// Sistema mínimo y progresivo, sin dependencias nuevas.
//
// Dos formas de clave (conviven):
//
// 1) Clave corta (perfil.*, pref.*): su texto vive en [_es] y [_en]
//    de este archivo.            context.t('perfil.titulo')
// 2) El propio texto en español como clave: se escribe tal cual en la
//    pantalla y su inglés vive en textos_en.dart.
//                                Tr('Iniciar sesión')
//                                Textos.t('Hola, {0}', [nombre])
//
// Dónde usar cada helper:
//   * Tr('texto')            -> reemplaza a Text('texto') (acepta
//                               style, textAlign, maxLines, overflow,
//                               softWrap, args). Sigue siendo const.
//   * Textos.t('texto', [..])-> mensajes, validaciones, tooltips,
//                               hintText/labelText, SnackBars…
//   * context.t('clave')     -> igual que Textos.t, pero suscrito al
//                               idioma del árbol de widgets.
//
// {0}, {1}… se sustituyen por los valores de la lista, en orden.
//
// * Si no hay traducción al inglés, se muestra el español.
// * Si la clave corta no existe en ninguno, se muestra la propia clave
//   (así un olvido se nota en pantalla y en las pruebas).
// * No hay condiciones por idioma dentro de las pantallas.
//
// El idioma elegido vive en PreferenciasService.idioma. Al cambiarlo,
// main.dart llama a [Textos.reconstruirArbol] para repintar todo lo
// que está en pantalla (y en las pantallas ya abiertas), sin cerrar
// sesión ni reiniciar.
//
// Solo se traduce texto fijo de la interfaz. El contenido que
// llega de MongoDB (nombres, descripciones, etc.) no se traduce.
// ============================================================

class Textos {
  Textos._();

  /// Texto traducido a [idioma]. [args] sustituye {0}, {1}…
  static String de(
    IdiomaApp idioma,
    String clave, [
    List<Object?> args = const [],
  ]) {
    final traducido =
        idioma == IdiomaApp.en ? (_en[clave] ?? textosEnLiteral[clave]) : null;

    var texto = traducido ?? _es[clave] ?? clave;

    for (var i = 0; i < args.length; i++) {
      texto = texto.replaceAll('{$i}', '${args[i]}');
    }

    return texto;
  }

  /// Traducción fuera de un widget (sin BuildContext): mensajes,
  /// validaciones, textos que construyen servicios o controladores.
  static String t(String clave, [List<Object?> args = const []]) {
    return de(PreferenciasService.instance.idioma.value, clave, args);
  }

  /// Fuerza el repintado de todo el árbol de widgets. Se usa al cambiar
  /// el idioma para que también se actualicen las pantallas que ya
  /// estaban abiertas debajo de Preferencias. No reinicia estados.
  static void reconstruirArbol() {
    final raiz = WidgetsBinding.instance.rootElement;

    if (raiz == null) {
      return;
    }

    void marcar(Element elemento) {
      elemento.markNeedsBuild();
      elemento.visitChildren(marcar);
    }

    raiz.visitChildren(marcar);
  }

  /// Claves registradas en cada idioma (para las pruebas).
  static Set<String> get clavesEs => _es.keys.toSet();
  static Set<String> get clavesEn => _en.keys.toSet();

  static const Map<String, String> _es = {
    // ---- Preferencias ----
    'pref.titulo': 'Preferencias',
    'pref.idioma': 'Idioma',
    'pref.idioma.desc': 'Elige el idioma de la aplicación. '
        'Se aplica al instante.',
    'pref.idioma.nota': 'Se traducen las pantallas de la aplicación. '
        'Los paneles de administración y de sitio, y el contenido de '
        'los sitios (nombres y descripciones), siguen en español.',
    'pref.tamano': 'Tamaño del texto',
    'pref.tamano.desc': 'Elige qué tan grande quieres leer la aplicación.',
    'pref.tamano.pequeno': 'Pequeño',
    'pref.tamano.normal': 'Normal',
    'pref.tamano.grande': 'Grande',
    'pref.fuente': 'Tipo de letra',
    'pref.fuente.desc': 'Cambia la letra de toda la aplicación.',
    'pref.fuente.predeterminada': 'Predeterminada',
    'pref.fuente.lora': 'Lora (con serifa)',
    'pref.fuente.poppins': 'Poppins (moderna)',
    'pref.fuente.nunito': 'Nunito (redondeada)',
    'pref.vista': 'Así se verá',
    'pref.vista.texto': 'Descubre fincas, miradores y sabores del '
        'Huila a tu propio ritmo.',

    // ---- Mi perfil (visitante) ----
    'perfil.titulo': 'Mi perfil',
    'perfil.pub.cabecera': 'Tu perfil de viajero',
    'perfil.pub.cabecera.desc': 'Inicia sesión para disfrutar '
        'una experiencia personalizada.',
    'perfil.pub.acceso': 'Accede a tu cuenta',
    'perfil.pub.acceso.desc': 'Guarda tus experiencias y disfruta '
        'tu recorrido por el Huila.',
    'perfil.pub.entrar': 'Iniciar sesión',
    'perfil.pub.crear': 'Crear una cuenta',
    'perfil.pub.explora': 'Explora lugares, descubre nuevas '
        'experiencias y construye tu propia '
        'ruta por el Huila.',

    // ---- Mi perfil (con sesión) ----
    'perfil.viajero': 'Viajero',
    'perfil.favoritos': 'Favoritos',
    'perfil.rutasCreadas': 'Rutas creadas',
    'perfil.miCuenta': 'Mi cuenta',
    'perfil.misFavoritos': 'Mis favoritos',
    'perfil.misFavoritos.desc': 'Los lugares que guardaste.',
    'perfil.misRutas': 'Mis rutas',
    'perfil.misRutas.desc': 'Tus recorridos por el Huila.',
    'perfil.misReservas': 'Mis reservas',
    'perfil.misReservas.desc': 'Tus solicitudes y su estado.',
    'perfil.editar': 'Editar perfil',
    'perfil.editar.desc': 'Nombre, teléfono y ciudad.',
    'perfil.avatar': 'Mi avatar cafetero',
    'perfil.avatar.desc': 'Crea y personaliza tu avatar.',
    'perfil.aplicacion': 'Aplicación',
    'perfil.preferencias.desc': 'Idioma, tamaño del texto y tipo de letra.',
    'perfil.cerrarSesion': 'Cerrar sesión',
    'perfil.cerrarSesion.pregunta': '¿Deseas cerrar tu sesión?',
    'comun.cancelar': 'Cancelar',
    'perfil.eliminarCuenta': 'Eliminar mi cuenta',
  };

  static const Map<String, String> _en = {
    // ---- Preferences ----
    'pref.titulo': 'Preferences',
    'pref.idioma': 'Language',
    'pref.idioma.desc': 'Choose the app language. '
        'It applies instantly.',
    'pref.idioma.nota': 'The app screens are translated. The '
        'administration and site panels, and site content (names and '
        'descriptions), remain in Spanish.',
    'pref.tamano': 'Text size',
    'pref.tamano.desc': 'Choose how large you want to read the app.',
    'pref.tamano.pequeno': 'Small',
    'pref.tamano.normal': 'Normal',
    'pref.tamano.grande': 'Large',
    'pref.fuente': 'Font',
    'pref.fuente.desc': 'Change the font of the whole app.',
    'pref.fuente.predeterminada': 'Default',
    'pref.fuente.lora': 'Lora (serif)',
    'pref.fuente.poppins': 'Poppins (modern)',
    'pref.fuente.nunito': 'Nunito (rounded)',
    'pref.vista': 'Preview',
    'pref.vista.texto': 'Discover farms, viewpoints and flavors of '
        'Huila at your own pace.',

    // ---- My profile (visitor) ----
    'perfil.titulo': 'My profile',
    'perfil.pub.cabecera': 'Your traveler profile',
    'perfil.pub.cabecera.desc': 'Sign in to enjoy '
        'a personalized experience.',
    'perfil.pub.acceso': 'Access your account',
    'perfil.pub.acceso.desc': 'Save your experiences and enjoy '
        'your journey through Huila.',
    'perfil.pub.entrar': 'Sign in',
    'perfil.pub.crear': 'Create an account',
    'perfil.pub.explora': 'Explore places, discover new '
        'experiences and build your own '
        'route through Huila.',

    // ---- My profile (signed in) ----
    'perfil.viajero': 'Traveler',
    'perfil.favoritos': 'Favorites',
    'perfil.rutasCreadas': 'Routes created',
    'perfil.miCuenta': 'My account',
    'perfil.misFavoritos': 'My favorites',
    'perfil.misFavoritos.desc': 'The places you saved.',
    'perfil.misRutas': 'My routes',
    'perfil.misRutas.desc': 'Your trips through Huila.',
    'perfil.misReservas': 'My reservations',
    'perfil.misReservas.desc': 'Your requests and their status.',
    'perfil.editar': 'Edit profile',
    'perfil.editar.desc': 'Name, phone and city.',
    'perfil.avatar': 'My coffee avatar',
    'perfil.avatar.desc': 'Create and customize your avatar.',
    'perfil.aplicacion': 'App',
    'perfil.preferencias.desc': 'Language, text size and font.',
    'perfil.cerrarSesion': 'Sign out',
    'perfil.cerrarSesion.pregunta': 'Do you want to sign out?',
    'comun.cancelar': 'Cancel',
    'perfil.eliminarCuenta': 'Delete my account',
  };
}

/// Publica el idioma actual al árbol de widgets. Lo coloca main.dart
/// dentro del builder del MaterialApp, por lo que cubre también
/// diálogos y pantallas abiertas con Navigator.
class IdiomaScope extends InheritedWidget {
  const IdiomaScope({
    super.key,
    required this.idioma,
    required super.child,
  });

  final IdiomaApp idioma;

  static IdiomaApp of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<IdiomaScope>()
            ?.idioma ??
        PreferenciasService.instance.idioma.value;
  }

  @override
  bool updateShouldNotify(IdiomaScope oldWidget) {
    return oldWidget.idioma != idioma;
  }
}

extension TextosContexto on BuildContext {
  /// Texto traducido; se reconstruye solo al cambiar el idioma.
  String t(String clave, [List<Object?> args = const []]) =>
      Textos.de(IdiomaScope.of(this), clave, args);
}

/// Sustituye a Text cuando el texto es fijo de la interfaz.
///
///   Tr('Iniciar sesión')
///   Tr('Hola, {0}', args: [nombre], style: ...)
///
/// Acepta los mismos parámetros habituales de Text y mantiene el
/// constructor const, por lo que puede reemplazar a `const Text(...)`.
/// Si el texto llega de MongoDB no debe pasar por aquí.
class Tr extends StatelessWidget {
  const Tr(
    this.clave, {
    super.key,
    this.args = const [],
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String clave;
  final List<Object?> args;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      Textos.de(IdiomaScope.of(context), clave, args),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
