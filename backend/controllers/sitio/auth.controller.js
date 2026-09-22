const CuentaSitio = require('../../models/sitio/auth');

const bcrypt = require('bcryptjs');

const jwt = require('jsonwebtoken');

const crypto = require('crypto');

const {
  enviarCodigoRecuperacion
} = require('../../utils/mailer');


// ======================================================
// INICIAR SESIÓN DEL SITIO
// ======================================================

const iniciarSesion = async (req, res) => {
  try {
    const {
      correo,
      password
    } = req.body;

    // --------------------------------------------------
    // VALIDAR DATOS
    // --------------------------------------------------

    if (!correo || !password) {
      return res.status(400).json({
        mensaje:
          'Correo y contraseña son obligatorios'
      });
    }

    // --------------------------------------------------
    // BUSCAR CUENTA
    // --------------------------------------------------

    const cuenta = await CuentaSitio.findOne({
      correo: correo.toLowerCase().trim()
    }).select('+password');

    if (!cuenta) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    // --------------------------------------------------
    // COMPROBAR ESTADO
    // --------------------------------------------------

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del sitio está inactiva'
      });
    }

    // --------------------------------------------------
    // COMPARAR CONTRASEÑA
    // --------------------------------------------------

    const passwordCorrecta =
      await bcrypt.compare(
        password,
        cuenta.password
      );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    // --------------------------------------------------
    // CREAR TOKEN JWT
    // --------------------------------------------------

    const token = jwt.sign(
      {
        id: cuenta._id,
        correo: cuenta.correo,
        rol: 'sitio'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    // --------------------------------------------------
    // RESPUESTA
    // --------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Inicio de sesión del sitio exitoso',

      token,

      cuenta: {
        id: cuenta._id,
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono,
        rol: 'sitio',
        activo: cuenta.activo
      }
    });

  } catch (error) {
    console.error(
      'Error al iniciar sesión como sitio:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al iniciar sesión como sitio',
      error: error.message
    });
  }
};


// ======================================================
// RECUPERAR CONTRASEÑA
// ======================================================

const recuperarPassword = async (req, res) => {
  try {
    const {
      correo
    } = req.body;

    // --------------------------------------------------
    // VALIDAR CORREO
    // --------------------------------------------------

    if (!correo) {
      return res.status(400).json({
        mensaje:
          'El correo es obligatorio'
      });
    }

    const correoNormalizado =
      correo.toLowerCase().trim();

    // --------------------------------------------------
    // BUSCAR CUENTA
    // --------------------------------------------------

    const cuenta =
      await CuentaSitio.findOne({
        correo: correoNormalizado
      });

    if (!cuenta) {
      return res.status(404).json({
        mensaje:
          'No existe una cuenta con ese correo'
      });
    }

    // --------------------------------------------------
    // COMPROBAR ESTADO
    // --------------------------------------------------

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del sitio está inactiva'
      });
    }

    // --------------------------------------------------
    // GENERAR CÓDIGO
    // --------------------------------------------------

    const codigoRecuperacion =
      crypto.randomInt(
        100000,
        1000000
      ).toString();

    // --------------------------------------------------
    // GUARDAR CÓDIGO
    // --------------------------------------------------

    cuenta.codigoRecuperacion =
      codigoRecuperacion;

    cuenta.codigoRecuperacionExpiracion =
      new Date(
        Date.now() + 10 * 60 * 1000
      );

    cuenta.tokenRecuperacion = null;

    cuenta.tokenRecuperacionExpiracion = null;

    await cuenta.save();

    // --------------------------------------------------
    // ENVIAR CÓDIGO
    // --------------------------------------------------

    try {
      await enviarCodigoRecuperacion(
        cuenta.correo,
        cuenta.nombre,
        codigoRecuperacion
      );
    } catch (errorCorreo) {
      console.error(
        'Error enviando código de recuperación:',
        errorCorreo
      );

      return res.status(500).json({
        mensaje:
          'No fue posible enviar el código de recuperación'
      });
    }

    // --------------------------------------------------
    // RESPUESTA
    // --------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Código de recuperación enviado al correo'
    });

  } catch (error) {
    console.error(
      'Error al recuperar contraseña:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al recuperar contraseña',
      error: error.message
    });
  }
};


// ======================================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// ======================================================

