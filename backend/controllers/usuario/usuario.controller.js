const bcrypt = require('bcryptjs');

const jwt = require('jsonwebtoken');

const crypto = require('crypto');

const mongoose = require('mongoose');

const { OAuth2Client } = require('google-auth-library');

const Usuario = require(
  '../../models/usuario/usuario'
);

// Modelos con datos del usuario, usados al eliminar la cuenta.
const Resena = require('../../models/sitio/resena');
const Reserva = require('../../models/sitio/reserva');
const Favorito = require('../../models/usuario/favorito');
const Ruta = require('../../models/usuario/ruta');
const Notificacion = require('../../models/usuario/notificacion');
const Ayuda = require('../../models/usuario/ayuda');
const Visita = require('../../models/usuario/visita');
const MapaOffline = require('../../models/usuario/mapaoffline');

const googleClient = new OAuth2Client(
  process.env.GOOGLE_CLIENT_ID
);

const {
  enviarCodigoVerificacion,
  enviarCodigoRecuperacion
} = require('../../utils/mailer');

// =====================================================
// AYUDAS COMUNES DEL PERFIL
// =====================================================

const CAMPOS_AVATAR = [
  'piel',
  'peinado',
  'colorPelo',
  'ropa',
  'sombrero',
  'accesorio',
  'fondo'
];

// Forma única con la que se devuelve el usuario al cliente.
// No incluye contraseña, códigos ni tokens de recuperación.
const usuarioPublico = (usuario) => {
  const avatar = usuario.avatar || {};

  return {
    id: usuario._id,
    nombre: usuario.nombre,
    apellido: usuario.apellido,
    correo: usuario.correo,
    telefono: usuario.telefono,
    ciudad: usuario.ciudad,
    fotoPerfil: usuario.fotoPerfil,
    avatar: {
      usar: avatar.usar === true,
      piel: avatar.piel,
      peinado: avatar.peinado,
      colorPelo: avatar.colorPelo,
      ropa: avatar.ropa,
      sombrero: avatar.sombrero,
      accesorio: avatar.accesorio,
      fondo: avatar.fondo
    }
  };
};

const esTextoSimple = (valor) =>
  typeof valor === 'string';

