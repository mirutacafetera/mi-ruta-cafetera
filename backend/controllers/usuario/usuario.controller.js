const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const mongoose = require('mongoose');
const { OAuth2Client } = require('google-auth-library');
const Usuario = require('../../models/usuario/usuario');
const Resena = require('../../models/sitio/resena');
const Reserva = require('../../models/sitio/reserva');
const Favorito = require('../../models/usuario/favorito');
const Ruta = require('../../models/usuario/ruta');
const Notificacion = require('../../models/usuario/notificacion');
const Ayuda = require('../../models/usuario/ayuda');
const Visita = require('../../models/usuario/visita');
const MapaOffline = require('../../models/usuario/mapaoffline');
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
const {
  enviarCodigoVerificacion,
  enviarCodigoRecuperacion
} = require('../../utils/mailer');

const CAMPOS_AVATAR = [
  'piel',
  'peinado',
  'colorPelo',
  'ropa',
  'sombrero',
  'accesorio',
  'fondo'
];

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

const esTextoSimple = (valor) => typeof valor === 'string';

const validarCambiosPerfil = (cuerpo, usuarioActual) => {
  const cambios = {};
  const datos = cuerpo || {};

  for (const campo of ['nombre', 'apellido']) {
    if (datos[campo] === undefined) continue;

    if (!esTextoSimple(datos[campo])) {
      return { error: `El campo ${campo} no es válido` };
    }

    const valor = datos[campo].trim();

    if (valor.length < 1 || valor.length > 60) {
      return {
        error: `El ${campo} debe tener entre 1 y 60 caracteres`
      };
    }

    cambios[campo] = valor;
  }

  if (datos.telefono !== undefined) {
    if (!esTextoSimple(datos.telefono)) {
      return { error: 'El teléfono no es válido' };
    }

    const valor = datos.telefono.trim();

    if (valor !== '' && !/^[0-9+()\-\s]{7,20}$/.test(valor)) {
      return {
        error:
          'El teléfono solo puede tener números, espacios, + ( ) y -, entre 7 y 20 caracteres'
      };
    }

    cambios.telefono = valor;
  }

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
    const avatarActual = (usuarioActual && usuarioActual.avatar) || {};
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

    if (!nombre || !apellido || !correo || !password) {
      return res.status(400).json({
        mensaje:
          'Nombre, apellido, correo y contraseña son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const usuarioExistente = await Usuario.findOne({
      correo: correoNormalizado
    });

    if (usuarioExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    const passwordEncriptada = await bcrypt.hash(password, 10);

    const codigoVerificacion = crypto
      .randomInt(100000, 1000000)
      .toString();

    const codigoVerificacionExpiracion = new Date(
      Date.now() + 10 * 60 * 1000
    );

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

    await enviarCodigoVerificacion(
      usuario.correo,
      usuario.nombre,
      codigoVerificacion
    );

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
        correoVerificado: usuario.correoVerificado
      }
    });
  } catch (error) {
    console.error('Error al registrar usuario:', error);

    return res.status(500).json({
      mensaje: 'Error al registrar usuario',
      error: error.message
    });
  }
};

const verificarCorreo = async (req, res) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje: 'Correo y código son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const usuario = await Usuario.findOne({
      correo: correoNormalizado
    });

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    if (
      usuario.correoVerificado === true ||
      usuario.isVerified === true
    ) {
      return res.status(400).json({
        mensaje: 'El correo ya está verificado'
      });
    }

    if (usuario.codigoVerificacion !== codigo) {
      return res.status(400).json({
        mensaje: 'El código de verificación es incorrecto'
      });
    }

    if (
      !usuario.codigoVerificacionExpiracion ||
      usuario.codigoVerificacionExpiracion < new Date()
    ) {
      return res.status(400).json({
        mensaje: 'El código de verificación ha expirado'
      });
    }

    usuario.correoVerificado = true;
    usuario.codigoVerificacion = null;
    usuario.codigoVerificacionExpiracion = null;

    await usuario.save();

    return res.status(200).json({
      mensaje: 'Correo verificado correctamente'
    });
  } catch (error) {
    console.error('Error al verificar correo:', error);

    return res.status(500).json({
      mensaje: 'Error al verificar el correo',
      error: error.message
    });
  }
};

