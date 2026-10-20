// Pruebas del módulo de reservas (usuario, establecimiento, administrador),
// de las notificaciones y de los permisos. NO usan MongoDB ni red: los
// modelos, JWT y Express se sustituyen por simulaciones en memoria, así que
// no tocan datos reales.
//
// Ejecutar desde backend/:  node --test tests/reservas.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');

// ---------------------------------------------------------------------------
// Datos y utilidades de simulación
// ---------------------------------------------------------------------------

const idDe = (letra) => letra.repeat(24);

const USUARIO_A = idDe('a');
const USUARIO_B = idDe('b');
const SITIO_1 = idDe('1');
const SITIO_2 = idDe('2');
const ACTIVIDAD_1 = idDe('c'); // sitio 1, precio 50000
const ACTIVIDAD_2 = idDe('d'); // sitio 2
const ACTIVIDAD_BORRADOR = idDe('e');
const ACTIVIDAD_INACTIVA = idDe('f');
const SITIO_CERRADO = idDe('9');
const ACTIVIDAD_SITIO_CERRADO = idDe('8');

let contador = 0;
const nuevoId = () => {
  contador += 1;
  return contador.toString(16).padStart(24, '0');
};

let bd; // se reinicia en cada prueba

function reiniciar() {
  contador = 0;
  bd = {
    reservas: [],
    notificaciones: [],
    fallaNotificacion: false,
    fallaGuardarReserva: false,
    actividades: {
      [ACTIVIDAD_1]: {
        _id: ACTIVIDAD_1,
        sitio: SITIO_1,
        nombre: 'Tour del café',
        precio: 50000,
        activo: true,
        estadoPublicacion: 'aprobado'
      },
      [ACTIVIDAD_2]: {
        _id: ACTIVIDAD_2,
        sitio: SITIO_2,
        nombre: 'Cabalgata',
        precio: 30000,
        activo: true,
        estadoPublicacion: 'aprobado'
      },
      [ACTIVIDAD_BORRADOR]: {
        _id: ACTIVIDAD_BORRADOR,
        sitio: SITIO_1,
        nombre: 'Sin aprobar',
        precio: 1,
        activo: true,
        estadoPublicacion: 'borrador'
      },
      [ACTIVIDAD_INACTIVA]: {
        _id: ACTIVIDAD_INACTIVA,
        sitio: SITIO_1,
        nombre: 'Desactivada',
        precio: 1,
        activo: false,
        estadoPublicacion: 'aprobado'
      },
      [ACTIVIDAD_SITIO_CERRADO]: {
        _id: ACTIVIDAD_SITIO_CERRADO,
        sitio: SITIO_CERRADO,
        nombre: 'En sitio cerrado',
        precio: 1,
        activo: true,
        estadoPublicacion: 'aprobado'
      }
    },
    sitios: {
      [SITIO_1]: { _id: SITIO_1, nombre: 'Finca La Esperanza', activo: true },
      [SITIO_2]: { _id: SITIO_2, nombre: 'Hacienda Dos', activo: true },
      [SITIO_CERRADO]: { _id: SITIO_CERRADO, nombre: 'Cerrado', activo: false }
    },
    usuarios: {
      [USUARIO_A]: {
        _id: USUARIO_A,
        nombre: 'Ana',
        apellido: 'Pérez',
        correo: 'ana@correo.com',
        telefono: '3001112233'
      },
      [USUARIO_B]: {
        _id: USUARIO_B,
        nombre: 'Beto',
        apellido: 'Gómez',
        correo: 'beto@correo.com',
        telefono: '3009998877'
      }
    }
  };
}

// --- consultas encadenables (populate / sort / select / lean / limit) -------

function coincide(doc, filtro) {
  return Object.entries(filtro).every(([clave, esperado]) => {
    const real = doc[clave];

    if (esperado && typeof esperado === 'object' && !(esperado instanceof Date)) {
      if (Array.isArray(esperado.$in)) {
        return esperado.$in.map(String).includes(String(real));
      }

      if (esperado.$gte || esperado.$lte) {
        const t = new Date(real).getTime();
        if (esperado.$gte && t < esperado.$gte.getTime()) return false;
        if (esperado.$lte && t > esperado.$lte.getTime()) return false;
        return true;
      }
    }

    return String(real) === String(esperado);
  });
}

function consulta(calcular) {
  const populate = [];
  let orden = null;
  let limite = null;

  const q = {
    populate(ruta) {
      populate.push(ruta);
      return q;
    },
    sort(o) {
      orden = o;
      return q;
    },
    select() {
      return q;
    },
    lean() {
      return q;
    },
    limit(n) {
      limite = n;
      return q;
    },
    then(ok, fallo) {
      return Promise.resolve()
        .then(() => {
          let resultado = calcular();

          if (Array.isArray(resultado)) {
            resultado = resultado.map((d) => poblar(d, populate));

            if (orden) {
              const [campo, sentido] = Object.entries(orden)[0];
              resultado = [...resultado].sort((a, b) => {
                const x = new Date(a[campo]).getTime();
                const y = new Date(b[campo]).getTime();
                return sentido >= 0 ? x - y : y - x;
              });
            }

            if (limite) resultado = resultado.slice(0, limite);
          } else if (resultado) {
            resultado = poblar(resultado, populate);
          }

          return resultado;
        })
        .then(ok, fallo);
    }
  };

  return q;
}