// Valida y normaliza los campos que el usuario puede editar.
// Devuelve { cambios, error }. Solo se aceptan los campos de
// la lista blanca; cualquier otro se ignora.
const validarCambiosPerfil = (cuerpo, usuarioActual) => {
  const cambios = {};
  const datos = cuerpo || {};

  // ---- nombre y apellido (obligatorios si se envían) ----
  for (const campo of ['nombre', 'apellido']) {
    if (datos[campo] === undefined) continue;

    if (!esTextoSimple(datos[campo])) {
      return { error: `El campo ${campo} no es válido` };
    }

    const valor = datos[campo].trim();

    if (valor.length < 1 || valor.length > 60) {
      return {
        error:
          `El ${campo} debe tener entre 1 y 60 caracteres`
      };
    }

    cambios[campo] = valor;
  }

  // ---- teléfono (opcional) ----
  if (datos.telefono !== undefined) {
    if (!esTextoSimple(datos.telefono)) {
      return { error: 'El teléfono no es válido' };
    }

    const valor = datos.telefono.trim();

    if (
      valor !== '' &&
      !/^[0-9+()\-\s]{7,20}$/.test(valor)
    ) {
      return {
        error:
          'El teléfono solo puede tener números, espacios, + ( ) y -, entre 7 y 20 caracteres'
      };
    }

    cambios.telefono = valor;
  }

  // ---- ciudad (opcional) ----
  if (datos.ciudad !== undefined) {
    if (!esTextoSimple(datos.ciudad)) {
      return { error: 'La ciudad no es válida' };
    }

    const valor = datos.ciudad.trim();

    if (valor.length > 60) {
      return {
        error: 'La ciudad no puede superar 60 caracteres'
      };
    }

    cambios.ciudad = valor;
  }

  // ---- fotografía (URL http/https o vacío) ----
  if (datos.fotoPerfil !== undefined) {
    if (!esTextoSimple(datos.fotoPerfil)) {
      return { error: 'La fotografía no es válida' };
    }

    const valor = datos.fotoPerfil.trim();

    if (valor !== '') {
      let url;

      try {
        url = new URL(valor);
      } catch (_) {
        return { error: 'La fotografía no es una URL válida' };
      }

      if (
        !['http:', 'https:'].includes(url.protocol) ||
        valor.length > 500
      ) {
        return { error: 'La fotografía no es una URL válida' };
      }
    }

    cambios.fotoPerfil = valor;
  }

  // ---- avatar cafetero ----
  if (datos.avatar !== undefined) {
    const avatar = datos.avatar;

    if (
      avatar === null ||
      typeof avatar !== 'object' ||
      Array.isArray(avatar)
    ) {
      return { error: 'El avatar no es válido' };
    }

    const opciones = Usuario.AVATAR_OPCIONES;
    const avatarActual =
      (usuarioActual && usuarioActual.avatar) || {};

    const resultado = {};

    for (const campo of CAMPOS_AVATAR) {
      if (avatar[campo] === undefined) {
        resultado[campo] = avatarActual[campo];
        continue;
      }

      if (!opciones[campo].includes(avatar[campo])) {
        return {
          error: `La opción de avatar "${campo}" no es válida`
        };
      }

      resultado[campo] = avatar[campo];
    }

    if (avatar.usar !== undefined) {
      if (typeof avatar.usar !== 'boolean') {
        return { error: 'El avatar no es válido' };
      }

      resultado.usar = avatar.usar;
    } else {
      resultado.usar = avatarActual.usar === true;
    }

    // Para usar el avatar, la configuración debe estar completa.
    if (
      resultado.usar &&
      CAMPOS_AVATAR.some((campo) => !resultado[campo])
    ) {
      return {
        error:
          'El avatar está incompleto. Elige todas las opciones antes de guardarlo'
      };
    }

    cambios.avatar = resultado;
  }

  if (Object.keys(cambios).length === 0) {
    return { error: 'No hay cambios válidos para guardar' };
  }

  return { cambios };
};

// =====================================================
// REGISTRAR USUARIO
// =====================================================

const registrarUsuario = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      correo,
      password,
      telefono,
      ciudad,
      fotoPerfil
    } = req.body;

    // -------------------------------------------------
    // VALIDAR CAMPOS OBLIGATORIOS
    // -------------------------------------------------

    if (
      !nombre ||
      !apellido ||
      !correo ||
      !password
    ) {
      return res.status(400).json({
        mensaje:
          'Nombre, apellido, correo y contraseña son obligatorios'
      });
    }

    // -------------------------------------------------
    // NORMALIZAR CORREO
    // -------------------------------------------------

    const correoNormalizado =
      correo.toLowerCase().trim();

    // -------------------------------------------------
    // VERIFICAR SI EL CORREO YA EXISTE
    // -------------------------------------------------

    const usuarioExistente =
      await Usuario.findOne({
        correo: correoNormalizado
      });

    if (usuarioExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    // -------------------------------------------------
    // ENCRIPTAR CONTRASEÑA
    // -------------------------------------------------

    const passwordEncriptada =
      await bcrypt.hash(
        password,
        10
      );

    // -------------------------------------------------
    // GENERAR CÓDIGO DE VERIFICACIÓN
    // -------------------------------------------------

    const codigoVerificacion =
      crypto.randomInt(
        100000,
        1000000
      ).toString();

    const codigoVerificacionExpiracion =
      new Date(
        Date.now() +
        10 * 60 * 1000
      );

    // -------------------------------------------------
    // CREAR USUARIO
    // -------------------------------------------------

    const usuario = new Usuario({
      nombre,
      apellido,
      correo: correoNormalizado,
      password: passwordEncriptada,
      telefono,
      ciudad,
      fotoPerfil,

      correoVerificado: false,

      codigoVerificacion,

      codigoVerificacionExpiracion
    });

    await usuario.save();

    // -------------------------------------------------
    // ENVIAR CÓDIGO POR CORREO
    // -------------------------------------------------

    await enviarCodigoVerificacion(
      usuario.correo,
      usuario.nombre,
      codigoVerificacion
    );

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(201).json({
      mensaje:
        'Usuario registrado correctamente. Revisa tu correo para verificar tu cuenta.',

      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        correo: usuario.correo,
        telefono: usuario.telefono,
        ciudad: usuario.ciudad,
        fotoPerfil: usuario.fotoPerfil,
        correoVerificado:
          usuario.correoVerificado
      }
    });
  } catch (error) {
    console.error(
      'Error al registrar usuario:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al registrar usuario',
      error: error.message
    });
  }
};

