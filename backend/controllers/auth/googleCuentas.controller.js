// ======================================================
// INICIO DE SESIÓN CON GOOGLE: ADMINISTRADORES Y SITIOS
// ======================================================
//
// Reutiliza la misma configuración de Google que el login de
// usuarios (GOOGLE_CLIENT_ID) y emite el MISMO tipo de JWT que el
// login tradicional de cada rol, por lo que el resto del sistema
// (verificarToken, verificarAdministrador, verificarSitio) no
// cambia.
//
// Reglas de seguridad:
//
// - El idToken se valida SIEMPRE en el servidor (firma, audiencia
//   y expiración) y el correo de Google debe estar verificado.
// - NUNCA se crean cuentas ni privilegios: solo entra quien ya
//   tiene una cuenta de ese rol creada por el flujo existente.
// - La cuenta se identifica primero por el identificador estable
//   de Google ("sub"). Si todavía no está vinculada, se vincula en
//   el primer acceso solo cuando el correo VERIFICADO de Google
//   coincide con el de una cuenta activa del mismo rol. Una vez
//   vinculada, otra cuenta de Google con el mismo correo NO entra.
// - Se respetan las mismas comprobaciones del login tradicional
//   (cuenta activa y, en administradores, correo verificado).
// - Los errores internos no se devuelven al cliente.
// ======================================================

const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');

const Administrador = require('../../models/admin/administrador');
const CuentaSitio = require('../../models/sitio/auth');

let clienteGoogle = null;

const obtenerClienteGoogle = () => {
  if (!clienteGoogle) {
    clienteGoogle = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
  }
  return clienteGoogle;
};

// Valida el idToken y devuelve la identidad verificada de Google.
// Lanza un error con `estado` y `mensaje` para el cliente.
const verificarIdTokenGoogle = async (idToken) => {
  const falla = (estado, mensaje) => {
    const error = new Error(mensaje);
    error.estado = estado;
    error.paraCliente = true;
    return error;
  };

  if (
    typeof idToken !== 'string' ||
    idToken.trim().length === 0 ||
    idToken.length > 8192
  ) {
    throw falla(400, 'No se proporcionó el token de Google');
  }

  if (!process.env.GOOGLE_CLIENT_ID) {
    console.error('GOOGLE_CLIENT_ID no está configurado.');
    throw falla(500, 'El inicio de sesión con Google no está disponible');
  }

  let payload;

  try {
    const ticket = await obtenerClienteGoogle().verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID
    });
    payload = ticket.getPayload();
  } catch (error) {
    console.error('Token de Google inválido:', error.message);
    throw falla(401, 'No se pudo validar la identidad con Google');
  }

  if (!payload || !payload.sub) {
    throw falla(401, 'No se pudo obtener la información de Google');
  }

  if (!payload.email) {
    throw falla(400, 'La cuenta de Google no proporciona un correo');
  }

  if (payload.email_verified !== true) {
    throw falla(401, 'El correo de Google no está verificado');
  }

  return {
    sub: String(payload.sub),
    email: String(payload.email).toLowerCase().trim()
  };
};

// Busca la cuenta del rol. Nunca crea cuentas.
const resolverCuenta = async (Modelo, identidad) => {
  const porGoogle = await Modelo.findOne({ googleId: identidad.sub });

  if (porGoogle) {
    return { cuenta: porGoogle, vincular: false };
  }

  const porCorreo = await Modelo.findOne({ correo: identidad.email });

  if (!porCorreo) {
    return { error: 'no_autorizada' };
  }

  if (porCorreo.googleId && porCorreo.googleId !== identidad.sub) {
    return { error: 'otra_cuenta_google' };
  }

  return { cuenta: porCorreo, vincular: true };
};

// Guarda el googleId solo si la cuenta sigue sin vincular.
const vincularGoogle = async (Modelo, cuenta, sub) => {
  const resultado = await Modelo.updateOne(
    {
      _id: cuenta._id,
      $or: [{ googleId: { $exists: false } }, { googleId: null }]
    },
    { $set: { googleId: sub } }
  );

  return (resultado.matchedCount ?? resultado.n ?? 0) === 1;
};

