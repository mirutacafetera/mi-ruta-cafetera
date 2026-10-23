// Pruebas del inicio de sesión con Google de administradores y sitios.
//
// No usan red ni MongoDB: se simulan google-auth-library y los modelos.
// Ejecutar desde backend/:  node --test tests/google_cuentas.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');
const jwt = require('jsonwebtoken');

process.env.JWT_SECRET = 'secreto-de-prueba';
process.env.GOOGLE_CLIENT_ID = 'cliente-de-prueba.apps.googleusercontent.com';

// ---------- Google simulado ----------
let respuestaGoogle = null;
let audienciaRecibida = null;

class OAuth2ClientFalso {
  async verifyIdToken({ audience }) {
    audienciaRecibida = audience;
    if (respuestaGoogle instanceof Error) {
      throw respuestaGoogle;
    }
    return { getPayload: () => respuestaGoogle };
  }
}

// ---------- Modelos simulados ----------
function crearModelo() {
  const modelo = {
    cuentas: [],
    actualizaciones: [],
    errorAlActualizar: null,
    async findOne(consulta) {
      const claves = Object.keys(consulta);
      return (
        this.cuentas.find((c) =>
          claves.every((k) => c[k] === consulta[k])
        ) || null
      );
    },
    async updateOne(filtro, cambio) {
      this.actualizaciones.push({ filtro, cambio });
      if (this.errorAlActualizar) {
        throw this.errorAlActualizar;
      }
      const cuenta = this.cuentas.find((c) => c._id === filtro._id);
      if (!cuenta || cuenta.googleId) {
        return { matchedCount: 0 };
      }
      cuenta.googleId = cambio.$set.googleId;
      return { matchedCount: 1 };
    }
  };
  return modelo;
}

const Administrador = crearModelo();
const CuentaSitio = crearModelo();

const cargarOriginal = Module._load;
Module._load = function (request) {
  if (request === 'google-auth-library') {
    return { OAuth2Client: OAuth2ClientFalso };
  }
  if (request.endsWith('models/admin/administrador')) return Administrador;
  if (request.endsWith('models/sitio/auth')) return CuentaSitio;
  return cargarOriginal.apply(this, arguments);
};
const {
  loginAdministradorConGoogle,
  loginSitioConGoogle
} = require('../controllers/auth/googleCuentas.controller');
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

const peticion = (idToken = 'token-de-google') => ({ body: { idToken } });

const identidad = (extra = {}) => ({
  sub: 'google-sub-1',
  email: 'Admin@Correo.com',
  email_verified: true,
  ...extra
});

function reiniciar() {
  respuestaGoogle = identidad();
  audienciaRecibida = null;
  Administrador.cuentas = [
    {
      _id: 'a1',
      nombre: 'Ana',
      apellido: 'Admin',
      correo: 'admin@correo.com',
      telefono: '300',
      activo: true,
      isVerified: true
    }
  ];
  CuentaSitio.cuentas = [
    {
      _id: 's1',
      sitioId: 'sitio-1',
      nombre: 'Sara',
      apellido: 'Sitio',
      correo: 'admin@correo.com',
      telefono: '300',
      activo: true
    }
  ];
  for (const m of [Administrador, CuentaSitio]) {
    m.actualizaciones = [];
    m.errorAlActualizar = null;
  }
}

test('administrador: primer acceso vincula Google y emite JWT de admin', async () => {
  reiniciar();
  const res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);

  assert.equal(res.codigo, 200);
  assert.equal(res.cuerpo.administrador.rol, 'admin');
  assert.equal(res.cuerpo.administrador.correo, 'admin@correo.com');
  assert.equal(audienciaRecibida, process.env.GOOGLE_CLIENT_ID);

  const datos = jwt.verify(res.cuerpo.token, process.env.JWT_SECRET);
  assert.equal(datos.rol, 'admin');
  assert.equal(datos.id, 'a1');

  assert.equal(Administrador.cuentas[0].googleId, 'google-sub-1');
  assert.equal(Administrador.actualizaciones.length, 1);
});

test('administrador: segundo acceso entra por googleId sin volver a vincular', async () => {
  reiniciar();
  Administrador.cuentas[0].googleId = 'google-sub-1';
  respuestaGoogle = identidad({ email: 'otro.correo@gmail.com' });

  const res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);

  assert.equal(res.codigo, 200);
  assert.equal(Administrador.actualizaciones.length, 0);
});

