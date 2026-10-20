// Auditoría de SOLO LECTURA de las coordenadas de los sitios turísticos.
//
// No modifica la base de datos. Lista cada sitio con su latitud y
// longitud y marca los que quedan fuera del corredor Garzón–Gigante
// (los que el mapa de la aplicación descarta).
//
// Uso (desde backend/):
//
//   node scripts/auditar_coordenadas_sitios.js
//
// Usa la misma MONGO_URI del archivo .env que el servidor.

require('dotenv').config();

const mongoose = require('mongoose');
const SitioTuristico = require('../models/admin/sitio');

// Mismos límites que lib/config/mapa_corredor.dart
const LIMITES = {
  latitudSur: 1.95,
  latitudNorte: 2.65,
  longitudOeste: -75.9,
  longitudEste: -75.3
};

function dentroDelCorredor(latitud, longitud) {
  return (
    Number.isFinite(latitud) &&
    Number.isFinite(longitud) &&
    latitud >= LIMITES.latitudSur &&
    latitud <= LIMITES.latitudNorte &&
    longitud >= LIMITES.longitudOeste &&
    longitud <= LIMITES.longitudEste
  );
}

function diagnostico(latitud, longitud) {
  if (!Number.isFinite(latitud) || !Number.isFinite(longitud)) {
    return 'SIN COORDENADAS';
  }

  if (latitud === 0 || longitud === 0) {
    return 'COORDENADA EN 0';
  }

  if (dentroDelCorredor(latitud, longitud)) {
    return 'OK';
  }

  if (dentroDelCorredor(longitud, latitud)) {
    return 'FUERA: latitud y longitud están intercambiadas';
  }

  if (dentroDelCorredor(latitud, -longitud)) {
    return 'FUERA: a la longitud le falta el signo negativo';
  }

  if (dentroDelCorredor(-latitud, longitud)) {
    return 'FUERA: la latitud tiene el signo invertido';
  }

  return 'FUERA DEL CORREDOR';
}

(async () => {
  const uri = process.env.MONGO_URI;

  if (!uri) {
    console.error('No se encontró MONGO_URI en el archivo .env.');
    process.exit(1);
  }

  await mongoose.connect(uri);

  const sitios = await SitioTuristico.find({})
    .select('nombre ciudad latitud longitud activo')
    .lean();

  let fuera = 0;

  const porCiudad = {};

  for (const sitio of sitios) {
    const latitud = Number(sitio.latitud);
    const longitud = Number(sitio.longitud);
    const estado = diagnostico(latitud, longitud);

    if (estado !== 'OK') {
      fuera++;
    }

    const ciudad = sitio.ciudad || '(sin ciudad)';
    porCiudad[ciudad] = (porCiudad[ciudad] || 0) + 1;

    console.log(
      `${estado === 'OK' ? 'OK    ' : 'REVISAR'} | ` +
        `${sitio.nombre} | ${ciudad} | ` +
        `${sitio.latitud}, ${sitio.longitud}` +
        `${estado === 'OK' ? '' : ' | ' + estado}` +
        `${sitio.activo === false ? ' | inactivo' : ''}`
    );
  }

  console.log('------------------------------------------');
  console.log(`Sitios: ${sitios.length} | A revisar: ${fuera}`);
  console.log('Por ciudad:', porCiudad);

  await mongoose.disconnect();
})().catch(error => {
  console.error('Error en la auditoría:', error.message);
  process.exit(1);
});
