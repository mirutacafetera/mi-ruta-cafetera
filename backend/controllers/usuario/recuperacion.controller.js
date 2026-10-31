
const crypto = require('crypto');
const bcrypt = require('bcryptjs');

const Usuario = require('../../models/usuario/usuario');
const { enviarCodigoRecuperacion } = require('../../utils/mailer');

// =====================================================
// RECUPERACIÓN DE CONTRASEÑA DEL USUARIO (VISITANTE)
// =====================================================

// Flujo (el contrato de las 3 rutas no cambia):
//
//   1. POST /usuarios/recuperar-password
//        body: { correo }
//        Responde SIEMPRE 200 con el mismo mensaje, exista o
//        no el correo (no revela qué correos están
//        registrados). Si existe, envía un código de 6 dígitos
//        válido 10 minutos. Pedir otro código invalida el
//        anterior.
//
//   2. POST /usuarios/verificar-codigo-recuperacion
//        body: { correo, codigo }
//        Si el código es correcto y vigente, devuelve un
//        token de recuperación (aleatorio de 32 bytes,
//        independiente del JWT de sesión) válido 10 minutos.
//        El código queda consumido.
//
//   3. POST /usuarios/restablecer-password
//        body: { tokenRecuperacion, nuevaPassword }
//        Cambia la contraseña y consume el token (un solo uso,
//        de forma atómica).
//
// Seguridad:
//  - El código y el token NO se guardan en texto legible: se
//    guarda un HMAC-SHA256. La clave sale de la variable de
//    entorno RECUPERACION_HMAC_KEY (opcional); si no existe se
//    deriva, con una etiqueta propia, de JWT_SECRET. El secreto
//    JWT no se modifica ni se usa directamente.
//  - Comparación en tiempo constante.
//  - Todos los datos del cuerpo se validan como texto antes de
//    consultar la base de datos (evita inyección de operadores
//    como {"$ne": null}).
//  - Los errores internos no devuelven detalles al cliente.
//  - Nunca se escribe el código ni el token en los registros.
//  - No cambia el esquema: usa los mismos campos del modelo.
//  - Los códigos que estuvieran guardados en texto legible
//    antes de este cambio dejan de funcionar (hay que pedir
//    uno nuevo).
// =====================================================

const VIGENCIA_MS = 10 * 60 * 1000;

const PASSWORD_MIN = 6;
const PASSWORD_MAX_BYTES = 72; // límite real de bcrypt

const MENSAJE_SOLICITUD =
  'Si el correo está registrado, te enviamos un código de ' +
  'recuperación. Revisa tu bandeja de entrada.';

const MENSAJE_CODIGO_INVALIDO =
  'El código es incorrecto o ha expirado. Solicita uno nuevo.';

const MENSAJE_TOKEN_INVALIDO =
  'La solicitud de recuperación no es válida o ya expiró. ' +
  'Solicita un código nuevo.';

const MENSAJE_ERROR =
  'No se pudo procesar la solicitud. Inténtalo de nuevo.';

// -----------------------------------------------------
// Utilidades
// -----------------------------------------------------

const claveHmac = () => {
  const dedicada = process.env.RECUPERACION_HMAC_KEY;

  if (typeof dedicada === 'string' && dedicada.length >= 16) {
    return dedicada;
  }

  const base = process.env.JWT_SECRET;

  if (!base) {
    throw new Error('Falta la configuración de seguridad del servidor');
  }

  return crypto
    .createHmac('sha256', base)
    .update('mi-ruta-cafetera:recuperacion-password:v1')
    .digest();
};

const huella = (tipo, ...partes) =>
  crypto
    .createHmac('sha256', claveHmac())
    .update(`${tipo}:${partes.join(':')}`)
    .digest('hex');

const huellaCodigo = (correo, codigo) =>
  huella('codigo', correo, codigo);

const huellaToken = (token) => huella('token', token);

const iguales = (guardada, calculada) => {
  if (
    typeof guardada !== 'string' ||
    typeof calculada !== 'string' ||
    guardada.length !== calculada.length
  ) {
    return false;
  }

  return crypto.timingSafeEqual(
    Buffer.from(guardada),
    Buffer.from(calculada)
  );
};

const normalizarCorreo = (valor) => {
  if (typeof valor !== 'string') {
    return null;
  }

  const correo = valor.trim().toLowerCase();

  if (
    correo.length === 0 ||
    correo.length > 254 ||
    !/^[^\s@]+@[^\s@]+$/.test(correo)
  ) {
    return null;
  }

  return correo;
};

const codigoValido = (valor) =>
  typeof valor === 'string' && /^\d{6}$/.test(valor.trim())
    ? valor.trim()
    : null;

const tokenValido = (valor) =>
  typeof valor === 'string' && /^[a-f0-9]{64}$/.test(valor)
    ? valor
    : null;

const passwordValida = (valor) =>
  typeof valor === 'string' &&
  valor.length >= PASSWORD_MIN &&
  Buffer.byteLength(valor, 'utf8') <= PASSWORD_MAX_BYTES;

// -----------------------------------------------------
// 1. SOLICITAR CÓDIGO
// -----------------------------------------------------

