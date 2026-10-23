// Pruebas de la recuperación de contraseña del USUARIO.
// NO usan MongoDB, red ni correo real: el modelo Usuario, bcrypt y el
// correo se sustituyen por simulaciones en memoria. Por eso NO prueban
// el comportamiento de bcrypt real ni de MongoDB real.
//
// Ejecutar desde backend/:  node --test tests/recuperacion_password.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');

process.env.JWT_SECRET = 'secreto-de-prueba-solo-tests';
delete process.env.RECUPERACION_HMAC_KEY;

// ---------------------------------------------------------------------------
// Simulaciones
// ---------------------------------------------------------------------------

let usuarios;
let correos;
// El controlador toma la función al cargarse, por eso el simulacro
// delega en esta variable, que las pruebas pueden cambiar.
let envioCorreo = async (correo, nombre, codigo) => {
  correos.push({ correo, nombre, codigo });
};
let llamadasModelo;

const ID = 'a'.repeat(24);

function nuevoUsuario(extra = {}) {
  return {
    _id: ID,
    nombre: 'Ana',
    correo: 'ana@correo.com',
    password: 'hash:clave-vieja',
    eliminadoAt: null,
    codigoRecuperacion: null,
    codigoRecuperacionExpiracion: null,
    tokenRecuperacion: null,
    tokenRecuperacionExpiracion: null,
    ...extra
  };
}

function reiniciar(lista = [nuevoUsuario()]) {
  usuarios = lista;
  correos = [];
  llamadasModelo = 0;
}

const Usuario = {
  async findOne(filtro) {
    llamadasModelo++;
    return (
      usuarios.find(
        (u) =>
          u.correo === filtro.correo &&
          (u.eliminadoAt ?? null) === filtro.eliminadoAt
      ) || null
    );
  },
  async updateOne(filtro, cambio) {
    llamadasModelo++;
    const u = usuarios.find(
      (x) =>
        x._id === filtro._id &&
        (filtro.codigoRecuperacion === undefined ||
          x.codigoRecuperacion === filtro.codigoRecuperacion)
    );
    if (!u) return { modifiedCount: 0 };
    Object.assign(u, cambio.$set);
    return { modifiedCount: 1 };
  },
  async findOneAndUpdate(filtro, cambio) {
    llamadasModelo++;
    const u = usuarios.find(
      (x) =>
        typeof filtro.tokenRecuperacion === 'string' &&
        x.tokenRecuperacion === filtro.tokenRecuperacion &&
        x.tokenRecuperacionExpiracion &&
        x.tokenRecuperacionExpiracion > filtro.tokenRecuperacionExpiracion.$gt &&
        (x.eliminadoAt ?? null) === filtro.eliminadoAt
    );
    if (!u) return null;
    Object.assign(u, cambio.$set);
    return u;
  }
};

const simulaciones = {
  'models/usuario/usuario': Usuario,
  'utils/mailer': {
    enviarCodigoRecuperacion: (...args) => envioCorreo(...args)
  },
  bcryptjs: {
    hash: async (plano) => `hash:${plano}`,
    compare: async (plano, hash) => hash === `hash:${plano}`
  }
};

const cargarOriginal = Module._load;
Module._load = function (request, parent, esMain) {
  for (const [clave, valor] of Object.entries(simulaciones)) {
    if (request === clave || request.endsWith('/' + clave)) return valor;
  }
  return cargarOriginal.call(this, request, parent, esMain);
};

const {
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword,
  _huellaCodigo,
  _huellaToken
} = require('../controllers/usuario/recuperacion.controller');

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

async function llamar(fn, body) {
  const res = crearRes();
  await fn({ body }, res);
  return res;
}

const esperarCorreo = () => new Promise((r) => setImmediate(r));

async function pedirCodigo(correo = 'ana@correo.com') {
  const res = await llamar(recuperarPassword, { correo });
  await esperarCorreo();
  return res;
}

// ---------------------------------------------------------------------------
// 1. Solicitud del código
// ---------------------------------------------------------------------------