const verificarCodigoRecuperacion = async (
  req,
  res
) => {
  try {
    const {
      correo,
      codigo
    } = req.body;

    // --------------------------------------------------
    // VALIDAR DATOS
    // --------------------------------------------------

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje:
          'Correo y código son obligatorios'
      });
    }

    // --------------------------------------------------
    // BUSCAR CUENTA
    // --------------------------------------------------

    const cuenta =
      await CuentaSitio.findOne({
        correo: correo.toLowerCase().trim()
      });

    if (!cuenta) {
      return res.status(404).json({
        mensaje:
          'No existe una cuenta con ese correo'
      });
    }

    // --------------------------------------------------
    // COMPROBAR ESTADO
    // --------------------------------------------------

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del sitio está inactiva'
      });
    }

    // --------------------------------------------------
    // COMPROBAR CÓDIGO
    // --------------------------------------------------

    if (
      cuenta.codigoRecuperacion !==
      codigo.toString()
    ) {
      return res.status(400).json({
        mensaje:
          'El código de recuperación es incorrecto'
      });
    }

    // --------------------------------------------------
    // COMPROBAR EXPIRACIÓN
    // --------------------------------------------------

    if (
      !cuenta.codigoRecuperacionExpiracion ||
      cuenta.codigoRecuperacionExpiracion <
        new Date()
    ) {
      return res.status(400).json({
        mensaje:
          'El código de recuperación ha expirado'
      });
    }

    // --------------------------------------------------
    // GENERAR TOKEN TEMPORAL
    // --------------------------------------------------

    const tokenRecuperacion =
      crypto.randomBytes(32).toString('hex');

    cuenta.tokenRecuperacion =
      tokenRecuperacion;

    cuenta.tokenRecuperacionExpiracion =
      new Date(
        Date.now() + 10 * 60 * 1000
      );

    // --------------------------------------------------
    // LIMPIAR CÓDIGO
    // --------------------------------------------------

    cuenta.codigoRecuperacion = null;

    cuenta.codigoRecuperacionExpiracion = null;

    await cuenta.save();

    // --------------------------------------------------
    // RESPUESTA
    // --------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Código de recuperación verificado correctamente',

      tokenRecuperacion
    });

  } catch (error) {
    console.error(
      'Error al verificar código de recuperación:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al verificar código de recuperación',
      error: error.message
    });
  }
};


// ======================================================
// RESTABLECER CONTRASEÑA
// ======================================================

const restablecerPassword = async (
  req,
  res
) => {
  try {
    const {
      tokenRecuperacion,
      nuevaPassword
    } = req.body;

    // --------------------------------------------------
    // VALIDAR DATOS
    // --------------------------------------------------

    if (
      !tokenRecuperacion ||
      !nuevaPassword
    ) {
      return res.status(400).json({
        mensaje:
          'Token de recuperación y nueva contraseña son obligatorios'
      });
    }

    // --------------------------------------------------
    // VALIDAR CONTRASEÑA
    // --------------------------------------------------

    if (nuevaPassword.length < 6) {
      return res.status(400).json({
        mensaje:
          'La nueva contraseña debe tener mínimo 6 caracteres'
      });
    }

    // --------------------------------------------------
    // BUSCAR CUENTA
    // --------------------------------------------------

    const cuenta =
      await CuentaSitio.findOne({
        tokenRecuperacion
      }).select('+password');

    if (!cuenta) {
      return res.status(400).json({
        mensaje:
          'El token de recuperación no es válido'
      });
    }

    // --------------------------------------------------
    // COMPROBAR EXPIRACIÓN
    // --------------------------------------------------

    if (
      !cuenta.tokenRecuperacionExpiracion ||
      cuenta.tokenRecuperacionExpiracion <
        new Date()
    ) {
      return res.status(400).json({
        mensaje:
          'El token de recuperación ha expirado'
      });
    }

    // --------------------------------------------------
    // CAMBIAR CONTRASEÑA
    // --------------------------------------------------

    cuenta.password =
      await bcrypt.hash(
        nuevaPassword,
        10
      );

    // --------------------------------------------------
    // LIMPIAR TOKEN
    // --------------------------------------------------

    cuenta.tokenRecuperacion = null;

    cuenta.tokenRecuperacionExpiracion = null;

    await cuenta.save();

    // --------------------------------------------------
    // RESPUESTA
    // --------------------------------------------------

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
        'Error al restablecer contraseña',
      error: error.message
    });
  }
};


// ======================================================
// EXPORTAR
// ======================================================

module.exports = {
  iniciarSesion,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
};