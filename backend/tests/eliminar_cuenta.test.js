// Pruebas de la eliminación de cuenta (DELETE /api/usuarios/:id) y de
// verificarToken. NO usan MongoDB ni red: los modelos, bcrypt, JWT, Google y
// el correo se sustituyen por simulaciones, no tocan datos reales.
//
// Ejecutar desde backend/:  node --test tests/eliminar_cuenta.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');

// ---------------------------------------------------------------------------
// Simulaciones
// ---------------------------------------------------------------------------

const registro = []; // llamadas en orden
let estado; // se reinicia en cada prueba

function reiniciar(opciones = {}) {
  registro.length = 0;
  estado = {
    usuario: {
      _id: 'a'.repeat(24),
      nombre: 'Ana',
      apellido: 'Pérez',
      correo: 'ana@correo.com',
      password: 'hash-ok',
      telefono: '300',
      ciudad: 'Garzón',
      fotoPerfil: 'http://foto',
      eliminadoAt: null,
      async save(op) {
        registro.push(['usuario.save', { ...this }, op]);
      },
      toString() {
        return 'usuario';
      }
    },
    reservasActivas: [0], // respuestas sucesivas de countDocuments
    fallaEn: null,
    sinTransacciones: false,
    ...opciones
  };
  estado.usuario._id = {
    toString: () => 'a'.repeat(24)
  };
}

function modeloBorrado(nombre) {
  return {
    async deleteMany(filtro, op) {
      registro.push([`${nombre}.deleteMany`, filtro, op]);
      if (estado.fallaEn === nombre) throw new Error('fallo simulado');
      return { deletedCount: 1 };
    }
  };
}

const Usuario = {
  findById(id) {
    registro.push(['Usuario.findById', id]);
    const doc = estado.usuario;
    const consulta = Promise.resolve(doc);
    consulta.select = () => {
      const q = Promise.resolve(doc);
      q.lean = () => Promise.resolve(doc);
      return q;
    };
    return consulta;
  }
};

const Reserva = {
  countDocuments(filtro) {
    registro.push(['Reserva.countDocuments', filtro]);
    const valor = estado.reservasActivas.length > 1
      ? estado.reservasActivas.shift()
      : estado.reservasActivas[0];
    return { session: () => Promise.resolve(valor) };
  },
  async updateMany(filtro, cambio, op) {
    registro.push(['Reserva.updateMany', filtro, cambio, op]);
    return {};
  },
  async deleteMany() {
    throw new Error('Las reservas NO deben borrarse');
  }
};