function poblar(doc, rutas) {
  if (!doc || !rutas.length) return doc;

  const copia = Object.assign(Object.create(Object.getPrototypeOf(doc)), doc);

  if (rutas.includes('usuario') && bd.usuarios[String(doc.usuario)]) {
    copia.usuario = bd.usuarios[String(doc.usuario)];
  }

  if (rutas.includes('sitio') && bd.sitios[String(doc.sitio)]) {
    copia.sitio = bd.sitios[String(doc.sitio)];
  }

  if (rutas.includes('actividad') && bd.actividades[String(doc.actividad)]) {
    copia.actividad = bd.actividades[String(doc.actividad)];
  }

  return copia;
}

// --- modelos simulados ------------------------------------------------------

class Reserva {
  constructor(datos) {
    Object.assign(this, {
      estado: 'pendiente',
      observaciones: '',
      respuestaSitio: '',
      respondidaAt: null,
      precioUnitario: 0,
      ...datos
    });
    this._id = nuevoId();
    this.createdAt = new Date(Date.now() + contador);
  }

  async save() {
    if (bd.fallaGuardarReserva) throw new Error('fallo simulado al guardar');

    if (
      this.claveSolicitud &&
      bd.reservas.some(
        (r) =>
          String(r.usuario) === String(this.usuario) &&
          r.claveSolicitud === this.claveSolicitud
      )
    ) {
      const error = new Error('duplicado');
      error.code = 11000;
      throw error;
    }

    bd.reservas.push(this);
  }

  static find(filtro) {
    return consulta(() => bd.reservas.filter((r) => coincide(r, filtro)));
  }

  static findOne(filtro) {
    return consulta(() => bd.reservas.find((r) => coincide(r, filtro)) || null);
  }

  static findOneAndUpdate(filtro, cambios) {
    return consulta(() => {
      const doc = bd.reservas.find((r) => coincide(r, filtro));
      if (!doc) return null;
      Object.assign(doc, cambios);
      return doc;
    });
  }

  static findById(id) {
    return consulta(() => bd.reservas.find((r) => String(r._id) === String(id)) || null);
  }

  static findByIdAndUpdate(id, cambios) {
    return consulta(() => {
      const doc = bd.reservas.find((r) => String(r._id) === String(id));
      if (!doc) return null;
      Object.assign(doc, cambios);
      return doc;
    });
  }
}

class Notificacion {
  constructor(datos) {
    Object.assign(this, { leida: false, activo: true, ...datos });
    this._id = nuevoId();
    this.createdAt = new Date(Date.now() + contador);
  }

  async save() {
    if (bd.fallaNotificacion) throw new Error('fallo simulado en notificación');
    bd.notificaciones.push(this);
  }

  static find(filtro) {
    return consulta(() => bd.notificaciones.filter((n) => coincide(n, filtro)));
  }

  static findOneAndUpdate(filtro, cambios) {
    return consulta(() => {
      const doc = bd.notificaciones.find((n) => coincide(n, filtro));
      if (!doc) return null;
      Object.assign(doc, cambios);
      return doc;
    });
  }
}

const Actividad = {
  findById: (id) => consulta(() => bd.actividades[String(id)] || null)
};

const SitioTuristico = {
  findById: (id) => consulta(() => bd.sitios[String(id)] || null)
};

const UsuarioModelo = {
  findById: (id) =>
    consulta(() =>
      bd.usuarios[String(id)] ? { _id: id, eliminadoAt: null } : null
    )
};

// --- Express simulado: solo registra rutas y manejadores -------------------

const routers = [];

const expressSimulado = {
  Router() {
    const router = { rutas: [], usos: [] };

    for (const metodo of ['get', 'post', 'put', 'patch', 'delete']) {
      router[metodo] = (ruta, ...manejadores) => {
        router.rutas.push({ metodo, ruta, manejadores });
      };
    }

    router.use = (...manejadores) => {
      router.usos.push(manejadores);
    };

    routers.push(router);
    return router;
  }
};

const jwtSimulado = {
  verify: (token) => {
    const tokens = {
      'tok-ana': { id: USUARIO_A, correo: 'ana@correo.com', rol: 'usuario' },
      'tok-beto': { id: USUARIO_B, correo: 'beto@correo.com', rol: 'usuario' },
      'tok-sitio1': { id: 'cuenta1', sitioId: SITIO_1, rol: 'sitio' },
      'tok-sitio2': { id: 'cuenta2', sitioId: SITIO_2, rol: 'sitio' },
      'tok-admin': { id: 'adm', rol: 'admin' }
    };

    if (!tokens[token]) {
      const e = new Error('inválido');
      e.name = 'JsonWebTokenError';
      throw e;
    }

    return tokens[token];
  }
};

const simulaciones = {
  'models/sitio/reserva': Reserva,
  'models/sitio/actividad': Actividad,
  'models/admin/sitio': SitioTuristico,
  'models/usuario/notificacion': Notificacion,
  'models/usuario/usuario': UsuarioModelo,
  jsonwebtoken: jwtSimulado,
  express: expressSimulado
};

const cargarOriginal = Module._load;

Module._load = function (request, parent, esMain) {
  for (const [clave, valor] of Object.entries(simulaciones)) {
    if (request === clave || request.endsWith('/' + clave)) {
      return valor;
    }
  }

  return cargarOriginal.call(this, request, parent, esMain);
};

process.env.JWT_SECRET = 'secreto-de-prueba';

// Los silencios evitan ruido de console.error en los casos de error esperados.
const errorOriginal = console.error;
console.error = () => {};
process.on('exit', () => {
  console.error = errorOriginal;
});

const auth = require('../middlewares/authmiddleware');
const ctrlUsuario = require('../controllers/usuario/reservas.controller');
const ctrlSitio = require('../controllers/sitio/reservas.controller');
const ctrlAdmin = require('../controllers/admin/reservas.controller');
const ctrlNotificaciones = require('../controllers/usuario/notificaciones.controller');

