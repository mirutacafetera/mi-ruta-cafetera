// Pruebas del limitador de peticiones y del cableado de las rutas de
// ayuda y de recuperación de contraseña del usuario. No usan MongoDB,
// red ni servidor HTTP: express y los controladores se sustituyen por
// simulaciones que solo registran el orden de los middlewares.
//
// Ejecutar desde backend/:  node --test tests/limites_y_rutas.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');

const rutas = [];

function nombreDe(fn) {
  return fn.etiqueta || fn.name || 'anonima';
}

const routerSimulado = {};
for (const metodo of ['get', 'post', 'put', 'delete']) {
  routerSimulado[metodo] = (ruta, ...manejadores) => {
    rutas.push({ metodo, ruta, manejadores });
  };
}

function etiquetada(nombre) {
  const f = (req, res, next) => next && next();
  f.etiqueta = nombre;
  return f;
}

const simulaciones = {
  express: { Router: () => routerSimulado },
  'middlewares/authmiddleware': {
    verificarToken: etiquetada('verificarToken'),
    verificarUsuario: etiquetada('verificarUsuario'),
    verificarAdministrador: etiquetada('verificarAdministrador')
  },
  'controllers/usuario/ayuda.controller': {
    crearReporte: etiquetada('crearReporte'),
    obtenerMisReportes: etiquetada('obtenerMisReportes')
  },
  'controllers/usuario/recuperacion.controller': {
    recuperarPassword: etiquetada('recuperarPassword'),
    verificarCodigoRecuperacion: etiquetada('verificarCodigoRecuperacion'),
    restablecerPassword: etiquetada('restablecerPassword')
  },
  'controllers/usuario/google.controller': {
    loginWithGoogle: etiquetada('loginWithGoogle')
  },
  'controllers/usuario/usuario.controller': new Proxy(
    {},
    { get: (_, nombre) => etiquetada(String(nombre)) }
  )
};

const cargarOriginal = Module._load;
Module._load = function (request, parent, esMain) {
  for (const [clave, valor] of Object.entries(simulaciones)) {
    if (request === clave || request.endsWith('/' + clave)) return valor;
  }
  return cargarOriginal.call(this, request, parent, esMain);
};

const { crearLimitador } = require('../middlewares/ratelimitmiddleware');

require('../routes/usuario/ayuda.routes');
const rutasAyuda = rutas.splice(0);

require('../routes/usuario/usuario.routes');
const rutasUsuario = rutas.splice(0);

function buscar(lista, metodo, ruta) {
  return lista.find((r) => r.metodo === metodo && r.ruta === ruta);
}

// ---------------------------------------------------------------------------
// Cableado de rutas
// ---------------------------------------------------------------------------

test('ayuda: POST y GET exigen token Y cuenta de usuario; POST con límite de envíos', () => {
  const post = buscar(rutasAyuda, 'post', '/').manejadores;
  assert.equal(nombreDe(post[0]), 'verificarToken');
  assert.equal(nombreDe(post[1]), 'verificarUsuario');
  assert.equal(post.length, 4); // token, usuario, limitador, controlador
  assert.equal(nombreDe(post[3]), 'crearReporte');

  const get = buscar(rutasAyuda, 'get', '/').manejadores;
  assert.equal(nombreDe(get[0]), 'verificarToken');
  assert.equal(nombreDe(get[1]), 'verificarUsuario');
  assert.equal(nombreDe(get[2]), 'obtenerMisReportes');
});

test('recuperación: cada ruta pasa por sus limitadores antes del controlador', () => {
  const solicitar = buscar(rutasUsuario, 'post', '/recuperar-password').manejadores;
  assert.equal(solicitar.length, 3);
  assert.equal(nombreDe(solicitar[2]), 'recuperarPassword');

  const verificar = buscar(
    rutasUsuario,
    'post',
    '/verificar-codigo-recuperacion'
  ).manejadores;
  assert.equal(verificar.length, 3);
  assert.equal(nombreDe(verificar[2]), 'verificarCodigoRecuperacion');

  const restablecer = buscar(
    rutasUsuario,
    'post',
    '/restablecer-password'
  ).manejadores;
  assert.equal(restablecer.length, 2);
  assert.equal(nombreDe(restablecer[1]), 'restablecerPassword');
});