test('correo registrado: 200, código enviado y guardado solo como huella', async () => {
  reiniciar();
  const res = await pedirCodigo();
  assert.equal(res.codigo, 200);
  assert.equal(correos.length, 1);
  assert.match(correos[0].codigo, /^\d{6}$/);
  const u = usuarios[0];
  assert.notEqual(u.codigoRecuperacion, correos[0].codigo);
  assert.match(u.codigoRecuperacion, /^[a-f0-9]{64}$/);
  assert.ok(u.codigoRecuperacionExpiracion > new Date());
  const minutos = (u.codigoRecuperacionExpiracion - Date.now()) / 60000;
  assert.ok(minutos > 9 && minutos <= 10);
});

test('correo NO registrado: misma respuesta 200 y no se envía nada', async () => {
  reiniciar();
  const registrado = await pedirCodigo('ana@correo.com');
  const nuevoEscenario = [nuevoUsuario()];
  reiniciar(nuevoEscenario);
  const desconocido = await pedirCodigo('nadie@correo.com');
  assert.equal(desconocido.codigo, 200);
  assert.deepEqual(desconocido.cuerpo, registrado.cuerpo);
  assert.equal(correos.length, 0);
});

test('correo con mayúsculas y espacios se normaliza', async () => {
  reiniciar();
  const res = await pedirCodigo('  ANA@Correo.com ');
  assert.equal(res.codigo, 200);
  assert.equal(correos.length, 1);
});

test('cuenta eliminada: respuesta genérica y sin correo', async () => {
  reiniciar([nuevoUsuario({ eliminadoAt: new Date() })]);
  const res = await pedirCodigo();
  assert.equal(res.codigo, 200);
  assert.equal(correos.length, 0);
});

test('correo ausente, vacío, inválido u objeto: 400 sin consultar la base', async () => {
  reiniciar();
  for (const correo of [undefined, '', 'sin-arroba', 123, { $ne: null }, ['a@b.c']]) {
    const res = await llamar(recuperarPassword, { correo });
    assert.equal(res.codigo, 400, JSON.stringify(correo));
  }
  const res = await llamar(recuperarPassword, undefined);
  assert.equal(res.codigo, 400);
  assert.equal(llamadasModelo, 0);
});

test('solicitud repetida: solo vale el código más reciente', async () => {
  reiniciar();
  await pedirCodigo();
  await pedirCodigo();
  assert.equal(correos.length, 2);
  const [primero, segundo] = correos.map((c) => c.codigo);
  if (primero !== segundo) {
    const viejo = await llamar(verificarCodigoRecuperacion, {
      correo: 'ana@correo.com',
      codigo: primero
    });
    assert.equal(viejo.codigo, 400);
  }
  const nuevo = await llamar(verificarCodigoRecuperacion, {
    correo: 'ana@correo.com',
    codigo: segundo
  });
  assert.equal(nuevo.codigo, 200);
});

test('un fallo de base de datos devuelve 500 genérico sin detalles', async () => {
  reiniciar();
  const original = Usuario.findOne;
  Usuario.findOne = async () => {
    throw new Error('detalle interno secreto');
  };
  const res = await llamar(recuperarPassword, { correo: 'ana@correo.com' });
  Usuario.findOne = original;
  assert.equal(res.codigo, 500);
  assert.equal(JSON.stringify(res.cuerpo).includes('secreto'), false);
  assert.equal(res.cuerpo.error, undefined);
});

test('un fallo del envío de correo no cambia la respuesta ni escribe el código en el log', async () => {
  reiniciar();
  const original = envioCorreo;
  envioCorreo = async () => {
    throw new Error('SMTP caído');
  };
  const registro = [];
  const errorOriginal = console.error;
  console.error = (...a) => registro.push(a.join(' '));
  const res = await llamar(recuperarPassword, { correo: 'ana@correo.com' });
  await esperarCorreo();
  console.error = errorOriginal;
  envioCorreo = original;
  assert.equal(res.codigo, 200);
  assert.ok(registro.length >= 1);
  assert.equal(/\d{6}/.test(registro.join(' ')), false);
});

// ---------------------------------------------------------------------------
// 2. Verificación del código
// ---------------------------------------------------------------------------