const simulaciones = {
  'models/usuario/usuario': Usuario,
  'models/sitio/resena': modeloBorrado('Resena'),
  'models/sitio/reserva': Reserva,
  'models/usuario/favorito': modeloBorrado('Favorito'),
  'models/usuario/ruta': modeloBorrado('Ruta'),
  'models/usuario/notificacion': modeloBorrado('Notificacion'),
  'models/usuario/ayuda': modeloBorrado('Ayuda'),
  'models/usuario/visita': modeloBorrado('Visita'),
  'models/usuario/mapaoffline': modeloBorrado('MapaOffline'),
  'utils/mailer': {
    enviarCodigoVerificacion: async () => {},
    enviarCodigoRecuperacion: async () => {}
  },
  bcryptjs: {
    compare: async (plano, hash) => plano === 'clave-correcta' && hash === 'hash-ok',
    hash: async () => 'hash-inutilizable'
  },
  jsonwebtoken: {
    sign: () => 'token',
    verify: (token) => {
      if (token === 'expirado') {
        const e = new Error('expirado');
        e.name = 'TokenExpiredError';
        throw e;
      }
      if (token === 'admin') return { id: 'adm', rol: 'admin' };
      return { id: 'a'.repeat(24), correo: 'ana@correo.com', rol: 'usuario' };
    }
  },
  'google-auth-library': {
    OAuth2Client: class {
      async verifyIdToken() {
        throw new Error('no se debe llamar en estas pruebas');
      }
    }
  }
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

const mongoose = require('mongoose');

function simularSesion() {
  mongoose.startSession = async () => ({
    async withTransaction(fn) {
      if (estado.sinTransacciones) {
        throw new Error(
          'Transaction numbers are only allowed on a replica set member or mongos'
        );
      }
      registro.push(['transaccion.inicio']);
      await fn();
      registro.push(['transaccion.fin']);
    },
    async endSession() {}
  });
}

const { eliminarUsuario } = require('../controllers/usuario/usuario.controller');
const { verificarToken } = require('../middlewares/authmiddleware');

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

const ID = 'a'.repeat(24);

async function eliminar({ usuarioId = ID, rol = 'usuario', body } = {}) {
  const res = crearRes();
  await eliminarUsuario(
    { usuario: { id: usuarioId, rol }, params: { id: ID }, body },
    res
  );
  return res;
}

const llamadas = (nombre) => registro.filter((r) => r[0] === nombre);
const hubo = (prefijo) => registro.some((r) => r[0].startsWith(prefijo));
const hayBorrados = () => registro.some((r) => r[0].endsWith('.deleteMany'));
const okBody = { confirmar: true, password: 'clave-correcta' };

// ---------------------------------------------------------------------------
// eliminarUsuario
// ---------------------------------------------------------------------------

test('otro usuario: 403 y no se toca nada', async () => {
  reiniciar(); simularSesion();
  const res = await eliminar({ usuarioId: 'b'.repeat(24), body: okBody });
  assert.equal(res.codigo, 403);
  assert.equal(hayBorrados(), false);
  assert.equal(hubo('usuario.save'), false);
});

test('sin confirmación explícita: 400 y no se toca nada', async () => {
  reiniciar(); simularSesion();
  const res = await eliminar({ body: { password: 'clave-correcta' } });
  assert.equal(res.codigo, 400);
  assert.equal(hayBorrados(), false);
});

test('contraseña incorrecta o ausente: 401 y no se toca nada', async () => {
  reiniciar(); simularSesion();
  let res = await eliminar({ body: { confirmar: true, password: 'mala' } });
  assert.equal(res.codigo, 401);
  res = await eliminar({ body: { confirmar: true } });
  assert.equal(res.codigo, 401);
  assert.equal(hayBorrados(), false);
  assert.equal(hubo('usuario.save'), false);
});

test('cuenta de Google sin idToken: 401', async () => {
  reiniciar(); simularSesion();
  estado.usuario.password = 'GOOGLE_123_456';
  const res = await eliminar({ body: { confirmar: true } });
  assert.equal(res.codigo, 401);
  assert.equal(hayBorrados(), false);
});

test('reservas activas o futuras: 409 y NO se borra ni anonimiza nada', async () => {
  reiniciar({ reservasActivas: [2] }); simularSesion();
  const res = await eliminar({ body: okBody });
  assert.equal(res.codigo, 409);
  assert.equal(res.cuerpo.reservasActivas, 2);
  assert.match(res.cuerpo.mensaje, /reservas/i);
  assert.equal(hayBorrados(), false);
  assert.equal(hubo('Reserva.updateMany'), false);
  assert.equal(hubo('usuario.save'), false);
});

test('el filtro de reservas activas usa estados pendiente/confirmada y fecha desde hoy', async () => {
  reiniciar({ reservasActivas: [1] }); simularSesion();
  await eliminar({ body: okBody });
  const [, filtro] = llamadas('Reserva.countDocuments')[0];
  assert.deepEqual(filtro.estado, { $in: ['pendiente', 'confirmada'] });
  const hoy = new Date();
  hoy.setHours(0, 0, 0, 0);
  assert.equal(filtro.fecha.$gte.getTime(), hoy.getTime());
  assert.equal(filtro.usuario.toString(), ID);
});

test('reserva creada justo durante la eliminación: 409 dentro de la transacción', async () => {
  reiniciar({ reservasActivas: [0, 1] }); simularSesion();
  const res = await eliminar({ body: okBody });
  assert.equal(res.codigo, 409);
  assert.equal(hayBorrados(), false);
  assert.equal(hubo('usuario.save'), false);
});

test('eliminación correcta: borra reseñas y datos privados, conserva reservas, anonimiza al final', async () => {
    reiniciar(); simularSesion();
  const res = await eliminar({ body: okBody });
  assert.equal(res.codigo, 200);

  for (const m of ['Resena', 'Favorito', 'Ruta', 'Notificacion', 'Visita', 'MapaOffline']) {
    const [c] = llamadas(`${m}.deleteMany`);
    assert.ok(c, `${m} debe borrarse`);
    assert.equal(c[1].usuario.toString(), ID);
  }
  const [ayuda] = llamadas('Ayuda.deleteMany');
  assert.equal(ayuda[1].usuarioId.toString(), ID);

  // Las reservas se conservan sin texto libre
  const [upd] = llamadas('Reserva.updateMany');
  assert.deepEqual(upd[2], { $set: { observaciones: '' } });

  // Todo ocurre dentro de la transacción y el usuario se guarda el último
  const orden = registro.map((r) => r[0]);
  const iResena = orden.indexOf('Resena.deleteMany');
  const iSave = orden.indexOf('usuario.save');
  assert.ok(orden.indexOf('transaccion.inicio') < iResena);
  assert.ok(iResena < iSave);
  assert.ok(iSave < orden.indexOf('transaccion.fin'));
  assert.equal(orden.filter((n) => n === 'usuario.save').length, 1);

  const guardado = llamadas('usuario.save')[0][1];
  assert.equal(guardado.nombre, 'Usuario');
  assert.equal(guardado.correo, `eliminado-${ID}@anonimo.invalid`);
  assert.equal(guardado.telefono, '');
  assert.equal(guardado.fotoPerfil, '');
  assert.equal(guardado.activo, false);
  assert.ok(guardado.eliminadoAt instanceof Date);
  assert.notEqual(guardado.password, 'hash-ok');
});

test('fallo a mitad: 500, la cuenta NO se anonimiza y se puede reintentar', async () => {
  reiniciar({ fallaEn: 'Ayuda' }); simularSesion();
  const res = await eliminar({ body: okBody });
  assert.equal(res.codigo, 500);
  assert.match(res.cuerpo.mensaje, /sigue activa/i);
  assert.equal(hubo('usuario.save'), false);
  assert.equal(hubo('transaccion.fin'), false);
});

test('servidor sin transacciones: se ejecuta sin sesión y el usuario se guarda al final', async () => {
  reiniciar({ sinTransacciones: true }); simularSesion();
  const res = await eliminar({ body: okBody });
  assert.equal(res.codigo, 200);
  const orden = registro.map((r) => r[0]);
  assert.ok(orden.indexOf('Resena.deleteMany') < orden.indexOf('usuario.save'));
  assert.equal(llamadas('Resena.deleteMany')[0][2].session, undefined);
});

test('sin transacciones y fallo a mitad: la cuenta sigue sin anonimizar', async () => {
  reiniciar({ sinTransacciones: true, fallaEn: 'Visita' }); simularSesion();
  const res = await eliminar({ body: okBody });
  assert.equal(res.codigo, 500);
  assert.equal(hubo('usuario.save'), false);
});

test('cuenta ya eliminada: 404', async () => {
  reiniciar(); simularSesion();
  estado.usuario.eliminadoAt = new Date();
  const res = await eliminar({ body: okBody });
  assert.equal(res.codigo, 404);
  assert.equal(hayBorrados(), false);
});

// ---------------------------------------------------------------------------
// verificarToken
// ---------------------------------------------------------------------------

async function pasarPorMiddleware(authorization) {
  const res = crearRes();
  let siguio = false;
  const req = { headers: authorization ? { authorization } : {} };
  await verificarToken(req, res, () => {
    siguio = true;
  });
  return { res, siguio, req };
}

test('token de cuenta eliminada: 401', async () => {
  reiniciar();
  estado.usuario.eliminadoAt = new Date();
  const { res, siguio } = await pasarPorMiddleware('Bearer valido');
  assert.equal(res.codigo, 401);
  assert.equal(siguio, false);
});

test('token de cuenta que ya no existe: 401', async () => {
  reiniciar();
  estado.usuario = null;
  const { res, siguio } = await pasarPorMiddleware('Bearer valido');
  assert.equal(res.codigo, 401);
  assert.equal(siguio, false);
});

test('token de cuenta vigente: continúa', async () => {
  reiniciar();
  const { siguio, req } = await pasarPorMiddleware('Bearer valido');
  assert.equal(siguio, true);
  assert.equal(req.usuario.rol, 'usuario');
});

test('token de administrador: no consulta la colección de usuarios', async () => {
  reiniciar();
  const { siguio } = await pasarPorMiddleware('Bearer admin');
  assert.equal(siguio, true);
  assert.equal(hubo('Usuario.findById'), false);
});

test('sin cabecera o token expirado: 401', async () => {
  reiniciar();
  assert.equal((await pasarPorMiddleware(null)).res.codigo, 401);
  assert.equal((await pasarPorMiddleware('Bearer expirado')).res.codigo, 401);
});
