// Pruebas de Ayuda y soporte del USUARIO (POST/GET /api/ayuda).
// NO usan MongoDB ni red: el modelo Ayuda y el middleware de
// autenticación se sustituyen por simulaciones en memoria. La
// verificación real del JWT no se prueba aquí.
//
// Ejecutar desde backend/:  node --test tests/ayuda.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('module');

let reportes;
let siguiente;

function reiniciar() {
  reportes = [];
  siguiente = 1;
}

const Ayuda = {
  findOne(filtro) {
    const encontrado = reportes.find(
      (r) =>
        r.usuarioId === filtro.usuarioId &&
        r.asunto === filtro.asunto &&
        r.mensaje === filtro.mensaje &&
        r.createdAt >= filtro.createdAt.$gte
    );
    return {
      select() {
        return this;
      },
      lean: async () => encontrado || null
    };
  },
  async create(datos) {
    const doc = {
      _id: `r${siguiente++}`,
      estado: 'pendiente',
      respuestaAdmin: null,
      createdAt: new Date(),
      updatedAt: new Date(),
      ...datos
    };
    reportes.push(doc);
    return doc;
  },
  find(filtro) {
    let lista = reportes.filter((r) => r.usuarioId === filtro.usuarioId);
    const cadena = {
      select(campos) {
        this.campos = campos.split(' ');
        return this;
      },
      sort() {
        lista = [...lista].sort((a, b) => b.createdAt - a.createdAt);
        return this;
      },
      limit(n) {
        lista = lista.slice(0, n);
        return this;
      },
      async lean() {
        return lista.map((r) => {
          const salida = { _id: r._id };
          for (const c of this.campos) salida[c] = r[c];
          return salida;
        });
      }
    };
    return cadena;
  }
};

const cargarOriginal = Module._load;
Module._load = function (request, parent, esMain) {
  if (request.endsWith('models/usuario/ayuda')) return Ayuda;
  return cargarOriginal.call(this, request, parent, esMain);
};

const {
  crearReporte,
  obtenerMisReportes
} = require('../controllers/usuario/ayuda.controller');

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

const USUARIO_A = 'a'.repeat(24);
const USUARIO_B = 'b'.repeat(24);

async function enviar(body, usuarioId = USUARIO_A) {
  const res = crearRes();
  await crearReporte({ usuario: { id: usuarioId, rol: 'usuario' }, body }, res);
  return res;
}

async function listar(usuarioId = USUARIO_A) {
  const res = crearRes();
  await obtenerMisReportes({ usuario: { id: usuarioId, rol: 'usuario' } }, res);
  return res;
}

const valido = {
  asunto: 'No me carga el mapa',
  mensaje: 'Cuando abro el mapa se queda en blanco desde ayer.'
};

test('envío válido: 201, estado pendiente y pertenece al usuario del token', async () => {
  reiniciar();
  const res = await enviar(valido);
  assert.equal(res.codigo, 201);
  assert.equal(res.cuerpo.reporte.estado, 'pendiente');
  assert.equal(reportes.length, 1);
  assert.equal(reportes[0].usuarioId, USUARIO_A);
});

test('la identidad sale del token: usuarioId/estado enviados en el cuerpo se ignoran', async () => {
  reiniciar();
  const res = await enviar({
    ...valido,
    usuarioId: USUARIO_B,
    estado: 'resuelto',
    respuestaAdmin: 'hecho'
  });
  assert.equal(res.codigo, 201);
  assert.equal(reportes[0].usuarioId, USUARIO_A);
  assert.equal(reportes[0].estado, 'pendiente');
  assert.equal(reportes[0].respuestaAdmin, null);
});

test('la respuesta no incluye el documento completo ni el id del usuario', async () => {
  reiniciar();
  const res = await enviar(valido);
  assert.deepEqual(Object.keys(res.cuerpo.reporte).sort(), [
    'asunto',
    'createdAt',
    'estado',
    'id',
    'mensaje'
  ]);
});

