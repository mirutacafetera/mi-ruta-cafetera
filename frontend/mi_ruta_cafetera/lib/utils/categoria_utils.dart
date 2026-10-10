import 'text_utils.dart';

class CategoriaUtils {
  CategoriaUtils._();

  static String imagen(String? nombre) {
    final categoria =
        TextUtils.normalizar(
      nombre ?? '',
    );

    if (categoria.contains('cafe')) {
      return 'assets/images/sitios/cafe.jpeg';
    }

    if (categoria.contains('artesania')) {
      return 'assets/images/sitios/artesanias.jpg';
    }

    if (categoria.contains('gastronom')) {
      return 'assets/images/sitios/gastronomia.jpeg';
    }

    if (categoria.contains('alojamiento') ||
        categoria.contains('hotel') ||
        categoria.contains('hospedaje')) {
      return 'assets/images/sitios/alojamiento.jpg';
    }

    if (categoria.contains('famil')) {
      return 'assets/images/sitios/familiares.jpeg';
    }

    if (categoria.contains('naturaleza') ||
        categoria.contains('ecoturismo') ||
        categoria.contains('senderismo')) {
      return 'assets/images/sitios/naturaleza.jpeg';
    }

    if (categoria.contains('cultura') ||
        categoria.contains('historia') ||
        categoria.contains('patrimonio')) {
      return 'assets/images/sitios/cultura.jpg';
    }

    if (categoria.contains('aventura')) {
      return 'assets/images/sitios/aventuras.jpeg';
    }

    if (categoria.contains('mirador') ||
        categoria.contains('paisaje')) {
      return 'assets/images/sitios/miradores.jpeg';
    }

    return 'assets/images/bienvenida/paisaje.jpg';
  }
}