const rutasUsuario = require('../routes/usuario/reserva.routes');
const rutasSitio = require('../routes/sitios/reservas.routes');
const rutasAdmin = require('../routes/admin/reservas.routes');
const rutasNotificaciones = require('../routes/usuario/notificacion.routes');

// ---------------------------------------------------------------------------
// Ayudas de prueba
// ---------------------------------------------------------------------------

function respuesta() {
  return {
    codigo: 200,
    cuerpo: undefined,
    status(c) {
      this.codigo = c;
      return this;
    },
    json(c) {
      this.cuerpo = c;
      return this;
    }
  };
}

const usuarioDe = (id) => ({ id, rol: 'usuario' });
const sitioDe = (sitioId) => ({ id: 'cuenta', sitioId, rol: 'sitio' });

const enDias = (n) => new Date(Date.now() + n * 86400000).toISOString();

async function crear(usuarioId, body, headers = {}) {
  const res = respuesta();
  await ctrlUsuario.crearReserva(
    { usuario: usuarioDe(usuarioId), body, headers },
    res
  );
  return res;
}

const cuerpoValido = (extra = {}) => ({
  actividad: ACTIVIDAD_1,
  fecha: enDias(3),
  cantidadPersonas: 2,
  observaciones: 'Vamos con niños',
  ...extra
});

async function cambiarEstado(sitioId, reservaId, body, idSitioRuta = sitioId) {
  const res = respuesta();
  await ctrlSitio.actualizarEstadoReserva(
    {
      usuario: sitioDe(sitioId),
      params: { id: idSitioRuta, reservaId },
      body
    },
    res
  );
  return res;
}

async function pasarPorMiddleware(manejadores, req) {
  const res = respuesta();
  const salida = { siguio: false, res };

  for (const manejador of manejadores) {
    let avanzo = false;
    await manejador(req, res, () => {
      avanzo = true;
    });

    if (!avanzo) return salida;
  }

  salida.siguio = true;
  return salida;
}

const buscarRuta = (router, metodo, ruta) =>
  router.rutas.find((r) => r.metodo === metodo && r.ruta === ruta);

// ===========================================================================
// 1. CREAR SOLICITUD
// ===========================================================================

test('usuario autenticado crea una solicitud válida', async () => {
  reiniciar();

  const res = await crear(USUARIO_A, cuerpoValido({
    // Intentos de manipulación: deben ignorarse.
    usuario: USUARIO_B,
    precioTotal: 1,
    estado: 'confirmada'
  }));

  assert.equal(res.codigo, 201);
  assert.equal(bd.reservas.length, 1);

  const r = bd.reservas[0];
  assert.equal(String(r.usuario), USUARIO_A, 'el usuario sale del token');
  assert.equal(String(r.sitio), SITIO_1, 'el sitio sale de la actividad');
  assert.equal(String(r.actividad), ACTIVIDAD_1);
  assert.equal(r.estado, 'pendiente');
  assert.equal(r.precioUnitario, 50000);
  assert.equal(r.precioTotal, 100000, 'el precio lo calcula el servidor');
  assert.equal(r.actividadNombre, 'Tour del café');
  assert.equal(r.cantidadPersonas, 2);
});

test('el establecimiento correcto recibe una notificación persistente', async () => {
  reiniciar();

  const res = await crear(USUARIO_A, cuerpoValido());
  assert.equal(res.codigo, 201);

  const paraSitio = bd.notificaciones.filter((n) => n.sitio);
  assert.equal(paraSitio.length, 1);
  assert.equal(String(paraSitio[0].sitio), SITIO_1);
  assert.equal(paraSitio[0].tipo, 'reserva_nueva');
  assert.equal(String(paraSitio[0].reserva), String(bd.reservas[0]._id));
  assert.equal(paraSitio[0].leida, false);

  const texto = `${paraSitio[0].titulo} ${paraSitio[0].mensaje}`;
  assert.ok(!texto.includes('Ana'), 'no expone el nombre');
  assert.ok(!texto.includes('ana@correo.com'), 'no expone el correo');
  assert.ok(!texto.includes('3001112233'), 'no expone el teléfono');

  assert.equal(
    bd.notificaciones.filter((n) => String(n.sitio) === SITIO_2).length,
    0,
    'no se notifica a otros establecimientos'
  );
});

test('la notificación sigue disponible al volver a consultar (persistencia)', async () => {
  reiniciar();
  await crear(USUARIO_A, cuerpoValido());

  // "Cerrar y abrir la aplicación" = una consulta nueva a la base de datos.
  const res = respuesta();
  await ctrlSitio.obtenerNotificacionesSitio(
    { usuario: sitioDe(SITIO_1) },
    res
  );

  assert.equal(res.codigo, 200);
  assert.equal(res.cuerpo.length, 1);
  assert.equal(res.cuerpo[0].tipo, 'reserva_nueva');
});

test('sin autenticación no se puede crear una solicitud', async () => {
  reiniciar();

  const ruta = buscarRuta(rutasUsuario, 'post', '/');
  const salida = await pasarPorMiddleware(ruta.manejadores, {
    headers: {},
    body: cuerpoValido()
  });

  assert.equal(salida.siguio, false);
  assert.equal(salida.res.codigo, 401);
  assert.equal(bd.reservas.length, 0);
});

