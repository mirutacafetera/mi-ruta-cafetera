// Pruebas de seguridad de las rutas de usuario / predefinidas.
//
// No usan red ni MongoDB: se sustituyen los modelos con Module._load.
// Ejecutar desde backend/:  node --test tests/rutas_seguridad.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');

const ID_USUARIO = '64b000000000000000000001';
const ID_SITIO = '64b0000000000000000000a1';

let guardadas = [];

class RutaFalsa {
  constructor(datos) {
    Object.assign(this, datos);
  }
  async save() {
    guardadas.push(this);
  }
  async populate() {}
  static async countDocuments() {
    return 0;
  }
}

const SitioFalso = {
  find() {
    return { select: async () => [{ _id: ID_SITIO }] };
  }
};

const cargarOriginal = Module._load;
Module._load = function (request, parent, isMain) {
  if (request.endsWith('models/usuario/ruta')) return RutaFalsa;
  if (request.endsWith('models/admin/sitio')) return SitioFalso;
  if (request.endsWith('models/usuario/usuario')) return {};
  return cargarOriginal.apply(this, arguments);
};

const { crearRuta } = require('../controllers/usuario/rutas.controller');
const { verificarUsuario } = require('../middlewares/authmiddleware');
Module._load = cargarOriginal;

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

function peticion(body, rol = 'usuario') {
  return { body, usuario: { id: ID_USUARIO, rol } };
}

test('un usuario NO puede crear una ruta predefinida', async () => {
  guardadas = [];
  const res = crearRes();
  await crearRuta(
    peticion({ nombre: 'Falsa', sitios: [ID_SITIO], tipo: 'predefinida' }),
    res
  );
  assert.equal(res.codigo, 403);
  assert.equal(guardadas.length, 0);
});

test('crear ruta personalizada sigue funcionando y expira', async () => {
  guardadas = [];
  const res = crearRes();
  await crearRuta(peticion({ nombre: 'Mi ruta', sitios: [ID_SITIO] }), res);
  assert.equal(res.codigo, 201);
  assert.equal(guardadas.length, 1);
  assert.equal(guardadas[0].tipo, 'personalizada');
  assert.equal(guardadas[0].usuario, ID_USUARIO);
  assert.ok(guardadas[0].expiraEn instanceof Date);
});

test('activa debe ser booleano', async () => {
  guardadas = [];
  const res = crearRes();
  await crearRuta(
    peticion({ nombre: 'X', sitios: [ID_SITIO], activa: 'si' }),
    res
  );
  assert.equal(res.codigo, 400);
  assert.equal(guardadas.length, 0);
});

test('verificarUsuario rechaza roles admin y sitio', () => {
  for (const rol of ['admin', 'sitio']) {
    const res = crearRes();
    let siguio = false;
    verificarUsuario({ usuario: { rol } }, res, () => {
      siguio = true;
    });
    assert.equal(res.codigo, 403);
    assert.equal(siguio, false);
  }
});
