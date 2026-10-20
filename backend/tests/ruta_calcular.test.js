// Pruebas de POST /api/rutas/calcular (controlador calcularRuta).
//
// No usan red ni MongoDB: se sustituye https.get por un OSRM simulado.
// Ejecutar desde backend/:  node --test tests/ruta_calcular.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const https = require('https');
const { EventEmitter } = require('events');

const { calcularRuta } = require('../controllers/ruta/ruta.controller');

function crearRes() {
  return {
    codigo: null,
    cuerpo: null,
    status(c) {
      this.codigo = c;
      return this;
    },
    json(b) {
      this.cuerpo = b;
      return this;
    }
  };
}

function osrmSimulado(respuesta, { statusCode = 200, error, timeout } = {}) {
  const original = https.get;
  https.get = (url, opciones, callback) => {
    const request = new EventEmitter();
    request.destroy = () => {};
    request.setTimeout = (ms, cb) => {
      if (timeout) setImmediate(cb);
    };
    request.url = url;
    https.ultimaUrl = url;
    setImmediate(() => {
      if (error) return request.emit('error', error);
      if (timeout) return;
      const response = new EventEmitter();
      response.statusCode = statusCode;
      callback(response);
      response.emit('data', typeof respuesta === 'string' ? respuesta : JSON.stringify(respuesta));
      response.emit('end');
    });
    return request;
  };
  return () => {
    https.get = original;
  };
}

const PUNTOS = [
  { latitud: 2.2, longitud: -75.62 },
  { latitud: 2.196, longitud: -75.6277 },
  { latitud: 2.3866, longitud: -75.5459 }
];

const OSRM_OK = {
  code: 'Ok',
  routes: [
    {
      distance: 30000,
      duration: 2400,
      geometry: {
        type: 'LineString',
        coordinates: [
          [-75.62, 2.2],
          [-75.6, 2.25],
          [-75.5459, 2.3866]
        ]
      },
      legs: [
        { distance: 1000, duration: 120, steps: [] },
        { distance: 29000, duration: 2280, steps: [] }
      ]
    }
  ],
  waypoints: [{ name: 'a', location: [-75.62, 2.2] }]
};

test('devuelve geometría de carretera, totales y un tramo por cada par de puntos', async () => {
  const restaurar = osrmSimulado(OSRM_OK);
  const res = crearRes();
  await calcularRuta({ body: { puntos: PUNTOS } }, res);
  restaurar();

  assert.equal(res.codigo, 200);
  assert.equal(res.cuerpo.ok, true);
  assert.equal(res.cuerpo.ruta.distancia, 30000);
  assert.equal(res.cuerpo.ruta.duracion, 2400);
  assert.equal(res.cuerpo.ruta.geometria.coordinates.length, 3);
  assert.equal(res.cuerpo.ruta.tramos.length, PUNTOS.length - 1);
  assert.deepEqual(res.cuerpo.ruta.tramos[0], { distancia: 1000, duracion: 120 });
});

test('OSRM recibe longitud,latitud en el orden recibido', async () => {
  const restaurar = osrmSimulado(OSRM_OK);
  const res = crearRes();
  await calcularRuta({ body: { puntos: PUNTOS } }, res);
  const url = https.ultimaUrl;
  restaurar();
  assert.match(
    url,
    /driving\/-75\.62,2\.2;-75\.6277,2\.196;-75\.5459,2\.3866\?overview=full&geometries=geojson/
  );
});

test('coordenadas inválidas responden 400 (no 500)', async () => {
  for (const puntos of [
    [{ latitud: 'abc', longitud: -75 }, PUNTOS[1]],
    [{ latitud: 2.2 }, PUNTOS[1]],
    [null, PUNTOS[1]],
    [{ latitud: 95, longitud: -75 }, PUNTOS[1]],
    [{ latitud: 2, longitud: -200 }, PUNTOS[1]],
    [{ latitud: null, longitud: null }, PUNTOS[1]]
  ]) {
    const res = crearRes();
    await calcularRuta({ body: { puntos } }, res);
    assert.equal(res.codigo, 400, JSON.stringify(puntos));
    assert.equal(res.cuerpo.ok, false);
  }
});

test('menos de 2 puntos, más de 10 y cuerpo ausente responden 400', async () => {
  for (const body of [
    { puntos: [PUNTOS[0]] },
    { puntos: Array(11).fill(PUNTOS[0]) },
    { puntos: 'no' },
    undefined
  ]) {
    const res = crearRes();
    await calcularRuta({ body }, res);
    assert.equal(res.codigo, 400);
  }
});

test('OSRM sin ruta o con error de código responde 502 y no simula éxito', async () => {
  let restaurar = osrmSimulado({ code: 'NoRoute', message: 'sin ruta' });
  let res = crearRes();
  await calcularRuta({ body: { puntos: PUNTOS } }, res);
  restaurar();
  assert.equal(res.codigo, 502);
  assert.equal(res.cuerpo.ok, false);

  restaurar = osrmSimulado({ code: 'Ok', routes: [] });
  res = crearRes();
  await calcularRuta({ body: { puntos: PUNTOS } }, res);
  restaurar();
  assert.equal(res.codigo, 502);

  restaurar = osrmSimulado({
    code: 'Ok',
    routes: [{ distance: 1, duration: 1, geometry: { coordinates: [] }, legs: [] }]
  });
  res = crearRes();
  await calcularRuta({ body: { puntos: PUNTOS } }, res);
  restaurar();
  assert.equal(res.codigo, 502);
});

test('OSRM caído (HTTP 500 / JSON inválido / error de red) responde 502', async () => {
  for (const opciones of [
    [{ code: 'x' }, { statusCode: 500 }],
    ['<html>no json</html>', {}],
    [{}, { error: new Error('ECONNREFUSED') }]
  ]) {
    const restaurar = osrmSimulado(opciones[0], opciones[1]);
    const res = crearRes();
    await calcularRuta({ body: { puntos: PUNTOS } }, res);
    restaurar();
    assert.equal(res.codigo, 502);
    assert.equal(res.cuerpo.ok, false);
  }
});

test('timeout de OSRM responde 504', async () => {
  const restaurar = osrmSimulado(null, { timeout: true });
  const res = crearRes();
  await calcularRuta({ body: { puntos: PUNTOS } }, res);
  restaurar();
  assert.equal(res.codigo, 504);
});
