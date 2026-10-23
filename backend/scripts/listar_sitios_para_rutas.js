// Listado de SOLO LECTURA de los sitios turisticos y sus actividades.
//
// No modifica la base de datos y no imprime credenciales. Sirve para
// obtener los identificadores reales (_id) de los sitios que formaran
// parte de las rutas turisticas y para ver que actividades, duraciones
// y horarios tienen registrados.
//
// Uso (desde backend/):
//
//   node scripts/listar_sitios_para_rutas.js
//
// Para guardar el resultado en un archivo:
//
//   node scripts/listar_sitios_para_rutas.js > sitios_rutas.txt
//
// Usa la misma MONGO_URI del archivo .env que el servidor.

require('dotenv').config();

const mongoose = require('mongoose');
const SitioTuristico = require('../models/admin/sitio');
const CategoriaSitio = require('../models/admin/categoria');
const Actividad = require('../models/sitio/actividad');

// Referencia para que Mongoose registre el modelo usado en populate.
void CategoriaSitio;

(async () => {
  const uri = process.env.MONGO_URI;

  if (!uri) {
    console.error('No se encontro MONGO_URI en el archivo .env.');
    process.exit(1);
  }

  await mongoose.connect(uri);

  const sitios = await SitioTuristico.find({})
    .select('nombre ciudad latitud longitud categoria horario activo')
    .populate('categoria', 'nombre')
    .sort({ ciudad: 1, nombre: 1 })
    .lean();

  const actividades = await Actividad.find({})
    .select('sitio nombre duracion horario precio activo estadoPublicacion')
    .lean();

  const actividadesPorSitio = new Map();

  for (const actividad of actividades) {
    const clave = String(actividad.sitio);

    if (!actividadesPorSitio.has(clave)) {
      actividadesPorSitio.set(clave, []);
    }

    actividadesPorSitio.get(clave).push(actividad);
  }

  for (const sitio of sitios) {
    const categoria = sitio.categoria && sitio.categoria.nombre
      ? sitio.categoria.nombre
      : '(sin categoria)';

    console.log(
      `${sitio._id} | ${sitio.nombre} | ${sitio.ciudad || '(sin ciudad)'} | ` +
        `${categoria} | ${sitio.latitud}, ${sitio.longitud}` +
        `${sitio.horario ? ' | horario: ' + sitio.horario : ''}` +
        `${sitio.activo === false ? ' | INACTIVO' : ''}`
    );

    const lista = actividadesPorSitio.get(String(sitio._id)) || [];

    for (const actividad of lista) {
      console.log(
        `      - actividad: ${actividad.nombre}` +
          ` | duracion: ${actividad.duracion || '(sin dato)'}` +
          ` | horario: ${actividad.horario || '(sin dato)'}` +
          ` | precio: ${actividad.precio ?? 0}` +
          ` | ${actividad.estadoPublicacion || '(sin estado)'}` +
          `${actividad.activo === false ? ' | INACTIVA' : ''}`
      );
    }
  }

  console.log('------------------------------------------');
  console.log(`Sitios: ${sitios.length} | Actividades: ${actividades.length}`);

  await mongoose.disconnect();
})().catch(error => {
  console.error('Error al listar los sitios:', error.message);
  process.exit(1);
});
