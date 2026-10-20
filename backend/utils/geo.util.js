// ======================================================
// UTILIDADES GEOGRÁFICAS
// ======================================================
//
// La distancia calculada aquí es en LÍNEA RECTA (fórmula de
// Haversine). No es la distancia por carretera ni un tiempo de
// viaje; quien la muestre debe indicarlo así.
// ======================================================

const RADIO_TIERRA_KM = 6371;

const aRadianes = (grados) => (grados * Math.PI) / 180;

const esCoordenadaValida = (lat, lng) =>
  typeof lat === 'number' &&
  typeof lng === 'number' &&
  Number.isFinite(lat) &&
  Number.isFinite(lng) &&
  lat >= -90 &&
  lat <= 90 &&
  lng >= -180 &&
  lng <= 180;

const distanciaLineaRectaKm = (lat1, lng1, lat2, lng2) => {
  const dLat = aRadianes(lat2 - lat1);
  const dLng = aRadianes(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(aRadianes(lat1)) *
      Math.cos(aRadianes(lat2)) *
      Math.sin(dLng / 2) ** 2;

  return 2 * RADIO_TIERRA_KM * Math.asin(Math.sqrt(a));
};

module.exports = {
  esCoordenadaValida,
  distanciaLineaRectaKm
};