// =====================================================
// VERIFICAR CORREO
// =====================================================

const verificarCorreo = async (req, res) => {
  try {
    const {
      correo,
      codigo
    } = req.body;

    // -------------------------------------------------
    // VALIDAR DATOS
    // -------------------------------------------------

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje:
          'Correo y código son obligatorios'
      });
    }

    // -------------------------------------------------
    // NORMALIZAR CORREO
    // -------------------------------------------------

    const correoNormalizado =
      correo.toLowerCase().trim();

    // -------------------------------------------------
    // BUSCAR USUARIO
    // -------------------------------------------------

    const usuario =
      await Usuario.findOne({
        correo: correoNormalizado
      });

    if (!usuario) {
      return res.status(404).json({
        mensaje:
          'Usuario no encontrado'
      });
    }

    // -------------------------------------------------
    // VERIFICAR SI YA ESTÁ VERIFICADO
    // -------------------------------------------------

    if (
      usuario.correoVerificado === true ||
      usuario.isVerified === true
    ) {
      return res.status(400).json({
        mensaje:
          'El correo ya está verificado'
      });
    }

    // -------------------------------------------------
    // VERIFICAR CÓDIGO
    // -------------------------------------------------

    if (
      usuario.codigoVerificacion !==
      codigo
    ) {
      return res.status(400).json({
        mensaje:
          'El código de verificación es incorrecto'
      });
    }

    // -------------------------------------------------
    // VERIFICAR EXPIRACIÓN
    // -------------------------------------------------

    if (
      !usuario.codigoVerificacionExpiracion ||
      usuario.codigoVerificacionExpiracion <
        new Date()
    ) {
      return res.status(400).json({
        mensaje:
          'El código de verificación ha expirado'
      });
    }

    // -------------------------------------------------
    // CONFIRMAR CORREO
    // -------------------------------------------------

    usuario.correoVerificado = true;

    usuario.codigoVerificacion = null;

    usuario.codigoVerificacionExpiracion = null;

    await usuario.save();

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Correo verificado correctamente'
    });
  } catch (error) {
    console.error(
      'Error al verificar correo:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al verificar el correo',
      error: error.message
    });
  }
};

// =====================================================
// INICIAR SESIÓN
// =====================================================

const iniciarSesionUsuario = async (req, res) => {
  try {
    const {
      correo,
      password
    } = req.body;

    // -------------------------------------------------
    // VALIDAR CAMPOS
    // -------------------------------------------------

    if (!correo || !password) {
      return res.status(400).json({
        mensaje:
          'Correo y contraseña son obligatorios'
      });
    }

    // -------------------------------------------------
    // NORMALIZAR CORREO
    // -------------------------------------------------

    const correoNormalizado =
      correo.toLowerCase().trim();

    // -------------------------------------------------
    // BUSCAR USUARIO
    // -------------------------------------------------

    const usuario =
      await Usuario
        .findOne({
          correo: correoNormalizado
        })
        .select('+password');

    if (!usuario) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    // -------------------------------------------------
    // VERIFICAR CORREO
    // -------------------------------------------------

    const correoEstaVerificado =
      usuario.correoVerificado === true ||
      usuario.isVerified === true;

    if (!correoEstaVerificado) {
      return res.status(403).json({
        mensaje:
          'Debes verificar tu correo antes de iniciar sesión'
      });
    }

    // -------------------------------------------------
    // COMPARAR CONTRASEÑA
    // -------------------------------------------------

    const passwordCorrecta =
      await bcrypt.compare(
        password,
        usuario.password
      );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    // -------------------------------------------------
    // CREAR JWT
    // -------------------------------------------------

    const token =
      jwt.sign(
        {
          id: usuario._id.toString(),
          correo: usuario.correo,
          rol: 'usuario'
        },
        process.env.JWT_SECRET,
        {
          expiresIn:
            process.env.JWT_EXPIRES_IN || '1d'
        }
      );

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Inicio de sesión exitoso',

      token,

      usuario: usuarioPublico(usuario)
    });
  } catch (error) {
    console.error(
      'Error al iniciar sesión:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al iniciar sesión',
      error: error.message
    });
  }
};

