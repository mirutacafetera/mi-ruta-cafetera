import 'package:latlong2/latlong.dart';

/// Área turística de trabajo de Mi Ruta Cafetera: el corredor
/// Garzón – Gigante (Huila, Colombia).
///
/// Es la ÚNICA fuente de las coordenadas por defecto del mapa, de
/// los límites de la cámara y de la validación de coordenadas.
///
/// Referencias (centros urbanos, coordenadas públicas):
///   Garzón  ≈ 2.1960, -75.6277
///   Gigante ≈ 2.3866, -75.5459
///
/// Si se necesita ampliar el área (por ejemplo, para probar la
/// aplicación desde otra ciudad), basta con cambiar los límites
/// de este archivo o poner [restringirCamara] en false.
class MapaCorredor {
  MapaCorredor._();

  // ============================================================
  // REFERENCIAS
  // ============================================================

  static const LatLng garzon = LatLng(2.1960, -75.6277);

  static const LatLng gigante = LatLng(2.3866, -75.5459);

  /// Punto medio entre Garzón y Gigante.
  static const LatLng centro = LatLng(2.2913, -75.5868);

  // ============================================================
  // ZOOM
  // ============================================================

  static const double zoomInicial = 10.5;

  static const double zoomMinimo = 9.5;

  static const double zoomMaximo = 18;

  // ============================================================
  // VISTA DEL CORREDOR (botón "ver corredor")
  // ============================================================
  //
  // Rectángulo que encuadra Garzón y Gigante con margen.
  // ============================================================

  static const LatLng vistaSuroeste = LatLng(2.12, -75.70);

  static const LatLng vistaNoreste = LatLng(2.46, -75.47);

  // ============================================================
  // LÍMITES DE LA CÁMARA Y DE LAS COORDENADAS
  // ============================================================
  //
  // Corredor más un margen aproximado de 15 km. Evita que el
  // usuario salga accidentalmente del área turística y permite
  // descartar coordenadas erróneas (0,0, signos invertidos,
  // latitud/longitud intercambiadas, etc.).
  // ============================================================

  static const double latitudSur = 1.95;

  static const double latitudNorte = 2.65;

  static const double longitudOeste = -75.90;

  static const double longitudEste = -75.30;

  static const LatLng limiteSuroeste = LatLng(latitudSur, longitudOeste);

  static const LatLng limiteNoreste = LatLng(latitudNorte, longitudEste);

  /// Si es false, la cámara del mapa no se restringe al corredor.
  static const bool restringirCamara = true;

  // ============================================================
  // VALIDACIÓN
  // ============================================================

  /// Indica si la coordenada es válida y está dentro del área
  /// turística de trabajo.
  static bool contiene(double latitud, double longitud) {
    if (!latitud.isFinite || !longitud.isFinite) {
      return false;
    }

    return latitud >= latitudSur &&
        latitud <= latitudNorte &&
        longitud >= longitudOeste &&
        longitud <= longitudEste;
  }

  static bool contienePunto(LatLng punto) {
    return contiene(punto.latitude, punto.longitude);
  }

  /// Distancia aproximada, en kilómetros, entre un punto y el
  /// centro del corredor.
  static double distanciaAlCentroKm(LatLng punto) {
    return const Distance().as(
      LengthUnit.Kilometer,
      centro,
      punto,
    );
  }
}