test('faltan campos obligatorios o son inválidos: 400 y no se guarda nada', async () => {
  reiniciar();

  const casos = [
    ['sin actividad', cuerpoValido({ actividad: undefined })],
    ['actividad con formato inválido', cuerpoValido({ actividad: 'abc' })],
    ['sin fecha', cuerpoValido({ fecha: undefined })],
    ['fecha inválida', cuerpoValido({ fecha: 'mañana' })],
    ['fecha pasada', cuerpoValido({ fecha: enDias(-10) })],
    ['fecha lejanísima', cuerpoValido({ fecha: enDias(2000) })],
    ['sin cantidad', cuerpoValido({ cantidadPersonas: undefined })],
    ['cantidad cero', cuerpoValido({ cantidadPersonas: 0 })],
    ['cantidad decimal', cuerpoValido({ cantidadPersonas: 1.5 })],
    ['cantidad negativa', cuerpoValido({ cantidadPersonas: -2 })],
    ['cantidad excesiva', cuerpoValido({ cantidadPersonas: 51 })],
    ['cantidad no numérica', cuerpoValido({ cantidadPersonas: 'abc' })],
    ['observaciones demasiado largas', cuerpoValido({ observaciones: 'x'.repeat(501) })],
    ['observaciones no textuales', cuerpoValido({ observaciones: { a: 1 } })],
    ['sitio con formato inválido', cuerpoValido({ sitio: '123' })]
  ];

  for (const [nombre, body] of casos) {
    const res = await crear(USUARIO_A, body);
    assert.equal(res.codigo, 400, nombre);
    assert.ok(res.cuerpo.mensaje, nombre);
  }

  const vacio = respuesta();
  await ctrlUsuario.crearReserva(
    { usuario: usuarioDe(USUARIO_A), body: undefined, headers: {} },
    vacio
  );
  assert.equal(vacio.codigo, 400);

  assert.equal(bd.reservas.length, 0);
  assert.equal(bd.notificaciones.length, 0);
});

test('actividad inexistente, sin aprobar o desactivada: 404', async () => {
  reiniciar();

  for (const actividad of [idDe('7'), ACTIVIDAD_BORRADOR, ACTIVIDAD_INACTIVA]) {
    const res = await crear(USUARIO_A, cuerpoValido({ actividad }));
    assert.equal(res.codigo, 404, actividad);
  }

  assert.equal(bd.reservas.length, 0);
});

test('la actividad no pertenece al sitio indicado: 400', async () => {
  reiniciar();

  const res = await crear(
    USUARIO_A,
    cuerpoValido({ actividad: ACTIVIDAD_2, sitio: SITIO_1 })
  );

  assert.equal(res.codigo, 400);
  assert.match(res.cuerpo.mensaje, /no pertenece al sitio/);
  assert.equal(bd.reservas.length, 0);
});

test('si el sitio indicado coincide con la actividad se acepta', async () => {
  reiniciar();

  const res = await crear(
    USUARIO_A,
    cuerpoValido({ actividad: ACTIVIDAD_2, sitio: SITIO_2 })
  );

  assert.equal(res.codigo, 201);
  assert.equal(String(bd.reservas[0].sitio), SITIO_2);
});

test('sitio desactivado: 404', async () => {
  reiniciar();

  const res = await crear(
    USUARIO_A,
    cuerpoValido({ actividad: ACTIVIDAD_SITIO_CERRADO })
  );

  assert.equal(res.codigo, 404);
  assert.equal(bd.reservas.length, 0);
});

test('si falla la notificación la solicitud NO se pierde y no se duplica', async () => {
  reiniciar();
  bd.fallaNotificacion = true;

  const res = await crear(USUARIO_A, cuerpoValido());

  assert.equal(res.codigo, 201);
  assert.equal(bd.reservas.length, 1);
  assert.equal(bd.notificaciones.length, 0);

  // El establecimiento la ve igualmente en su lista de reservas.
  const lista = respuesta();
  await ctrlSitio.obtenerReservas(
    { usuario: sitioDe(SITIO_1), params: { id: SITIO_1 } },
    lista
  );
  assert.equal(lista.cuerpo.length, 1);
});

test('reenviar con la misma clave no crea una segunda solicitud', async () => {
  reiniciar();

  const primera = await crear(
    USUARIO_A,
    cuerpoValido({ claveSolicitud: 'clave-unica-1' })
  );
  const segunda = await crear(
    USUARIO_A,
    cuerpoValido({ claveSolicitud: 'clave-unica-1' })
  );

  assert.equal(primera.codigo, 201);
  assert.equal(segunda.codigo, 200);
  assert.equal(segunda.cuerpo.duplicada, true);
  assert.equal(bd.reservas.length, 1);
  assert.equal(
    bd.notificaciones.filter((n) => n.sitio).length,
    1,
    'no se vuelve a avisar al establecimiento'
  );
});

test('la clave también puede ir en la cabecera Idempotency-Key', async () => {
  reiniciar();

  const h = { 'idempotency-key': 'cabecera-1' };
  await crear(USUARIO_A, cuerpoValido(), h);
  const segunda = await crear(USUARIO_A, cuerpoValido(), h);

  assert.equal(segunda.cuerpo.duplicada, true);
  assert.equal(bd.reservas.length, 1);
});

test('dos envíos simultáneos con la misma clave resultan en una sola reserva', async () => {
  reiniciar();

  const [uno, dos] = await Promise.all([
    crear(USUARIO_A, cuerpoValido({ claveSolicitud: 'carrera-1' })),
    crear(USUARIO_A, cuerpoValido({ claveSolicitud: 'carrera-1' }))
  ]);

  assert.equal(bd.reservas.length, 1);
  assert.deepEqual([uno.codigo, dos.codigo].sort(), [200, 201]);
});