// =====================================================
// RECUPERAR CONTRASEÑA
// =====================================================

const recuperarPassword = async (req, res) => {
  try {
    const { correo } = req.body;

    // -------------------------------------------------
    // VALIDAR CORREO
    // -------------------------------------------------

    if (!correo) {
      return res.status(400).json({
        mensaje:
          'El correo es obligatorio'
      });
    }

    // -------------------------------------------------
    // NORMALIZAR CORREO
    // -------------------------------------------------

    const correoNormalizado =
      correo.toLowerCase().trim();

    // -------------------------------------------------
    // BUSCAR USUARIO
    // -------------------------------------------------

    const usuario =
      await Usuario.findOne({
        correo: correoNormalizado
      });

    if (!usuario) {
      return res.status(404).json({
        mensaje:
          'No existe un usuario registrado con ese correo'
      });
    }

    // -------------------------------------------------
    // GENERAR CÓDIGO
    // -------------------------------------------------

    const codigoRecuperacion =
      crypto.randomInt(
        100000,
        1000000
      ).toString();

    const codigoRecuperacionExpiracion =
      new Date(
        Date.now() +
        10 * 60 * 1000
      );

    // -------------------------------------------------
    // GUARDAR CÓDIGO
    // -------------------------------------------------

    usuario.codigoRecuperacion =
      codigoRecuperacion;

    usuario.codigoRecuperacionExpiracion =
      codigoRecuperacionExpiracion;

    usuario.tokenRecuperacion = null;

    usuario.tokenRecuperacionExpiracion =
      null;

    await usuario.save();

    // -------------------------------------------------
    // ENVIAR CÓDIGO
    // -------------------------------------------------

    await enviarCodigoRecuperacion(
      usuario.correo,
      usuario.nombre,
      codigoRecuperacion
    );

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Hemos enviado un código de recuperación a tu correo'
    });
  } catch (error) {
    console.error(
      'Error al recuperar contraseña:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al solicitar recuperación de contraseña',
      error: error.message
    });
  }
};

// =====================================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// =====================================================