test('código correcto: devuelve token de 64 hex, guardado solo como huella, y consume el código', async () => {
  reiniciar();
  await pedirCodigo();
  const codigo = correos[0].codigo;
  const res = await llamar(verificarCodigoRecuperacion, {
    correo: 'ana@correo.com',
    codigo
  });
  assert.equal(res.codigo, 200);
  assert.match(res.cuerpo.tokenRecuperacion, /^[a-f0-9]{64}$/);
  const u = usuarios[0];
  assert.notEqual(u.tokenRecuperacion, res.cuerpo.tokenRecuperacion);
  assert.equal(u.tokenRecuperacion, _huellaToken(res.cuerpo.tokenRecuperacion));
  assert.equal(u.codigoRecuperacion, null);
});

test('código reutilizado: 400', async () => {
  reiniciar();
  await pedirCodigo();
  const codigo = correos[0].codigo;
  const datos = { correo: 'ana@correo.com', codigo };
  assert.equal((await llamar(verificarCodigoRecuperacion, datos)).codigo, 200);
  assert.equal((await llamar(verificarCodigoRecuperacion, datos)).codigo, 400);
});

test('código incorrecto, expirado y correo desconocido dan el mismo 400', async () => {
  reiniciar();
  await pedirCodigo();
  const codigo = correos[0].codigo;
  const incorrecto = codigo === '111111' ? '222222' : '111111';

  const mal = await llamar(verificarCodigoRecuperacion, {
    correo: 'ana@correo.com',
    codigo: incorrecto
  });

  usuarios[0].codigoRecuperacionExpiracion = new Date(Date.now() - 1000);
  const expirado = await llamar(verificarCodigoRecuperacion, {
    correo: 'ana@correo.com',
    codigo
  });

  const desconocido = await llamar(verificarCodigoRecuperacion, {
    correo: 'nadie@correo.com',
    codigo
  });

  for (const r of [mal, expirado, desconocido]) {
    assert.equal(r.codigo, 400);
    assert.deepEqual(r.cuerpo, mal.cuerpo);
  }
});

test('un código guardado en texto legible (versión anterior) ya no sirve', async () => {
  reiniciar([
    nuevoUsuario({
      codigoRecuperacion: '123456',
      codigoRecuperacionExpiracion: new Date(Date.now() + 60000)
    })
  ]);
  const res = await llamar(verificarCodigoRecuperacion, {
    correo: 'ana@correo.com',
    codigo: '123456'
  });
  assert.equal(res.codigo, 400);
});

test('el código de otro correo no sirve (la huella incluye el correo)', () => {
  assert.notEqual(
    _huellaCodigo('a@x.com', '123456'),
    _huellaCodigo('b@x.com', '123456')
  );
});

test('formato inválido de código o correo: 400 sin consultar la base', async () => {
  reiniciar();
  const casos = [
    { correo: 'ana@correo.com', codigo: '12345' },
    { correo: 'ana@correo.com', codigo: 'abcdef' },
    { correo: 'ana@correo.com', codigo: { $ne: null } },
    { correo: { $ne: null }, codigo: '123456' },
    { correo: 'ana@correo.com' },
    undefined
  ];
  for (const c of casos) {
    const res = await llamar(verificarCodigoRecuperacion, c);
    assert.equal(res.codigo, 400, JSON.stringify(c));
  }
  assert.equal(llamadasModelo, 0);
});

// ---------------------------------------------------------------------------
// 3. Restablecer la contraseña
// ---------------------------------------------------------------------------

async function obtenerToken() {
  await pedirCodigo();
  const res = await llamar(verificarCodigoRecuperacion, {
    correo: 'ana@correo.com',
    codigo: correos[correos.length - 1].codigo
  });
  return res.cuerpo.tokenRecuperacion;
}