test('una segunda solicitud pendiente igual (sin clave) responde 409', async () => {
  reiniciar();

  const fecha = enDias(4);
  const primera = await crear(USUARIO_A, cuerpoValido({ fecha }));
  const segunda = await crear(USUARIO_A, cuerpoValido({ fecha }));

  assert.equal(primera.codigo, 201);
  assert.equal(segunda.codigo, 409);
  assert.equal(bd.reservas.length, 1);

  // Otro usuario sí puede pedir la misma actividad y fecha.
  const otro = await crear(USUARIO_B, cuerpoValido({ fecha }));
  assert.equal(otro.codigo, 201);
});

test('un error interno no filtra detalles al cliente', async () => {
  reiniciar();
  bd.fallaGuardarReserva = true;

  const res = await crear(USUARIO_A, cuerpoValido());

  assert.equal(res.codigo, 500);
  assert.ok(!JSON.stringify(res.cuerpo).includes('fallo simulado'));
});

// ===========================================================================
// 2. ROLES Y RUTAS
// ===========================================================================

test('/api/reservas rechaza tokens de sitio y de administrador', async () => {
  reiniciar();

  const ruta = buscarRuta(rutasUsuario, 'post', '/');

  for (const token of ['tok-sitio1', 'tok-admin']) {
    const salida = await pasarPorMiddleware(ruta.manejadores, {
      headers: { authorization: `Bearer ${token}` },
      body: cuerpoValido()
    });

    assert.equal(salida.siguio, false, token);
    assert.equal(salida.res.codigo, 403, token);
  }

  const bien = await pasarPorMiddleware(ruta.manejadores.slice(0, 2), {
    headers: { authorization: 'Bearer tok-ana' },
    body: cuerpoValido()
  });
  assert.equal(bien.siguio, true);
});

test('todas las rutas de usuario exigen sesión de usuario', () => {
  for (const r of rutasUsuario.rutas) {
    assert.ok(r.manejadores.includes(auth.verificarToken), `${r.metodo} ${r.ruta}`);
    assert.ok(r.manejadores.includes(auth.verificarUsuario), `${r.metodo} ${r.ruta}`);
  }
});

test('las rutas de administrador exigen el rol de administrador', async () => {
  reiniciar();

  for (const r of rutasAdmin.rutas) {
    assert.ok(r.manejadores.includes(auth.verificarToken), `${r.metodo} ${r.ruta}`);
    assert.ok(r.manejadores.includes(auth.verificarAdministrador), `${r.metodo} ${r.ruta}`);
  }

  // Un usuario común con sesión válida ya no puede listar todas las reservas.
  const ruta = buscarRuta(rutasAdmin, 'get', '/');
  const salida = await pasarPorMiddleware(ruta.manejadores, {
    headers: { authorization: 'Bearer tok-ana' }
  });

  assert.equal(salida.siguio, false);
  assert.equal(salida.res.codigo, 403);

  const admin = await pasarPorMiddleware(ruta.manejadores.slice(0, 2), {
    headers: { authorization: 'Bearer tok-admin' }
  });
  assert.equal(admin.siguio, true);
});

test('las rutas de sitio exigen cuenta de sitio y las notificaciones van antes que /:id', async () => {
  reiniciar();

  for (const r of rutasSitio.rutas) {
    assert.ok(r.manejadores.includes(auth.verificarToken), `${r.metodo} ${r.ruta}`);
    assert.ok(r.manejadores.includes(auth.verificarSitio), `${r.metodo} ${r.ruta}`);
  }

  const orden = rutasSitio.rutas.map((r) => r.ruta);
  assert.ok(orden.indexOf('/notificaciones') < orden.indexOf('/:id'));
  assert.ok(orden.indexOf('/notificaciones/:id/leida') < orden.indexOf('/:id/:reservaId'));

  // Un usuario no puede entrar a las rutas del sitio.
  const ruta = buscarRuta(rutasSitio, 'get', '/:id');
  const salida = await pasarPorMiddleware(ruta.manejadores, {
    headers: { authorization: 'Bearer tok-ana' },
    params: { id: SITIO_1 }
  });

  assert.equal(salida.siguio, false);
  assert.equal(salida.res.codigo, 403);
});

test('las notificaciones del usuario ya no son públicas', async () => {
  reiniciar();

  assert.equal(rutasNotificaciones.usos.length, 1);
  assert.ok(rutasNotificaciones.usos[0].includes(auth.verificarToken));
  assert.ok(rutasNotificaciones.usos[0].includes(auth.verificarUsuario));

  const sinToken = await pasarPorMiddleware(rutasNotificaciones.usos[0], {
    headers: {}
  });
  assert.equal(sinToken.siguio, false);
  assert.equal(sinToken.res.codigo, 401);
});

// ===========================================================================
// 3. PROPIEDAD DE LAS RESERVAS (USUARIO)
// ===========================================================================

test('un usuario solo ve sus propias reservas', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  await crear(USUARIO_B, cuerpoValido({ fecha: enDias(5) }));

  const res = respuesta();
  await ctrlUsuario.obtenerReservas({ usuario: usuarioDe(USUARIO_A) }, res);

  assert.equal(res.codigo, 200);
  assert.equal(res.cuerpo.length, 1);
  assert.equal(String(res.cuerpo[0].usuario), USUARIO_A);
});

