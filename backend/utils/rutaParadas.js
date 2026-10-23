// ======================================================
// VALIDACIÓN DE PARADAS DE RUTAS PREDEFINIDAS
// ======================================================
//
// Funciones puras + una consulta de sitios inyectable, para poder
// probarlas sin MongoDB.
//
// Límites geográficos: los mismos de lib/config/mapa_corredor.dart
// (corredor Garzón–Gigante).
// ======================================================

const mongoose = require('mongoose');

const LIMITES_CORREDOR = {
  latitudSur: 1.95,
  latitudNorte: 2.65,
  longitudOeste: -75.9,
  longitudEste: -75.3
};

// 9 paradas + el origen del usuario = 10 puntos, el máximo que
// acepta POST /api/rutas/calcular.
const MAX_PARADAS = 9;
const MIN_PARADAS = 2;
const REGEX_HORA = /^([01]\d|2[0-3]):[0-5]\d$/;

const dentroDelCorredor = (latitud, longitud) =>
  typeof latitud === 'number' &&
  typeof longitud === 'number' &&
  Number.isFinite(latitud) &&
  Number.isFinite(longitud) &&
  latitud >= LIMITES_CORREDOR.latitudSur &&
  latitud <= LIMITES_CORREDOR.latitudNorte &&
  longitud >= LIMITES_CORREDOR.longitudOeste &&
  longitud <= LIMITES_CORREDOR.longitudEste;

const aMinutos = (hhmm) => {
  const [h, m] = hhmm.split(':').map(Number);
  return h * 60 + m;
};

// Devuelve { ok:true, paradas, sitios, duracionPlanificadaMin }
// o { ok:false, mensaje }.
// `obtenerSitios(ids)` debe devolver los sitios con
// { _id, nombre, latitud, longitud, activo }.
async function validarParadas(paradas, obtenerSitios) {
  const fallo = (mensaje) => ({ ok: false, mensaje });

  if (!Array.isArray(paradas)) {
    return fallo('El campo paradas debe ser un arreglo.');
  }
  if (paradas.length < MIN_PARADAS || paradas.length > MAX_PARADAS) {
    return fallo(
      `La ruta debe tener entre ${MIN_PARADAS} y ${MAX_PARADAS} paradas.`
    );
  }

  const limpias = [];
  const ordenes = new Set();
  const ids = new Set();

  for (let i = 0; i < paradas.length; i++) {
    const p = paradas[i];
    const n = i + 1;

    if (p === null || typeof p !== 'object' || Array.isArray(p)) {
      return fallo(`La parada ${n} no es válida.`);
    }
    if (!mongoose.Types.ObjectId.isValid(p.sitio)) {
      return fallo(`El sitio de la parada ${n} no es válido.`);
    }
    const idSitio = String(p.sitio);
    if (ids.has(idSitio)) {
      return fallo('La ruta no puede contener sitios repetidos.');
    }
    ids.add(idSitio);

    if (!Number.isInteger(p.orden) || p.orden < 1) {
      return fallo(`El orden de la parada ${n} debe ser un entero positivo.`);
    }
    if (ordenes.has(p.orden)) {
      return fallo('Hay órdenes repetidos en las paradas.');
    }
    ordenes.add(p.orden);

    let duracionMin = null;
    if (p.duracionMin !== undefined && p.duracionMin !== null) {
      if (
        !Number.isInteger(p.duracionMin) ||
        p.duracionMin < 5 ||
        p.duracionMin > 480
      ) {
        return fallo(
          `La duración de la parada ${n} debe ser un entero entre 5 y 480 minutos.`
        );
      }
      duracionMin = p.duracionMin;
    }

    const horas = {};
    for (const campo of ['horaLlegada', 'horaSalida']) {
      const v = p[campo];
      if (v === undefined || v === null || v === '') {
        horas[campo] = null;
      } else if (typeof v !== 'string' || !REGEX_HORA.test(v)) {
        return fallo(`${campo} de la parada ${n} debe tener formato HH:mm.`);
      } else {
        horas[campo] = v;
      }
    }
    if (
      horas.horaLlegada &&
      horas.horaSalida &&
      aMinutos(horas.horaSalida) <= aMinutos(horas.horaLlegada)
    ) {
      return fallo(
        `La hora de salida de la parada ${n} debe ser posterior a la de llegada.`
      );
    }

    for (const campo of ['tipoActividad', 'descripcion', 'indicaciones']) {
      if (p[campo] !== undefined && typeof p[campo] !== 'string') {
        return fallo(`${campo} de la parada ${n} debe ser texto.`);
      }
    }
    if (
      p.requiereReserva !== undefined &&
      typeof p.requiereReserva !== 'boolean'
    ) {
      return fallo(`requiereReserva de la parada ${n} debe ser booleano.`);
    }
    if (
      p.actividad !== undefined &&
      p.actividad !== null &&
      !mongoose.Types.ObjectId.isValid(p.actividad)
    ) {
      return fallo(`La actividad de la parada ${n} no es válida.`);
    }

    limpias.push({
      sitio: idSitio,
      orden: p.orden,
      tipoActividad: (p.tipoActividad || 'visita').trim(),
      descripcion: (p.descripcion || '').trim(),
      duracionMin,
      horaLlegada: horas.horaLlegada,
      horaSalida: horas.horaSalida,
      indicaciones: (p.indicaciones || '').trim(),
      requiereReserva: p.requiereReserva === true,
      actividad: p.actividad || null
    });
  }

  limpias.sort((a, b) => a.orden - b.orden);

  const sitios = await obtenerSitios([...ids]);
  const porId = new Map(sitios.map((s) => [String(s._id), s]));

  for (const parada of limpias) {
    const sitio = porId.get(parada.sitio);
    if (!sitio) {
      return fallo('Uno o más sitios turísticos no existen.');
    }
    if (sitio.activo === false) {
      return fallo(`El sitio "${sitio.nombre}" está desactivado.`);
    }
    if (!dentroDelCorredor(sitio.latitud, sitio.longitud)) {
      return fallo(
        `El sitio "${sitio.nombre}" tiene coordenadas inválidas o fuera del corredor.`
      );
    }
  }

  const todasConDuracion = limpias.every((p) => p.duracionMin !== null);
  const duracionPlanificadaMin = todasConDuracion
    ? limpias.reduce((t, p) => t + p.duracionMin, 0)
    : null;

  return {
    ok: true,
    paradas: limpias,
    sitios: limpias.map((p) => p.sitio),
    duracionPlanificadaMin
  };
}

module.exports = {
  LIMITES_CORREDOR,
  MAX_PARADAS,
  MIN_PARADAS,
  dentroDelCorredor,
  validarParadas
};