test('flujo completo: cambia la contraseña, consume el token y la anterior deja de coincidir', async () => {
  reiniciar();
  const token = await obtenerToken();
  const res = await llamar(restablecerPassword, {
    tokenRecuperacion: token,
    nuevaPassword: 'nueva-clave-1'
  });
  assert.equal(res.codigo, 200);
  const u = usuarios[0];
  assert.equal(u.password, 'hash:nueva-clave-1');
  assert.notEqual(u.password, 'hash:clave-vieja');
  assert.equal(u.tokenRecuperacion, null);
  assert.equal(u.tokenRecuperacionExpiracion, null);
  const bcrypt = simulaciones.bcryptjs;
  assert.equal(await bcrypt.compare('nueva-clave-1', u.password), true);
  assert.equal(await bcrypt.compare('clave-vieja', u.password), false);
});

test('token reutilizado: 400 y la contraseña no vuelve a cambiar', async () => {
  reiniciar();
  const token = await obtenerToken();
  await llamar(restablecerPassword, {
    tokenRecuperacion: token,
    nuevaPassword: 'nueva-clave-1'
  });
  const otra = await llamar(restablecerPassword, {
    tokenRecuperacion: token,
    nuevaPassword: 'otra-clave-2'
  });
  assert.equal(otra.codigo, 400);
  assert.equal(usuarios[0].password, 'hash:nueva-clave-1');
});

test('token expirado: 400 y no cambia nada', async () => {
  reiniciar();
  const token = await obtenerToken();
  usuarios[0].tokenRecuperacionExpiracion = new Date(Date.now() - 1000);
  const res = await llamar(restablecerPassword, {
    tokenRecuperacion: token,
    nuevaPassword: 'nueva-clave-1'
  });
  assert.equal(res.codigo, 400);
  assert.equal(usuarios[0].password, 'hash:clave-vieja');
});

test('token inventado (con formato válido): 400', async () => {
  reiniciar();
  await obtenerToken();
  const res = await llamar(restablecerPassword, {
    tokenRecuperacion: 'f'.repeat(64),
    nuevaPassword: 'nueva-clave-1'
  });
  assert.equal(res.codigo, 400);
  assert.equal(usuarios[0].password, 'hash:clave-vieja');
});

test('token como objeto/operador de Mongo ({"$ne": null}): 400 sin tocar la base', async () => {
  reiniciar();
  await obtenerToken();
  const antes = llamadasModelo;
  for (const t of [{ $ne: null }, { $gt: '' }, ['x'], 12345, '', 'corto', 'G'.repeat(64)]) {
    const res = await llamar(restablecerPassword, {
      tokenRecuperacion: t,
      nuevaPassword: 'nueva-clave-1'
    });
    assert.equal(res.codigo, 400, JSON.stringify(t));
  }
  assert.equal(llamadasModelo, antes);
  assert.equal(usuarios[0].password, 'hash:clave-vieja');
});

test('contraseña débil o inválida: 400 y el token sigue vigente', async () => {
  reiniciar();
  const token = await obtenerToken();
  const largo = 'a'.repeat(73);
  for (const p of ['', '12345', 'abc', undefined, null, 123456, { $ne: 1 }, largo]) {
    const res = await llamar(restablecerPassword, {
      tokenRecuperacion: token,
      nuevaPassword: p
    });
    assert.equal(res.codigo, 400, JSON.stringify(p));
  }
  assert.ok(usuarios[0].tokenRecuperacion);
  const ok = await llamar(restablecerPassword, {
    tokenRecuperacion: token,
    nuevaPassword: '123456'
  });
  assert.equal(ok.codigo, 200);
});

test('la política actual de 6 caracteres se mantiene (mínimo 6, máximo 72 bytes)', async () => {
  reiniciar();
  let token = await obtenerToken();
  const seis = await llamar(restablecerPassword, {
    tokenRecuperacion: token,
    nuevaPassword: 'abc123'
  });
  assert.equal(seis.codigo, 200);

  token = await obtenerToken();
  const limite = await llamar(restablecerPassword, {
    tokenRecuperacion: token,
    nuevaPassword: 'a'.repeat(72)
  });
  assert.equal(limite.codigo, 200);
});

test('el token de recuperación es independiente del JWT de sesión', async () => {
  reiniciar();
  const token = await obtenerToken();
  assert.match(token, /^[a-f0-9]{64}$/);
  assert.equal(token.includes('.'), false); // un JWT tiene 3 partes con puntos
});