test('un usuario no puede cancelar ni modificar la reserva de otro', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);

  const cancelar = respuesta();
  await ctrlUsuario.cancelarReserva(
    { usuario: usuarioDe(USUARIO_B), params: { id } },
    cancelar
  );
  assert.equal(cancelar.codigo, 404);

  const actualizar = respuesta();
  await ctrlUsuario.actualizarReserva(
    { usuario: usuarioDe(USUARIO_B), params: { id }, body: { cantidadPersonas: 5 } },
    actualizar
  );
  assert.equal(actualizar.codigo, 404);

  assert.equal(bd.reservas[0].estado, 'pendiente');
  assert.equal(bd.reservas[0].cantidadPersonas, 2);
});

test('el usuario cancela su reserva pendiente y se avisa al establecimiento', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);

  const res = respuesta();
  await ctrlUsuario.cancelarReserva(
    { usuario: usuarioDe(USUARIO_A), params: { id } },
    res
  );

  assert.equal(res.codigo, 200);
  assert.equal(bd.reservas[0].estado, 'cancelada');
  assert.ok(
    bd.notificaciones.some(
      (n) => String(n.sitio) === SITIO_1 && n.tipo === 'reserva_cancelada'
    )
  );
});

test('no se puede cancelar una reserva completada, rechazada o ya cancelada', async () => {
  reiniciar();

  for (const estado of ['completada', 'rechazada', 'cancelada']) {
    const r = new Reserva({
      usuario: USUARIO_A,
      sitio: SITIO_1,
      actividad: ACTIVIDAD_1,
      fecha: new Date(),
      cantidadPersonas: 1,
      precioTotal: 1,
      estado
    });
    await r.save();

    const res = respuesta();
    await ctrlUsuario.cancelarReserva(
      { usuario: usuarioDe(USUARIO_A), params: { id: String(r._id) } },
      res
    );

    assert.equal(res.codigo, 409, estado);
    assert.equal(r.estado, estado, estado);
  }
});

test('el usuario solo puede modificar fecha, cantidad y observaciones de una pendiente', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const reserva = bd.reservas[0];
  const id = String(reserva._id);

  const res = respuesta();
  await ctrlUsuario.actualizarReserva(
    {
      usuario: usuarioDe(USUARIO_A),
      params: { id },
      body: {
        cantidadPersonas: 4,
        actividad: ACTIVIDAD_2,
        sitio: SITIO_2,
        precioTotal: 1,
        estado: 'confirmada'
      }
    },
    res
  );

  assert.equal(res.codigo, 200);
  assert.equal(reserva.cantidadPersonas, 4);
  assert.equal(reserva.precioTotal, 200000, 'recalculado con el precio guardado');
  assert.equal(String(reserva.actividad), ACTIVIDAD_1, 'la actividad no cambia');
  assert.equal(String(reserva.sitio), SITIO_1, 'el sitio no cambia');
  assert.equal(reserva.estado, 'pendiente', 'el estado no lo cambia el usuario');

  // Ya confirmada: no se puede modificar.
  reserva.estado = 'confirmada';
  const tarde = respuesta();
  await ctrlUsuario.actualizarReserva(
    { usuario: usuarioDe(USUARIO_A), params: { id }, body: { cantidadPersonas: 9 } },
    tarde
  );
  assert.equal(tarde.codigo, 409);
  assert.equal(reserva.cantidadPersonas, 4);
});

test('actualizar sin cambios o con datos inválidos responde 400', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);

  for (const body of [{}, { cantidadPersonas: 0 }, { fecha: 'x' }, { observaciones: 5 }]) {
    const res = respuesta();
    await ctrlUsuario.actualizarReserva(
      { usuario: usuarioDe(USUARIO_A), params: { id }, body },
      res
    );
    assert.equal(res.codigo, 400, JSON.stringify(body));
  }
});

// ===========================================================================
// 4. ESTABLECIMIENTO
// ===========================================================================

test('el establecimiento solo consulta las reservas de su propio sitio', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  await crear(USUARIO_A, cuerpoValido({ actividad: ACTIVIDAD_2, fecha: enDias(6) }));

  const propias = respuesta();
  await ctrlSitio.obtenerReservas(
    { usuario: sitioDe(SITIO_1), params: { id: SITIO_1 } },
    propias
  );
  assert.equal(propias.codigo, 200);
  assert.equal(propias.cuerpo.length, 1);
  assert.equal(String(propias.cuerpo[0].sitio._id), SITIO_1);
  assert.equal(propias.cuerpo[0].usuario.correo, 'ana@correo.com', 'contacto para coordinar el pago');

  // Pedir las de otro sitio: 403.
  const ajenas = respuesta();
  await ctrlSitio.obtenerReservas(
    { usuario: sitioDe(SITIO_1), params: { id: SITIO_2 } },
    ajenas
  );
  assert.equal(ajenas.codigo, 403);
});

test('el establecimiento no puede ver ni cambiar una reserva de otro sitio', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido({ actividad: ACTIVIDAD_2 }));
  const idDeOtroSitio = String(bd.reservas[0]._id); // pertenece al sitio 2

  const ver = respuesta();
  await ctrlSitio.obtenerReserva(
    {
      usuario: sitioDe(SITIO_1),
      params: { id: SITIO_1, reservaId: idDeOtroSitio }
    },
    ver
  );
  assert.equal(ver.codigo, 404);

  // Con su propio id de sitio: no la encuentra.
  const propio = await cambiarEstado(SITIO_1, idDeOtroSitio, { estado: 'confirmada' });
  assert.equal(propio.codigo, 404);

  // Usando el id del otro sitio en la URL: 403.
  const ajeno = await cambiarEstado(SITIO_1, idDeOtroSitio, { estado: 'confirmada' }, SITIO_2);
  assert.equal(ajeno.codigo, 403);

  assert.equal(bd.reservas[0].estado, 'pendiente');
});