const iniciarSesionUsuario = async (req, res) => {
  try {
    const { correo, password } = req.body;

    if (!correo || !password) {
      return res.status(400).json({
        mensaje: 'Correo y contraseña son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const usuario = await Usuario.findOne({
      correo: correoNormalizado
    }).select('+password');

    if (!usuario) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    if (usuario.activo === false || usuario.eliminadoAt) {
      return res.status(403).json({
        mensaje: 'Esta cuenta está desactivada o fue eliminada'
      });
    }

    const correoEstaVerificado =
      usuario.correoVerificado === true ||
      usuario.isVerified === true;

    if (!correoEstaVerificado) {
      return res.status(403).json({
        mensaje: 'Debes verificar tu correo antes de iniciar sesión'
      });
    }

    const passwordCorrecta = await bcrypt.compare(
      password,
      usuario.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    const token = jwt.sign(
      {
        id: usuario._id.toString(),
        correo: usuario.correo,
        rol: 'usuario'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRES_IN || '1d'
      }
    );

    return res.status(200).json({
      mensaje: 'Inicio de sesión exitoso',
      token,
      usuario: usuarioPublico(usuario)
    });
  } catch (error) {
    console.error('Error al iniciar sesión:', error);

    return res.status(500).json({
      mensaje: 'Error al iniciar sesión',
      error: error.message
    });
  }
};

const recuperarPassword = async (req, res) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return res.status(400).json({
        mensaje: 'El correo es obligatorio'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const usuario = await Usuario.findOne({
      correo: correoNormalizado
    });

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'No existe un usuario registrado con ese correo'
      });
    }

    const codigoRecuperacion = crypto
      .randomInt(100000, 1000000)
      .toString();

    const codigoRecuperacionExpiracion = new Date(
      Date.now() + 10 * 60 * 1000
    );

    usuario.codigoRecuperacion = codigoRecuperacion;
    usuario.codigoRecuperacionExpiracion =
      codigoRecuperacionExpiracion;
    usuario.tokenRecuperacion = null;
    usuario.tokenRecuperacionExpiracion = null;

    await usuario.save();

    await enviarCodigoRecuperacion(
      usuario.correo,
      usuario.nombre,
      codigoRecuperacion
    );

    return res.status(200).json({
      mensaje: 'Hemos enviado un código de recuperación a tu correo'
    });
  } catch (error) {
    console.error('Error al recuperar contraseña:', error);

    return res.status(500).json({
      mensaje: 'Error al solicitar recuperación de contraseña',
      error: error.message
    });
  }
};
const verificarCodigoRecuperacion = async (req, res) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje: 'Correo y código son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const usuario = await Usuario.findOne({
      correo: correoNormalizado
    });

    if (!usuario || usuario.eliminadoAt || usuario.activo === false) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    if (usuario.codigoRecuperacion !== codigo) {
      return res.status(400).json({
        mensaje: 'El código de recuperación es incorrecto'
      });
    }

    if (
      !usuario.codigoRecuperacionExpiracion ||
      usuario.codigoRecuperacionExpiracion < new Date()
    ) {
      return res.status(400).json({
        mensaje: 'El código de recuperación ha expirado'
      });
    }

    const tokenRecuperacion = crypto.randomBytes(32).toString('hex');

    const tokenRecuperacionExpiracion = new Date(
      Date.now() + 10 * 60 * 1000
    );

    usuario.tokenRecuperacion = tokenRecuperacion;
    usuario.tokenRecuperacionExpiracion = tokenRecuperacionExpiracion;
    usuario.codigoRecuperacion = null;
    usuario.codigoRecuperacionExpiracion = null;

    await usuario.save();

    return res.status(200).json({
      mensaje: 'Código verificado correctamente',
      tokenRecuperacion
    });
  } catch (error) {
    console.error('Error al verificar código de recuperación:', error);

    return res.status(500).json({
      mensaje: 'Error al verificar el código',
      error: error.message
    });
  }
};

const restablecerPassword = async (req, res) => {
  try {
    const { tokenRecuperacion, nuevaPassword } = req.body;

    if (!tokenRecuperacion || !nuevaPassword) {
      return res.status(400).json({
        mensaje: 'Token y nueva contraseña son obligatorios'
      });
    }

    const usuario = await Usuario.findOne({
      tokenRecuperacion
    });

    if (!usuario || usuario.eliminadoAt || usuario.activo === false) {
      return res.status(400).json({
        mensaje: 'El token de recuperación no es válido'
      });
    }

    if (
      !usuario.tokenRecuperacionExpiracion ||
      usuario.tokenRecuperacionExpiracion < new Date()
    ) {
      return res.status(400).json({
        mensaje: 'El token de recuperación ha expirado'
      });
    }

    usuario.password = await bcrypt.hash(nuevaPassword, 10);
    usuario.tokenRecuperacion = null;
    usuario.tokenRecuperacionExpiracion = null;

    await usuario.save();

    return res.status(200).json({
      mensaje: 'Contraseña restablecida correctamente'
    });
  } catch (error) {
    console.error('Error al restablecer contraseña:', error);

    return res.status(500).json({
      mensaje: 'Error al restablecer la contraseña',
      error: error.message
    });
  }
};

const obtenerMiPerfil = async (req, res) => {
  try {
    if (req.usuario.rol !== 'usuario') {
      return res.status(403).json({
        mensaje: 'No tienes permisos para esta acción'
      });
    }

    const usuario = await Usuario.findById(req.usuario.id)
      .select('+password');

    if (!usuario || usuario.eliminadoAt || usuario.activo === false) {
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
    console.error('Error al obtener mi perfil:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener el perfil'
    });
  }
};