test('datos inválidos: 400 y no se guarda nada', async () => {
  reiniciar();
  const casos = [
    {},
    undefined,
    { asunto: '', mensaje: '' },
    { asunto: 'ab', mensaje: valido.mensaje },
    { asunto: valido.asunto, mensaje: 'corto' },
    { asunto: '   ', mensaje: valido.mensaje },
    { asunto: 'a'.repeat(101), mensaje: valido.mensaje },
    { asunto: valido.asunto, mensaje: 'm'.repeat(1001) },
    { asunto: { $ne: null }, mensaje: valido.mensaje },
    { asunto: valido.asunto, mensaje: ['x'.repeat(20)] },
    { asunto: 12345, mensaje: valido.mensaje }
  ];
  for (const c of casos) {
    const res = await enviar(c);
    assert.equal(res.codigo, 400, JSON.stringify(c));
  }
  assert.equal(reportes.length, 0);
});

test('los límites exactos son válidos y se aplica trim', async () => {
  reiniciar();
  const res = await enviar({
    asunto: `  ${'a'.repeat(100)}  `,
    mensaje: `  ${'m'.repeat(1000)}  `
  });
  assert.equal(res.codigo, 201);
  assert.equal(reportes[0].asunto.length, 100);
  assert.equal(reportes[0].mensaje.length, 1000);
});

test('doble envío del mismo reporte: 409 y queda uno solo', async () => {
  reiniciar();
  assert.equal((await enviar(valido)).codigo, 201);
  assert.equal((await enviar(valido)).codigo, 409);
  assert.equal(reportes.length, 1);
});

test('el mismo texto de OTRO usuario no cuenta como duplicado', async () => {
  reiniciar();
  assert.equal((await enviar(valido, USUARIO_A)).codigo, 201);
  assert.equal((await enviar(valido, USUARIO_B)).codigo, 201);
});

test('un reporte distinto o pasado el plazo se acepta de nuevo', async () => {
  reiniciar();
  await enviar(valido);
  assert.equal(
    (await enviar({ ...valido, mensaje: 'Ahora tampoco carga el listado.' })).codigo,
    201
  );
  reportes[0].createdAt = new Date(Date.now() - 11 * 60 * 1000);
  assert.equal((await enviar(valido)).codigo, 201);
});

test('error del servidor: 500 genérico sin detalles internos', async () => {
  reiniciar();
  const original = Ayuda.create;
  Ayuda.create = async () => {
    throw new Error('detalle interno secreto');
  };
  const res = await enviar(valido);
  Ayuda.create = original;
  assert.equal(res.codigo, 500);
  assert.equal(JSON.stringify(res.cuerpo).includes('secreto'), false);
});

test('reintento después de un error del servidor funciona', async () => {
  reiniciar();
  const original = Ayuda.create;
  Ayuda.create = async () => {
    throw new Error('caída');
  };
  assert.equal((await enviar(valido)).codigo, 500);
  Ayuda.create = original;
  assert.equal((await enviar(valido)).codigo, 201);
});

test('GET devuelve solo los reportes del usuario autenticado', async () => {
  reiniciar();
  await enviar(valido, USUARIO_A);
  await enviar({ ...valido, asunto: 'Otro asunto de B' }, USUARIO_B);
  const a = await listar(USUARIO_A);
  const b = await listar(USUARIO_B);
  assert.equal(a.codigo, 200);
  assert.equal(a.cuerpo.length, 1);
  assert.equal(a.cuerpo[0].asunto, valido.asunto);
  assert.equal(b.cuerpo.length, 1);
  assert.equal(b.cuerpo[0].asunto, 'Otro asunto de B');
});

test('GET no expone el id del usuario y trae la respuesta del administrador', async () => {
  reiniciar();
  await enviar(valido);
  reportes[0].respuestaAdmin = 'Ya lo revisamos';
  const res = await listar();
  assert.equal(res.cuerpo[0].usuarioId, undefined);
  assert.equal(res.cuerpo[0].respuestaAdmin, 'Ya lo revisamos');
});