test('el establecimiento autorizado confirma una solicitud pendiente', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);

  const res = await cambiarEstado(SITIO_1, id, {
    estado: 'confirmada',
    motivo: 'Te escribiremos por WhatsApp para el pago'
  });

  assert.equal(res.codigo, 200);
  assert.equal(bd.reservas[0].estado, 'confirmada');
  assert.ok(bd.reservas[0].respondidaAt instanceof Date);
  assert.equal(bd.reservas[0].respuestaSitio, 'Te escribiremos por WhatsApp para el pago');

  const aviso = bd.notificaciones.find(
    (n) => String(n.usuario) === USUARIO_A && n.tipo === 'reserva_confirmada'
  );
  assert.ok(aviso, 'el usuario recibe una notificación persistente');
  assert.match(aviso.mensaje, /Finca La Esperanza/);
  assert.match(aviso.mensaje, /coordinar el pago/);
  assert.match(aviso.mensaje, /WhatsApp/);
});

test('el establecimiento rechaza con motivo; sin motivo responde 400', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);

  const sinMotivo = await cambiarEstado(SITIO_1, id, { estado: 'rechazada' });
  assert.equal(sinMotivo.codigo, 400);
  assert.equal(bd.reservas[0].estado, 'pendiente');

  const corto = await cambiarEstado(SITIO_1, id, { estado: 'rechazada', motivo: 'no' });
  assert.equal(corto.codigo, 400);

  const res = await cambiarEstado(SITIO_1, id, {
    estado: 'rechazada',
    motivo: 'Ese día no hay cupo'
  });

  assert.equal(res.codigo, 200);
  assert.equal(bd.reservas[0].estado, 'rechazada');
  assert.equal(bd.reservas[0].respuestaSitio, 'Ese día no hay cupo');

  const aviso = bd.notificaciones.find(
    (n) => String(n.usuario) === USUARIO_A && n.tipo === 'reserva_rechazada'
  );
  assert.ok(aviso);
  assert.match(aviso.mensaje, /Ese día no hay cupo/);
});

test('el usuario ve el estado actualizado en sus reservas', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);
  await cambiarEstado(SITIO_1, id, { estado: 'confirmada' });

  const res = respuesta();
  await ctrlUsuario.obtenerReservas({ usuario: usuarioDe(USUARIO_A) }, res);

  assert.equal(res.cuerpo[0].estado, 'confirmada');
});

test('transiciones de estado inválidas responden 409 y valores desconocidos 400', async () => {
  reiniciar();

  const hacer = async (estadoInicial) => {
    const r = new Reserva({
      usuario: USUARIO_A,
      sitio: SITIO_1,
      actividad: ACTIVIDAD_1,
      fecha: new Date(),
      cantidadPersonas: 1,
      precioTotal: 1,
      estado: estadoInicial
    });
    await r.save();
    return r;
  };

  const casos = [
    ['completada', 'confirmada'],
    ['rechazada', 'confirmada'],
    ['cancelada', 'confirmada'],
    ['pendiente', 'completada'],
    ['confirmada', 'rechazada']
  ];

  for (const [desde, hacia] of casos) {
    const r = await hacer(desde);
    const res = await cambiarEstado(SITIO_1, String(r._id), {
      estado: hacia,
      motivo: 'motivo de prueba'
    });

    assert.equal(res.codigo, 409, `${desde} -> ${hacia}`);
    assert.equal(r.estado, desde, `${desde} -> ${hacia}`);
  }

  const r = await hacer('pendiente');

  for (const estado of ['pendiente', 'borrada', undefined, 7, null]) {
    const res = await cambiarEstado(SITIO_1, String(r._id), { estado });
    assert.equal(res.codigo, 400, String(estado));
  }

  const sinCuerpo = respuesta();
  await ctrlSitio.actualizarEstadoReserva(
    {
      usuario: sitioDe(SITIO_1),
      params: { id: SITIO_1, reservaId: String(r._id) },
      body: undefined
    },
    sinCuerpo
  );
  assert.equal(sinCuerpo.codigo, 400);
});

test('la transición pendiente -> cancelada se conserva por compatibilidad', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const res = await cambiarEstado(SITIO_1, String(bd.reservas[0]._id), {
    estado: 'cancelada'
  });

  assert.equal(res.codigo, 200);
  assert.equal(bd.reservas[0].estado, 'cancelada');
});

test('una confirmada se marca completada', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);
  await cambiarEstado(SITIO_1, id, { estado: 'confirmada' });
  const res = await cambiarEstado(SITIO_1, id, { estado: 'completada' });

  assert.equal(res.codigo, 200);
  assert.equal(bd.reservas[0].estado, 'completada');
});

test('si falla el aviso al usuario el cambio de estado igual queda guardado', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  bd.fallaNotificacion = true;

  const res = await cambiarEstado(SITIO_1, String(bd.reservas[0]._id), {
    estado: 'confirmada'
  });

  assert.equal(res.codigo, 200);
  assert.equal(bd.reservas[0].estado, 'confirmada');
});

test('un identificador de reserva con formato inválido responde 404 sin consultar', async () => {
  reiniciar();

  const res = await cambiarEstado(SITIO_1, 'no-es-un-id', { estado: 'confirmada' });
  assert.equal(res.codigo, 404);

  const cancelar = respuesta();
  await ctrlUsuario.cancelarReserva(
    { usuario: usuarioDe(USUARIO_A), params: { id: '$ne' } },
    cancelar
  );
  assert.equal(cancelar.codigo, 404);
});

