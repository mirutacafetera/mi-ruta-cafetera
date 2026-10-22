// Carga las 3 rutas turísticas predefinidas en MongoDB.
//
// POR DEFECTO ES SOLO LECTURA (simulacro): valida y muestra lo que
// insertaría, sin escribir nada.
//
//   node scripts/cargar_rutas_predefinidas.js            (simulacro)
//   node scripts/cargar_rutas_predefinidas.js --aplicar  (inserta)
//
// Solo INSERTA rutas que no existan (mismo nombre y tipo
// predefinida). Nunca modifica ni elimina documentos existentes.
// Usa la misma MONGO_URI del archivo .env que el servidor.

require('dotenv').config();

const mongoose = require('mongoose');
const Ruta = require('../models/usuario/ruta');
const SitioTuristico = require('../models/admin/sitio');
const { validarParadas } = require('../utils/rutaParadas');
const { RUTAS_PREDEFINIDAS } = require('../data/rutasPredefinidas');

const aplicar = process.argv.includes('--aplicar');

const obtenerSitios = (ids) =>
  SitioTuristico.find({ _id: { $in: ids } })
    .select('_id nombre latitud longitud activo')
    .lean();

async function main() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log(aplicar ? 'MODO: APLICAR (inserta)' : 'MODO: SIMULACRO (no escribe)');

  let errores = 0;

  for (const def of RUTAS_PREDEFINIDAS) {
    console.log('\n== ' + def.nombre);

    const validacion = await validarParadas(def.paradas, obtenerSitios);
    if (!validacion.ok) {
      errores++;
      console.log('   NO VÁLIDA: ' + validacion.mensaje);
      continue;
    }

    const sitios = await obtenerSitios(validacion.sitios);
    const nombres = new Map(sitios.map((s) => [String(s._id), s.nombre]));
    validacion.paradas.forEach((p) => {
      console.log(
        `   ${p.orden}. ${nombres.get(p.sitio)} | ${p.tipoActividad} | ${p.duracionMin} min`
      );
    });
    console.log(`   Actividad planificada: ${validacion.duracionPlanificadaMin} min`);

    const existente = await Ruta.findOne({
      tipo: 'predefinida',
      nombre: def.nombre
    }).select('_id');
    if (existente) {
      console.log('   YA EXISTE: se omite (no se modifica).');
      continue;
    }

    if (!aplicar) {
      console.log('   (simulacro) se insertaría.');
      continue;
    }

    await Ruta.create({
      usuario: null,
      nombre: def.nombre,
      descripcion: def.descripcion,
      tipoExperiencia: def.tipoExperiencia,
      paradas: validacion.paradas,
      sitios: validacion.sitios,
      duracionPlanificadaMin: validacion.duracionPlanificadaMin,
      tipo: 'predefinida',
      activa: true,
      expiraEn: null
    });
    console.log('   INSERTADA.');
  }

  console.log('\n------------------------------------------');
  console.log(errores ? `Rutas con errores: ${errores}` : 'Todas las rutas son válidas.');
  await mongoose.disconnect();
  process.exitCode = errores ? 1 : 0;
}

main().catch(async (error) => {
  console.error('Error:', error.message);
  try {
    await mongoose.disconnect();
  } catch (_) {}
  process.exitCode = 1;
});
