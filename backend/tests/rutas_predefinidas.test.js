// Pruebas de validación y administración de rutas predefinidas.
// Sin red ni MongoDB. Ejecutar desde backend/:
//   node --test tests/rutas_predefinidas.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');

const guardadas = [];

class RutaFalsa {
  constructor(datos) {
    Object.assign(this, datos);
  }
  async save() {
    guardadas.push(this);
  }
  async populate() {}
  static findOne() {
    return { select: async () => RutaFalsa.existente || null };
  }
}

let sitiosBD = [];
const SitioFalso = {
  find() {
    return {
      select() {
        return { lean: async () => sitiosBD };
      }
    };
  }
};

const cargarOriginal = Module._load;
Module._load = function (request) {
  if (request.endsWith('models/usuario/ruta')) return RutaFalsa;
  if (request.endsWith('models/admin/sitio')) return SitioFalso;
  return cargarOriginal.apply(this, arguments);
};
const { validarParadas } = require('../utils/rutaParadas');
const { crearPredefinida } = require('../controllers/admin/rutaPredefinida.controller');
const { RUTAS_PREDEFINIDAS } = require('../data/rutasPredefinidas');
Module._load = cargarOriginal;

const A = '64b0000000000000000000a1';
const B = '64b0000000000000000000a2';

function res() {
  return {
    codigo: null,
    cuerpo: null,
    status(c) { this.codigo = c; return this; },
    json(b) { this.cuerpo = b; return this; }
  };
}

const obtener = async () => sitiosBD;

function poner(...sitios) {
  sitiosBD = sitios;
}
const sitio = (id, extra = {}) => ({
  _id: id, nombre: 'S' + id.slice(-1), latitud: 2.2, longitud: -75.6, activo: true, ...extra
});

test('paradas válidas: ordena, suma duración y sincroniza sitios', async () => {
  poner(sitio(A), sitio(B));
  const r = await validarParadas(
    [
      { sitio: B, orden: 2, duracionMin: 30 },
      { sitio: A, orden: 1, duracionMin: 60 }
    ],
    obtener
  );
  assert.equal(r.ok, true);
  assert.deepEqual(r.sitios, [A, B]);
  assert.equal(r.duracionPlanificadaMin, 90);
});

test('rechaza menos de 2 y más de 9 paradas', async () => {
  poner(sitio(A));
  assert.equal((await validarParadas([{ sitio: A, orden: 1 }], obtener)).ok, false);
  const muchas = Array.from({ length: 10 }, (_, i) => ({ sitio: A, orden: i + 1 }));
  assert.equal((await validarParadas(muchas, obtener)).ok, false);
});

test('rechaza sitios u órdenes repetidos y sitio inválido', async () => {
  poner(sitio(A), sitio(B));
  assert.equal((await validarParadas([{ sitio: A, orden: 1 }, { sitio: A, orden: 2 }], obtener)).ok, false);
  assert.equal((await validarParadas([{ sitio: A, orden: 1 }, { sitio: B, orden: 1 }], obtener)).ok, false);
  assert.equal((await validarParadas([{ sitio: 'x', orden: 1 }, { sitio: B, orden: 2 }], obtener)).ok, false);
});

test('rechaza horas mal formadas, salida anterior a llegada y duración inválida', async () => {
  poner(sitio(A), sitio(B));
  const base = { sitio: B, orden: 2 };
  assert.equal((await validarParadas([{ sitio: A, orden: 1, horaLlegada: '25:00' }, base], obtener)).ok, false);
  assert.equal((await validarParadas([{ sitio: A, orden: 1, horaLlegada: '10:00', horaSalida: '09:00' }, base], obtener)).ok, false);
  assert.equal((await validarParadas([{ sitio: A, orden: 1, duracionMin: 2 }, base], obtener)).ok, false);
});

test('rechaza sitio inexistente, desactivado o fuera del corredor', async () => {
  const p = [{ sitio: A, orden: 1 }, { sitio: B, orden: 2 }];
  poner(sitio(A));
  assert.equal((await validarParadas(p, obtener)).ok, false);
  poner(sitio(A), sitio(B, { activo: false }));
  assert.equal((await validarParadas(p, obtener)).ok, false);
  poner(sitio(A), sitio(B, { latitud: 12345, longitud: -2365 }));
  assert.equal((await validarParadas(p, obtener)).ok, false);
});

test('crearPredefinida guarda una ruta permanente sin usuario', async () => {
  guardadas.length = 0;
  poner(sitio(A), sitio(B));
  const r = res();
  await crearPredefinida(
    { body: { nombre: ' Ruta X ', paradas: [{ sitio: A, orden: 1, duracionMin: 30 }, { sitio: B, orden: 2, duracionMin: 30 }] } },
    r
  );
  assert.equal(r.codigo, 201);
  assert.equal(guardadas[0].tipo, 'predefinida');
  assert.equal(guardadas[0].usuario, null);
  assert.equal(guardadas[0].expiraEn, null);
  assert.equal(guardadas[0].nombre, 'Ruta X');
});

test('crearPredefinida rechaza nombre duplicado (409) y datos inválidos (400)', async () => {
  poner(sitio(A), sitio(B));
  const body = { nombre: 'Dup', paradas: [{ sitio: A, orden: 1 }, { sitio: B, orden: 2 }] };
  RutaFalsa.existente = { _id: 'x' };
  let r = res();
  await crearPredefinida({ body }, r);
  assert.equal(r.codigo, 409);
  RutaFalsa.existente = null;
  r = res();
  await crearPredefinida({ body: { paradas: body.paradas } }, r);
  assert.equal(r.codigo, 400);
});

test('las 3 rutas definidas son consistentes', () => {
  assert.equal(RUTAS_PREDEFINIDAS.length, 3);
  for (const ruta of RUTAS_PREDEFINIDAS) {
    const ids = ruta.paradas.map((p) => p.sitio);
    assert.equal(new Set(ids).size, ids.length, ruta.nombre);
    assert.ok(ids.every((id) => /^[0-9a-f]{24}$/.test(id)), ruta.nombre);
    const ordenes = ruta.paradas.map((p) => p.orden);
    assert.deepEqual(ordenes, ordenes.map((_, i) => i + 1));
    const total = ruta.paradas.reduce((t, p) => t + p.duracionMin, 0);
    assert.ok(total <= 480, `${ruta.nombre}: ${total} min de actividad`);
  }
});

test('el router de administración exige administrador', () => {
  const src = require('fs').readFileSync(
    require('path').join(__dirname, '../routes/admin/rutasPredefinidas.routes.js'),
    'utf8'
  );
  assert.match(src, /router\.use\(verificarToken, verificarAdministrador\)/);
});