// ===========================================================================
// 5. NOTIFICACIONES
// ===========================================================================

test('el establecimiento solo ve y marca sus propias notificaciones', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  await crear(USUARIO_A, cuerpoValido({ actividad: ACTIVIDAD_2, fecha: enDias(6) }));

  const del1 = respuesta();
  await ctrlSitio.obtenerNotificacionesSitio({ usuario: sitioDe(SITIO_1) }, del1);
  assert.equal(del1.cuerpo.length, 1);

  const del2 = respuesta();
  await ctrlSitio.obtenerNotificacionesSitio({ usuario: sitioDe(SITIO_2) }, del2);
  assert.equal(del2.cuerpo.length, 1);

  const idDelSitio2 = String(del2.cuerpo[0]._id);

  const ajena = respuesta();
  await ctrlSitio.marcarNotificacionSitioLeida(
    { usuario: sitioDe(SITIO_1), params: { id: idDelSitio2 } },
    ajena
  );
  assert.equal(ajena.codigo, 404);
  assert.equal(del2.cuerpo[0].leida, false);

  const propia = respuesta();
  await ctrlSitio.marcarNotificacionSitioLeida(
    { usuario: sitioDe(SITIO_2), params: { id: idDelSitio2 } },
    propia
  );
  assert.equal(propia.codigo, 200);
  assert.equal(propia.cuerpo.notificacion.leida, true);
});

test('el usuario solo ve y marca sus propias notificaciones', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  await crear(USUARIO_B, cuerpoValido({ fecha: enDias(5) }));

  const propias = respuesta();
  await ctrlNotificaciones.obtenerNotificaciones(
    { usuario: usuarioDe(USUARIO_A), params: {} },
    propias
  );
  assert.equal(propias.codigo, 200);
  assert.ok(propias.cuerpo.length >= 1);
  assert.ok(propias.cuerpo.every((n) => String(n.usuario) === USUARIO_A));

  // La ruta anterior con el id de otra persona queda prohibida.
  const ajenas = respuesta();
  await ctrlNotificaciones.obtenerNotificaciones(
    { usuario: usuarioDe(USUARIO_A), params: { usuarioId: USUARIO_B } },
    ajenas
  );
  assert.equal(ajenas.codigo, 403);

  // La ruta anterior con su propio id sigue funcionando.
  const compat = respuesta();
  await ctrlNotificaciones.obtenerNotificaciones(
    { usuario: usuarioDe(USUARIO_A), params: { usuarioId: USUARIO_A } },
    compat
  );
  assert.equal(compat.codigo, 200);

  const deB = bd.notificaciones.find((n) => String(n.usuario) === USUARIO_B);
  const marcarAjena = respuesta();
  await ctrlNotificaciones.marcarLeida(
    { usuario: usuarioDe(USUARIO_A), params: { id: String(deB._id) } },
    marcarAjena
  );
  assert.equal(marcarAjena.codigo, 404);
  assert.equal(deB.leida, false);

  const deA = bd.notificaciones.find((n) => String(n.usuario) === USUARIO_A);
  const marcarPropia = respuesta();
  await ctrlNotificaciones.marcarLeida(
    { usuario: usuarioDe(USUARIO_A), params: { id: String(deA._id) } },
    marcarPropia
  );
  assert.equal(marcarPropia.codigo, 200);
  assert.equal(deA.leida, true);
});

// ===========================================================================
// 6. ADMINISTRADOR Y COMPATIBILIDAD
// ===========================================================================

test('el administrador puede usar el nuevo estado rechazada y rechaza los desconocidos', async () => {
  reiniciar();

  await crear(USUARIO_A, cuerpoValido());
  const id = String(bd.reservas[0]._id);

  const ok = respuesta();
  await ctrlAdmin.actualizarEstadoReserva(
    { params: { id }, body: { estado: 'rechazada' } },
    ok
  );
  assert.equal(ok.codigo, 200);
  assert.equal(bd.reservas[0].estado, 'rechazada');

  const mal = respuesta();
  await ctrlAdmin.actualizarEstadoReserva(
    { params: { id }, body: { estado: 'inventado' } },
    mal
  );
  assert.equal(mal.codigo, 400);
});

test('las funciones y rutas que ya usaba el proyecto siguen existiendo', () => {
  for (const nombre of ['obtenerReservas', 'crearReserva', 'actualizarReserva', 'cancelarReserva']) {
    assert.equal(typeof ctrlUsuario[nombre], 'function', nombre);
  }

  for (const nombre of ['obtenerReservas', 'obtenerReserva', 'actualizarEstadoReserva']) {
    assert.equal(typeof ctrlSitio[nombre], 'function', nombre);
    assert.equal(typeof ctrlAdmin[nombre], 'function', nombre);
  }

  const firmas = (router) => router.rutas.map((r) => `${r.metodo} ${r.ruta}`);

  assert.deepEqual(
    firmas(rutasUsuario).sort(),
    ['get /', 'post /', 'put /:id', 'put /:id/cancelar'].sort()
  );

  for (const esperada of [
    'get /:id',
    'get /:id/:reservaId',
    'put /:id/:reservaId/estado'
  ]) {
    assert.ok(firmas(rutasSitio).includes(esperada), esperada);
  }

  for (const esperada of ['get /', 'get /:id', 'patch /:id/estado']) {
    assert.ok(firmas(rutasAdmin).includes(esperada), esperada);
  }

  for (const esperada of ['get /:usuarioId', 'put /:id/leida']) {
    assert.ok(firmas(rutasNotificaciones).includes(esperada), esperada);
  }
});