const recuperarPassword = async (req, res) => {
  const correo = normalizarCorreo(req.body?.correo);

  if (!correo) {
    return res.status(400).json({
      mensaje: 'Escribe un correo válido'
    });
  }

  try {
    const usuario = await Usuario.findOne({
      correo,
      eliminadoAt: null
    });

    if (usuario) {
      const codigo = crypto.randomInt(100000, 1000000).toString();

      await Usuario.updateOne(
        { _id: usuario._id },
        {
          $set: {
            codigoRecuperacion: huellaCodigo(correo, codigo),
            codigoRecuperacionExpiracion: new Date(
              Date.now() + VIGENCIA_MS
            ),
            tokenRecuperacion: null,
            tokenRecuperacionExpiracion: null
          }
        }
      );

      // El correo se envía sin esperar para que la respuesta
      // tarde lo mismo exista o no la cuenta.
      Promise.resolve()
        .then(() =>
          enviarCodigoRecuperacion(usuario.correo, usuario.nombre, codigo)
        )
        .catch((error) => {
          console.error(
            'No se pudo enviar el correo de recuperación:',
            error && error.message
          );
        });
    }

    return res.status(200).json({
      mensaje: MENSAJE_SOLICITUD
    });
  } catch (error) {
    console.error(
      'Error al solicitar recuperación de contraseña:',
      error && error.message
    );

    return res.status(500).json({
      mensaje: MENSAJE_ERROR
    });
  }
};

// -----------------------------------------------------
// 2. VERIFICAR CÓDIGO
// -----------------------------------------------------

const verificarCodigoRecuperacion = async (req, res) => {
  const correo = normalizarCorreo(req.body?.correo);
  const codigo = codigoValido(req.body?.codigo);

  if (!correo || !codigo) {
    return res.status(400).json({
      mensaje: 'Escribe tu correo y el código de 6 dígitos'
    });
  }

  try {
    const usuario = await Usuario.findOne({
      correo,
      eliminadoAt: null
    });

    const calculada = huellaCodigo(correo, codigo);

    const vigente =
      usuario &&
      usuario.codigoRecuperacion &&
      usuario.codigoRecuperacionExpiracion &&
      new Date(usuario.codigoRecuperacionExpiracion) >= new Date();

    if (!vigente || !iguales(usuario.codigoRecuperacion, calculada)) {
      return res.status(400).json({
        mensaje: MENSAJE_CODIGO_INVALIDO
      });
    }

    const tokenRecuperacion = crypto.randomBytes(32).toString('hex');

    // Consumo atómico del código: solo uno de dos intentos
    // simultáneos con el mismo código puede ganar.
    const resultado = await Usuario.updateOne(
      {
        _id: usuario._id,
        codigoRecuperacion: usuario.codigoRecuperacion
      },
      {
        $set: {
          tokenRecuperacion: huellaToken(tokenRecuperacion),
          tokenRecuperacionExpiracion: new Date(
            Date.now() + VIGENCIA_MS
          ),
          codigoRecuperacion: null,
          codigoRecuperacionExpiracion: null
        }
      }
    );

    if (!resultado || resultado.modifiedCount !== 1) {
      return res.status(400).json({
        mensaje: MENSAJE_CODIGO_INVALIDO
      });
    }

    return res.status(200).json({
      mensaje: 'Código verificado correctamente',
      tokenRecuperacion
    });
  } catch (error) {
    console.error(
      'Error al verificar código de recuperación:',
      error && error.message
    );

    return res.status(500).json({
      mensaje: MENSAJE_ERROR
    });
  }
};

// -----------------------------------------------------
// 3. RESTABLECER CONTRASEÑA
// -----------------------------------------------------

const restablecerPassword = async (req, res) => {
  const token = tokenValido(req.body?.tokenRecuperacion);
  const nuevaPassword = req.body?.nuevaPassword;

  if (!token) {
    return res.status(400).json({
      mensaje: MENSAJE_TOKEN_INVALIDO
    });
  }

  if (!passwordValida(nuevaPassword)) {
    return res.status(400).json({
      mensaje:
        `La contraseña debe tener entre ${PASSWORD_MIN} y 72 caracteres`
    });
  }

  try {
    const passwordEncriptada = await bcrypt.hash(nuevaPassword, 10);

    // Búsqueda y consumo del token en una sola operación
    // atómica: un token solo se puede usar una vez.
    const usuario = await Usuario.findOneAndUpdate(
      {
        tokenRecuperacion: huellaToken(token),
        tokenRecuperacionExpiracion: { $gt: new Date() },
        eliminadoAt: null
      },
      {
        $set: {
          password: passwordEncriptada,
          tokenRecuperacion: null,
          tokenRecuperacionExpiracion: null,
          codigoRecuperacion: null,
          codigoRecuperacionExpiracion: null
        }
      }
    );

    if (!usuario) {
      return res.status(400).json({
        mensaje: MENSAJE_TOKEN_INVALIDO
      });
    }

    return res.status(200).json({
      mensaje: 'Contraseña restablecida correctamente'
    });
  } catch (error) {
    console.error(
      'Error al restablecer contraseña:',
      error && error.message
    );

    return res.status(500).json({
      mensaje: MENSAJE_ERROR
    });
  }
};

module.exports = {
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword,
  // Solo para pruebas
  _huellaCodigo: huellaCodigo,
  _huellaToken: huellaToken
};