const responderError = (res, error, accion) => {
  if (error && error.paraCliente) {
    return res.status(error.estado).json({ mensaje: error.message });
  }

  console.error(`Error al ${accion}:`, error);

  return res.status(500).json({
    mensaje: `Error al ${accion}`
  });
};

// Flujo común a ambos roles.
const autenticarConGoogle = async ({
  req,
  res,
  Modelo,
  etiquetaRol,
  validarEstado,
  construirRespuesta,
  accion
}) => {
  try {
    const identidad = await verificarIdTokenGoogle(req.body?.idToken);
    const resultado = await resolverCuenta(Modelo, identidad);

    if (resultado.error === 'no_autorizada') {
      return res.status(403).json({
        mensaje:
          `No hay una cuenta de ${etiquetaRol} autorizada ` +
          'para este correo de Google'
      });
    }

    if (resultado.error === 'otra_cuenta_google') {
      return res.status(403).json({
        mensaje: 'Esta cuenta ya está vinculada a otra cuenta de Google'
      });
    }

    const { cuenta, vincular } = resultado;

    const mensajeEstado = validarEstado(cuenta);

    if (mensajeEstado) {
      return res.status(403).json({ mensaje: mensajeEstado });
    }

    if (vincular) {
      let vinculada = false;

      try {
        vinculada = await vincularGoogle(Modelo, cuenta, identidad.sub);
      } catch (error) {
        if (error && error.code === 11000) {
          return res.status(409).json({
            mensaje: 'Esta cuenta de Google ya está vinculada a otra cuenta'
          });
        }
        throw error;
      }

      if (!vinculada) {
        return res.status(409).json({
          mensaje: 'La cuenta cambió durante el acceso. Inténtalo de nuevo'
        });
      }
    }

    return res.status(200).json(construirRespuesta(cuenta));
  } catch (error) {
    return responderError(res, error, accion);
  }
};

// POST /api/admin/administradores/login-google
const loginAdministradorConGoogle = (req, res) =>
  autenticarConGoogle({
    req,
    res,
    Modelo: Administrador,
    etiquetaRol: 'administrador',
    accion: 'iniciar sesión de administrador con Google',
    validarEstado: (administrador) => {
      if (!administrador.activo) {
        return 'La cuenta del administrador está inactiva';
      }
      if (!administrador.isVerified) {
        return 'Debes verificar tu correo antes de iniciar sesión';
      }
      return null;
    },
    construirRespuesta: (administrador) => {
      const token = jwt.sign(
        {
          id: administrador._id.toString(),
          correo: administrador.correo,
          rol: 'admin'
        },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
      );

      return {
        mensaje: 'Inicio de sesión de administrador exitoso',
        token,
        administrador: {
          id: administrador._id,
          nombre: administrador.nombre,
          apellido: administrador.apellido,
          correo: administrador.correo,
          telefono: administrador.telefono,
          activo: administrador.activo,
          isVerified: administrador.isVerified,
          rol: 'admin'
        }
      };
    }
  });

// POST /api/sitios/auth/login-google
const loginSitioConGoogle = (req, res) =>
  autenticarConGoogle({
    req,
    res,
    Modelo: CuentaSitio,
    etiquetaRol: 'sitio turístico',
    accion: 'iniciar sesión del sitio con Google',
    validarEstado: (cuenta) =>
      cuenta.activo ? null : 'La cuenta del sitio está inactiva',
    construirRespuesta: (cuenta) => {
      const token = jwt.sign(
        {
          id: cuenta._id.toString(),
          sitioId: cuenta.sitioId.toString(),
          correo: cuenta.correo,
          rol: 'sitio'
        },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      return {
        mensaje: 'Inicio de sesión del sitio exitoso',
        token,
        cuenta: {
          id: cuenta._id.toString(),
          sitioId: cuenta.sitioId.toString(),
          nombre: cuenta.nombre,
          apellido: cuenta.apellido,
          correo: cuenta.correo,
          telefono: cuenta.telefono,
          rol: 'sitio',
          activo: cuenta.activo
        }
      };
    }
  });

module.exports = {
  loginAdministradorConGoogle,
  loginSitioConGoogle,
  verificarIdTokenGoogle
};