test('administrador: una cuenta ya vinculada no admite otra cuenta de Google con el mismo correo', async () => {
  reiniciar();
  Administrador.cuentas[0].googleId = 'otra-persona';

  const res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);

  assert.equal(res.codigo, 403);
  assert.equal(res.cuerpo.token, undefined);
  assert.equal(Administrador.actualizaciones.length, 0);
});

test('administrador: sin cuenta autorizada no se crea nada (403)', async () => {
  reiniciar();
  respuestaGoogle = identidad({ email: 'desconocido@gmail.com' });

  const res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);

  assert.equal(res.codigo, 403);
  assert.equal(Administrador.cuentas.length, 1);
  assert.equal(res.cuerpo.token, undefined);
});

test('administrador inactivo o sin verificar: 403 y no se vincula', async () => {
  reiniciar();
  Administrador.cuentas[0].activo = false;
  let res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);
  assert.equal(res.codigo, 403);

  reiniciar();
  Administrador.cuentas[0].isVerified = false;
  res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);
  assert.equal(res.codigo, 403);
  assert.equal(Administrador.actualizaciones.length, 0);
});

test('correo de Google no verificado: 401', async () => {
  reiniciar();
  respuestaGoogle = identidad({ email_verified: false });

  const res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);

  assert.equal(res.codigo, 401);
  assert.equal(Administrador.actualizaciones.length, 0);
});

test('token inválido: 401 sin filtrar detalles; sin token: 400', async () => {
  reiniciar();
  respuestaGoogle = new Error('Wrong recipient, payload audience != requiredAudience');

  let res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);
  assert.equal(res.codigo, 401);
  assert.doesNotMatch(JSON.stringify(res.cuerpo), /audience/i);

  res = crearRes();
  await loginAdministradorConGoogle({ body: {} }, res);
  assert.equal(res.codigo, 400);

  res = crearRes();
  await loginAdministradorConGoogle({ body: { idToken: { $ne: null } } }, res);
  assert.equal(res.codigo, 400);
});

test('un administrador no puede entrar como sitio ni al revés', async () => {
  reiniciar();
  Administrador.cuentas[0].correo = 'solo.admin@correo.com';
  respuestaGoogle = identidad({ email: 'solo.admin@correo.com' });

  const res = crearRes();
  await loginSitioConGoogle(peticion(), res);

  assert.equal(res.codigo, 403);
  assert.equal(CuentaSitio.actualizaciones.length, 0);
});

test('sitio: vincula Google y el JWT lleva el sitio de la cuenta', async () => {
  reiniciar();
  const res = crearRes();
  await loginSitioConGoogle(peticion(), res);

  assert.equal(res.codigo, 200);
  assert.equal(res.cuerpo.cuenta.rol, 'sitio');
  assert.equal(res.cuerpo.cuenta.sitioId, 'sitio-1');

  const datos = jwt.verify(res.cuerpo.token, process.env.JWT_SECRET);
  assert.equal(datos.rol, 'sitio');
  assert.equal(datos.sitioId, 'sitio-1');
  assert.equal(CuentaSitio.cuentas[0].googleId, 'google-sub-1');
});

test('sitio inactivo: 403', async () => {
  reiniciar();
  CuentaSitio.cuentas[0].activo = false;

  const res = crearRes();
  await loginSitioConGoogle(peticion(), res);

  assert.equal(res.codigo, 403);
  assert.equal(CuentaSitio.actualizaciones.length, 0);
});

test('carrera al vincular o índice único duplicado: 409', async () => {
  reiniciar();
  Administrador.cuentas[0].googleId = undefined;
  Administrador.errorAlActualizar = { code: 11000 };

  let res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);
  assert.equal(res.codigo, 409);

  reiniciar();
  const original = Administrador.updateOne;
  Administrador.updateOne = async () => ({ matchedCount: 0 });
  res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);
  Administrador.updateOne = original;
  assert.equal(res.codigo, 409);
});

test('un error inesperado devuelve 500 genérico', async () => {
  reiniciar();
  const original = Administrador.findOne;
  Administrador.findOne = async () => {
    throw new Error('fallo interno con detalles');
  };

  const res = crearRes();
  await loginAdministradorConGoogle(peticion(), res);
  Administrador.findOne = original;

  assert.equal(res.codigo, 500);
  assert.doesNotMatch(JSON.stringify(res.cuerpo), /detalles/);
});