test('el resto de rutas de usuario conserva su protección', () => {
  assert.equal(
    nombreDe(buscar(rutasUsuario, 'get', '/perfil').manejadores[0]),
    'verificarToken'
  );
  assert.equal(
    nombreDe(buscar(rutasUsuario, 'put', '/:id').manejadores[0]),
    'verificarToken'
  );
  assert.equal(
    nombreDe(buscar(rutasUsuario, 'delete', '/:id').manejadores[0]),
    'verificarToken'
  );
});

// ---------------------------------------------------------------------------
// Limitador
// ---------------------------------------------------------------------------

function ejecutar(limitador, req) {
  const res = {
    codigo: null,
    cuerpo: null,
    cabeceras: {},
    set(k, v) {
      this.cabeceras[k] = v;
    },
    status(c) {
      this.codigo = c;
      return this;
    },
    json(b) {
      this.cuerpo = b;
      return this;
    }
  };
  let paso = false;
  limitador(req, res, () => {
    paso = true;
  });
  return { paso, res };
}

test('limitador por clave personalizada: bloquea al superar el máximo y avisa cuándo reintentar', () => {
  const limitador = crearLimitador({
    maximo: 3,
    ventanaMs: 60000,
    clave: (req) => `correo:${req.body.correo}`
  });
  const req = { body: { correo: 'a@x.com' }, ip: '1.1.1.1' };
  for (let i = 0; i < 3; i++) assert.equal(ejecutar(limitador, req).paso, true);
  const cuarto = ejecutar(limitador, req);
  assert.equal(cuarto.paso, false);
  assert.equal(cuarto.res.codigo, 429);
  assert.ok(cuarto.res.cabeceras['Retry-After']);
  assert.ok(cuarto.res.cuerpo.mensaje);
});

test('limitador: correos distintos desde la misma IP tienen contadores independientes', () => {
  const limitador = crearLimitador({
    maximo: 1,
    ventanaMs: 60000,
    clave: (req) => `correo:${req.body.correo}`
  });
  assert.equal(
    ejecutar(limitador, { body: { correo: 'a@x.com' }, ip: '1.1.1.1' }).paso,
    true
  );
  assert.equal(
    ejecutar(limitador, { body: { correo: 'b@x.com' }, ip: '1.1.1.1' }).paso,
    true
  );
  assert.equal(
    ejecutar(limitador, { body: { correo: 'a@x.com' }, ip: '2.2.2.2' }).paso,
    false
  );
});

test('limitador sin clave personalizada conserva el comportamiento anterior (usuario o IP)', () => {
  const limitador = crearLimitador({ maximo: 1, ventanaMs: 60000 });
  assert.equal(ejecutar(limitador, { usuario: { id: 'u1' }, ip: '1.1.1.1' }).paso, true);
  assert.equal(ejecutar(limitador, { usuario: { id: 'u1' }, ip: '9.9.9.9' }).paso, false);
  assert.equal(ejecutar(limitador, { usuario: { id: 'u2' }, ip: '1.1.1.1' }).paso, true);
  assert.equal(ejecutar(limitador, { ip: '5.5.5.5' }).paso, true);
  assert.equal(ejecutar(limitador, { ip: '5.5.5.5' }).paso, false);
});

test('una clave que lanza error no rompe el limitador (usa IP)', () => {
  const limitador = crearLimitador({
    maximo: 1,
    ventanaMs: 60000,
    clave: () => {
      throw new Error('x');
    }
  });
  assert.equal(ejecutar(limitador, { ip: '7.7.7.7' }).paso, true);
  assert.equal(ejecutar(limitador, { ip: '7.7.7.7' }).paso, false);
});