const verificarCodigoRecuperacion =
  async (req, res) => {
    try {
      const {
        correo,
        codigo
      } = req.body;

      // ------------------------------------------------
      // VALIDAR DATOS
      // ------------------------------------------------

      if (!correo || !codigo) {
        return res.status(400).json({
          mensaje:
            'Correo y código son obligatorios'
        });
      }

      // ------------------------------------------------
      // NORMALIZAR CORREO
      // ------------------------------------------------

      const correoNormalizado =
        correo.toLowerCase().trim();

      // ------------------------------------------------
      // BUSCAR USUARIO
      // ------------------------------------------------

      const usuario =
        await Usuario.findOne({
          correo: correoNormalizado
        });

      if (!usuario) {
        return res.status(404).json({
          mensaje:
            'Usuario no encontrado'
        });
      }

      // ------------------------------------------------
      // VERIFICAR CÓDIGO
      // ------------------------------------------------

      if (
        usuario.codigoRecuperacion !==
        codigo
      ) {
        return res.status(400).json({
          mensaje:
            'El código de recuperación es incorrecto'
        });
      }

      // ------------------------------------------------
      // VERIFICAR EXPIRACIÓN
      // ------------------------------------------------

      if (
        !usuario.codigoRecuperacionExpiracion ||
        usuario.codigoRecuperacionExpiracion <
          new Date()
      ) {
        return res.status(400).json({
          mensaje:
            'El código de recuperación ha expirado'
        });
      }

      // ------------------------------------------------
      // GENERAR TOKEN
      // ------------------------------------------------

      const tokenRecuperacion =
        crypto.randomBytes(32).toString(
          'hex'
        );

      const tokenRecuperacionExpiracion =
        new Date(
          Date.now() +
          10 * 60 * 1000
        );

      // ------------------------------------------------
      // GUARDAR TOKEN
      // ------------------------------------------------

      usuario.tokenRecuperacion =
        tokenRecuperacion;

      usuario.tokenRecuperacionExpiracion =
        tokenRecuperacionExpiracion;

      usuario.codigoRecuperacion = null;

      usuario.codigoRecuperacionExpiracion =
        null;

      await usuario.save();

      // ------------------------------------------------
      // RESPUESTA
      // ------------------------------------------------

      return res.status(200).json({
        mensaje:
          'Código verificado correctamente',

        tokenRecuperacion
      });
    } catch (error) {
      console.error(
        'Error al verificar código de recuperación:',
        error
      );

      return res.status(500).json({
        mensaje:
          'Error al verificar el código',
        error: error.message
      });
    }
  };

// =====================================================
// RESTABLECER CONTRASEÑA
// =====================================================

const restablecerPassword =
  async (req, res) => {
    try {
      const {
        tokenRecuperacion,
        nuevaPassword
      } = req.body;

      // ------------------------------------------------
      // VALIDAR DATOS
      // ------------------------------------------------

      if (
        !tokenRecuperacion ||
        !nuevaPassword
      ) {
        return res.status(400).json({
          mensaje:
            'Token y nueva contraseña son obligatorios'
        });
      }

      // ------------------------------------------------
      // BUSCAR USUARIO
      // ------------------------------------------------

      const usuario =
        await Usuario.findOne({
          tokenRecuperacion
        });

      if (!usuario) {
        return res.status(400).json({
          mensaje:
            'El token de recuperación no es válido'
        });
      }

      // ------------------------------------------------
      // VERIFICAR EXPIRACIÓN
      // ------------------------------------------------

      if (
        !usuario.tokenRecuperacionExpiracion ||
        usuario.tokenRecuperacionExpiracion <
          new Date()
      ) {
        return res.status(400).json({
          mensaje:
            'El token de recuperación ha expirado'
        });
      }

      // ------------------------------------------------
      // ENCRIPTAR NUEVA CONTRASEÑA
      // ------------------------------------------------

      usuario.password =
        await bcrypt.hash(
          nuevaPassword,
          10
        );

      // ------------------------------------------------
      // LIMPIAR TOKEN
      // ------------------------------------------------

      usuario.tokenRecuperacion = null;

      usuario.tokenRecuperacionExpiracion =
        null;

      await usuario.save();

      // ------------------------------------------------
      // RESPUESTA
      // ------------------------------------------------

      return res.status(200).json({
        mensaje:
          'Contraseña restablecida correctamente'
      });
    } catch (error) {
      console.error(
        'Error al restablecer contraseña:',
        error
      );

      return res.status(500).json({
        mensaje:
          'Error al restablecer la contraseña',
        error: error.message
      });
    }
  };

  // =====================================================
// OBTENER MI PERFIL
// =====================================================

const obtenerMiPerfil = async (req, res) => {
  try {
    if (req.usuario.rol !== 'usuario') {
      return res.status(403).json({
        mensaje: 'No tienes permisos para esta acción'
      });
    }

    // La contraseña se carga solo para saber si la cuenta
    // se creó con Google; nunca se envía al cliente.
    const usuario = await Usuario
      .findById(req.usuario.id)
      .select('+password');

    if (!usuario || usuario.eliminadoAt) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    return res.status(200).json({
      usuario: {
        ...usuarioPublico(usuario),
        cuentaGoogle: esCuentaGoogle(usuario)
      }
    });
  } catch (error) {
    console.error(
      'Error al obtener mi perfil:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener el perfil'
    });
  }
};