const actualizarUsuario = async (req, res) => {
  try {
    if (
      req.usuario.rol !== 'usuario' ||
      req.usuario.id !== req.params.id
    ) {
      return res.status(403).json({
        mensaje: 'No puedes modificar otro usuario'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador de usuario no válido'
      });
    }

    const usuario = await Usuario.findById(req.params.id);

    if (!usuario || usuario.eliminadoAt || usuario.activo === false) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    const { cambios, error } = validarCambiosPerfil(
      req.body,
      usuario
    );

    if (error) {
      return res.status(400).json({ mensaje: error });
    }

    usuario.set(cambios);
    await usuario.save();

    return res.status(200).json({
      mensaje: 'Perfil actualizado correctamente',
      usuario: usuarioPublico(usuario)
    });
  } catch (error) {
    console.error('Error al actualizar usuario:', error);

    if (error.name === 'ValidationError') {
      return res.status(400).json({
        mensaje: 'Los datos enviados no son válidos'
      });
    }

    return res.status(500).json({
      mensaje: 'Error al actualizar el perfil'
    });
  }
};
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
      mensaje: 'Escribe tu contraseña para eliminar la cuenta'
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

const eliminarDatosYAnonimizar = async (
  usuario,
  sesion,
  datosEliminacion
) => {
  const opciones = sesion ? { session: sesion } : {};
  const id = usuario._id;

  const activas = await contarReservasActivas(id, sesion);

  if (activas > 0) {
    throw new ReservasActivasError(activas);
  }

  await Resena.deleteMany({ usuario: id }, opciones);
  await Favorito.deleteMany({ usuario: id }, opciones);
  await Ruta.deleteMany({ usuario: id }, opciones);
  await Notificacion.deleteMany({ usuario: id }, opciones);
  await Ayuda.deleteMany({ usuarioId: id }, opciones);
  await Visita.deleteMany({ usuario: id }, opciones);
  await MapaOffline.deleteMany({ usuario: id }, opciones);

  await Reserva.updateMany(
    { usuario: id },
    { $set: { observaciones: '' } },
    opciones
  );

  // Conservar el historial antes de anonimizar la cuenta.
  usuario.eliminacion = datosEliminacion;

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
  usuario.eliminadoAt = datosEliminacion.fecha;

  await usuario.save(opciones);
};

const eliminarUsuario = async (req, res) => {
  try {
    if (
      req.usuario.rol !== 'usuario' ||
      req.usuario.id !== req.params.id
    ) {
      return res.status(403).json({
        mensaje: 'No puedes eliminar otro usuario'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador de usuario no válido'
      });
    }

    const usuario = await Usuario.findById(req.params.id)
      .select('+password');

    if (!usuario || usuario.eliminadoAt) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    if (!req.body || req.body.confirmar !== true) {
      return res.status(400).json({
        mensaje:
          'Debes confirmar de forma explícita que quieres eliminar tu cuenta'
      });
    }

    const fallo = await comprobarIdentidad(usuario, req.body);

    if (fallo) {
      return res.status(fallo.codigo).json({
        mensaje: fallo.mensaje
      });
    }

    const reservasActivas = await contarReservasActivas(
      usuario._id,
      null
    );

    if (reservasActivas > 0) {
      return respuestaReservasActivas(res, reservasActivas);
    }

    // Guardar el nombre original, responsable, fecha y motivo.
    const fechaEliminacion = new Date();

    const datosEliminacion = {
     tipo: 'usuario',
     usuarioNombre: `${usuario.nombre} ${usuario.apellido}`.trim(),
     usuarioCorreo: usuario.correo,
     responsableId: usuario._id,
     responsableNombre: 'El propio usuario',  
     fecha: fechaEliminacion,
     motivo: 'El usuario solicitó eliminar su propia cuenta'
     
    };

    const sesion = await mongoose.startSession();

    try {
      await sesion.withTransaction(async () => {
        await eliminarDatosYAnonimizar(
          usuario,
          sesion,
          datosEliminacion
        );
      });
    } catch (errorTransaccion) {
      const sinTransacciones =
        /replica set|Transaction numbers/i.test(
          String(errorTransaccion && errorTransaccion.message)
        );

      if (!sinTransacciones) {
        throw errorTransaccion;
      }

      const recargado = await Usuario.findById(req.params.id)
        .select('+password');

      if (!recargado || recargado.eliminadoAt) {
        throw new Error(
          'No se encontró una cuenta válida para eliminar'
        );
      }

      await eliminarDatosYAnonimizar(
        recargado,
        null,
        datosEliminacion
      );
    } finally {
      await sesion.endSession();
    }

    return res.status(200).json({
      mensaje:
        'Tu cuenta fue eliminada: tus reseñas y tus datos personales se borraron'
    });
  } catch (error) {
    if (error instanceof ReservasActivasError) {
      return respuestaReservasActivas(res, error.cantidad);
    }

    console.error('Error al eliminar usuario:', error);

    return res.status(500).json({
      mensaje:
        'No se pudo completar la eliminación. Tu cuenta sigue activa; inténtalo de nuevo'
    });
  }
};

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