// =====================================================
// ACTUALIZAR USUARIO
// =====================================================
//
// Solo permite modificar la propia cuenta y únicamente los
// campos de la lista blanca (nombre, apellido, teléfono,
// ciudad, fotografía y avatar). El correo, la contraseña y
// los datos de verificación no se pueden cambiar aquí.
// =====================================================

const actualizarUsuario = async (
  req,
  res
) => {
  try {
    // -------------------------------------------------
    // VERIFICAR PROPIETARIO
    // -------------------------------------------------

    if (
      req.usuario.rol !== 'usuario' ||
      req.usuario.id !== req.params.id
    ) {
      return res.status(403).json({
        mensaje:
          'No puedes modificar otro usuario'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador de usuario no válido'
      });
    }

    const usuario = await Usuario.findById(req.params.id);

    if (!usuario || usuario.eliminadoAt) {
      return res.status(404).json({
        mensaje:
          'Usuario no encontrado'
      });
    }

    // -------------------------------------------------
    // VALIDAR CAMBIOS
    // -------------------------------------------------

    const { cambios, error } = validarCambiosPerfil(
      req.body,
      usuario
    );

    if (error) {
      return res.status(400).json({ mensaje: error });
    }

    // -------------------------------------------------
    // GUARDAR
    // -------------------------------------------------

    usuario.set(cambios);

    await usuario.save();

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Perfil actualizado correctamente',

      usuario: usuarioPublico(usuario)
    });
  } catch (error) {
    console.error(
      'Error al actualizar usuario:',
      error
    );

    if (error.name === 'ValidationError') {
      return res.status(400).json({
        mensaje: 'Los datos enviados no son válidos'
      });
    }

    return res.status(500).json({
      mensaje:
        'Error al actualizar el perfil'
    });
  }
};

// =====================================================
// ELIMINAR CUENTA
// =====================================================
//
// DELETE /api/usuarios/:id
//
// Qué hace, según las relaciones reales de los modelos:
//
//   - Reseñas (y sus comentarios): BORRADO DEFINITIVO.
//   - Favoritos, rutas, notificaciones, reportes de ayuda,
//     visitas y mapas offline: BORRADO DEFINITIVO.
//   - Reservas: si hay alguna ACTIVA o FUTURA (estado
//     pendiente o confirmada con fecha de hoy en adelante)
//     la eliminación se BLOQUEA (409) y no se toca nada.
//     Las reservas pasadas se conservan como registro de
//     operación, sin texto libre y sin datos personales.
//   - Usuario: el documento queda como "lápida" anonimizada
//     (sin datos personales, con eliminadoAt) para que las
//     reservas conservadas no queden huérfanas.
//
// Exige confirmación explícita (`confirmar: true`) y
// comprobar la identidad:
//   - cuentas con contraseña  -> body.password
//   - cuentas de Google       -> body.idToken reciente
//
// Los JWT emitidos antes de eliminar la cuenta dejan de ser
// válidos: verificarToken comprueba que el usuario exista y
// no tenga eliminadoAt. La cuenta eliminada no puede volver a
// iniciar sesión (su correo ya no existe). Quien se registre
// de nuevo con ese correo obtiene una cuenta nueva y vacía.
//
// Consistencia: todo ocurre en una transacción cuando el
// servidor la permite. Sin transacciones, el documento del
// usuario se anonimiza al FINAL: si algo falla antes, la
// cuenta sigue activa y se puede reintentar (los borrados
// son idempotentes).
// =====================================================

const MAX_EDAD_ID_TOKEN_SEGUNDOS = 10 * 60;

const esCuentaGoogle = (usuario) =>
  typeof usuario.password === 'string' &&
  usuario.password.startsWith('GOOGLE_');

const comprobarIdentidad = async (usuario, cuerpo) => {
  const datos = cuerpo || {};

  if (esCuentaGoogle(usuario)) {
    if (typeof datos.idToken !== 'string' || !datos.idToken) {
      return {
        codigo: 401,
        mensaje:
          'Confirma tu identidad con Google para eliminar la cuenta'
      };
    }

    let payload;

    try {
      const ticket = await googleClient.verifyIdToken({
        idToken: datos.idToken,
        audience: process.env.GOOGLE_CLIENT_ID
      });

      payload = ticket.getPayload();
    } catch (_) {
      return {
        codigo: 401,
        mensaje: 'No se pudo confirmar tu identidad con Google'
      };
    }

    const ahora = Math.floor(Date.now() / 1000);

    if (
      !payload ||
      !payload.email ||
      payload.email_verified !== true ||
      payload.email.toLowerCase().trim() !== usuario.correo ||
      !payload.iat ||
      ahora - payload.iat > MAX_EDAD_ID_TOKEN_SEGUNDOS
    ) {
      return {
        codigo: 401,
        mensaje:
          'No se pudo confirmar tu identidad. Vuelve a iniciar sesión con Google e inténtalo de nuevo'
      };
    }

    return null;
  }

  if (typeof datos.password !== 'string' || !datos.password) {
    return {
      codigo: 401,
      mensaje:
        'Escribe tu contraseña para eliminar la cuenta'
    };
  }

  const coincide = await bcrypt.compare(
    datos.password,
    usuario.password
  );

  if (!coincide) {
    return {
      codigo: 401,
      mensaje: 'La contraseña es incorrecta'
    };
  }

  return null;
};

const ESTADOS_RESERVA_ACTIVA = ['pendiente', 'confirmada'];

const inicioDeHoy = () => {
  const hoy = new Date();
  hoy.setHours(0, 0, 0, 0);
  return hoy;
};

// Reservas que impiden eliminar la cuenta: activas o futuras.
const contarReservasActivas = (usuarioId, sesion) =>
  Reserva.countDocuments({
    usuario: usuarioId,
    estado: { $in: ESTADOS_RESERVA_ACTIVA },
    fecha: { $gte: inicioDeHoy() }
  }).session(sesion || null);

class ReservasActivasError extends Error {
  constructor(cantidad) {
    super('RESERVAS_ACTIVAS');
    this.cantidad = cantidad;
  }
}

const respuestaReservasActivas = (res, cantidad) =>
  res.status(409).json({
    mensaje:
      'No puedes eliminar tu cuenta mientras tengas reservas ' +
      'activas o próximas. Cancélalas o espera a que se ' +
      'completen y vuelve a intentarlo.',
    reservasActivas: cantidad
  });

const eliminarDatosYAnonimizar = async (usuario, sesion) => {
  const opciones = sesion ? { session: sesion } : {};
  const id = usuario._id;

  // Se vuelve a comprobar dentro de la transacción.
  const activas = await contarReservasActivas(id, sesion);

  if (activas > 0) {
    throw new ReservasActivasError(activas);
  }

  // Reseñas y comentarios: borrado definitivo.
  await Resena.deleteMany({ usuario: id }, opciones);

  // Información privada: se elimina.
  await Favorito.deleteMany({ usuario: id }, opciones);
  await Ruta.deleteMany({ usuario: id }, opciones);
  await Notificacion.deleteMany({ usuario: id }, opciones);
  await Ayuda.deleteMany({ usuarioId: id }, opciones);
  await Visita.deleteMany({ usuario: id }, opciones);
  await MapaOffline.deleteMany({ usuario: id }, opciones);

  // Reservas pasadas: se conservan como registro de operación,
  // sin texto libre que pudiera contener datos personales.
  await Reserva.updateMany(
    { usuario: id },
    { $set: { observaciones: '' } },
    opciones
  );

  // El documento del usuario queda anonimizado para que ya no
  // identifique a la persona y las reservas no queden huérfanas.
  const passwordInutilizable = await bcrypt.hash(
    crypto.randomBytes(32).toString('hex'),
    10
  );

  usuario.nombre = 'Usuario';
  usuario.apellido = 'eliminado';
  usuario.correo = `eliminado-${id.toString()}@anonimo.invalid`;
  usuario.password = passwordInutilizable;
  usuario.telefono = '';
  usuario.ciudad = '';
  usuario.fotoPerfil = '';
  usuario.avatar = { usar: false };
  usuario.correoVerificado = false;
  usuario.codigoVerificacion = null;
  usuario.codigoVerificacionExpiracion = null;
  usuario.codigoRecuperacion = null;
  usuario.codigoRecuperacionExpiracion = null;
  usuario.tokenRecuperacion = null;
  usuario.tokenRecuperacionExpiracion = null;
  usuario.activo = false;
  usuario.eliminadoAt = new Date();

  await usuario.save(opciones);
};

const eliminarUsuario = async (
  req,
  res
) => {
  try {
    // -------------------------------------------------
    // VERIFICAR PROPIETARIO
    // -------------------------------------------------

    if (
      req.usuario.rol !== 'usuario' ||
      req.usuario.id !== req.params.id
    ) {
      return res.status(403).json({
        mensaje:
          'No puedes eliminar otro usuario'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador de usuario no válido'
      });
    }

    const usuario = await Usuario
      .findById(req.params.id)
      .select('+password');

    if (!usuario || usuario.eliminadoAt) {
      return res.status(404).json({
        mensaje:
          'Usuario no encontrado'
      });
    }

    // -------------------------------------------------
    // CONFIRMACIÓN EXPLÍCITA
    // -------------------------------------------------

    if (!req.body || req.body.confirmar !== true) {
      return res.status(400).json({
        mensaje:
          'Debes confirmar de forma explícita que quieres eliminar tu cuenta'
      });
    }

    // -------------------------------------------------
    // COMPROBAR IDENTIDAD
    // -------------------------------------------------

    const fallo = await comprobarIdentidad(
      usuario,
      req.body
    );

    if (fallo) {
      return res.status(fallo.codigo).json({
        mensaje: fallo.mensaje
      });
    }

    // -------------------------------------------------
    // RESERVAS ACTIVAS O FUTURAS: BLOQUEAN LA ELIMINACIÓN
    // -------------------------------------------------

    const reservasActivas = await contarReservasActivas(
      usuario._id,
      null
    );

    if (reservasActivas > 0) {
      return respuestaReservasActivas(res, reservasActivas);
    }

    // -------------------------------------------------
    // ELIMINAR Y ANONIMIZAR (en transacción si el servidor lo permite)
    // -------------------------------------------------

    const sesion = await mongoose.startSession();

    try {
      await sesion.withTransaction(async () => {
        await eliminarDatosYAnonimizar(usuario, sesion);
      });
    } catch (errorTransaccion) {
      const sinTransacciones =
        /replica set|Transaction numbers/i.test(
          String(errorTransaccion && errorTransaccion.message)
        );

      if (!sinTransacciones) {
        throw errorTransaccion;
      }

      // Servidor sin transacciones: se ejecuta sin sesión.
      const recargado = await Usuario
        .findById(req.params.id)
        .select('+password');

      await eliminarDatosYAnonimizar(recargado, null);
    } finally {
      await sesion.endSession();
    }

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Tu cuenta fue eliminada: tus reseñas y tus datos personales se borraron'
    });
  } catch (error) {
    if (error instanceof ReservasActivasError) {
      return respuestaReservasActivas(res, error.cantidad);
    }

    console.error(
      'Error al eliminar usuario:',
      error
    );

    return res.status(500).json({
      mensaje:
        'No se pudo completar la eliminación. Tu cuenta sigue activa; inténtalo de nuevo'
    });
  }
};

// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  registrarUsuario,
  verificarCorreo,
  iniciarSesionUsuario,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword,
  obtenerMiPerfil,
  actualizarUsuario,
  eliminarUsuario,
  usuarioPublico
};
