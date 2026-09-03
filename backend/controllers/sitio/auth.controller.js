const CuentaSitio = require('../../models/sitio/auth');

const bcrypt = require('bcryptjs');

const jwt = require('jsonwebtoken');

const crypto = require('crypto');

const {
  enviarCodigoVerificacion,
  enviarCodigoRecuperacion
} = require('../../utils/mailer');


// ==========================================
// REGISTRAR CUENTA DEL SITIO
// ==========================================

const registrar = async (req, res) => {
  try {

    const {
      nombre,
      apellido,
      correo,
      password,
      telefono
    } = req.body;

    // Validar campos obligatorios

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

    // Normalizar correo

    const correoNormalizado =
      correo.toLowerCase().trim();

    // Comprobar si ya existe

    const cuentaExistente =
      await CuentaSitio.findOne({
        correo: correoNormalizado
      });

    if (cuentaExistente) {
      return res.status(400).json({
        mensaje:
          'El correo ya está registrado'
      });
    }

    // Encriptar contraseña

    const passwordEncriptada =
      await bcrypt.hash(password, 10);

    // Generar código de verificación

    const codigoVerificacion =
      Math.floor(
        100000 + Math.random() * 900000
      ).toString();

    // Crear cuenta

    const nuevaCuenta =
      new CuentaSitio({

        nombre,

        apellido,

        correo:
          correoNormalizado,

        password:
          passwordEncriptada,

        telefono,

        isVerified:
          false,

        codigoVerificacion,

        codigoVerificacionExpiracion:
          new Date(
            Date.now() +
            10 * 60 * 1000
          )
      });

    await nuevaCuenta.save();

    // Enviar código de verificación

    try {

      await enviarCodigoVerificacion(
        nuevaCuenta.correo,
        nuevaCuenta.nombre,
        codigoVerificacion
      );

    } catch (errorCorreo) {

      console.error(
        'Error enviando código de verificación:',
        errorCorreo
      );

      // Eliminar cuenta si no se pudo enviar
      // el correo de verificación

      await CuentaSitio.findByIdAndDelete(
        nuevaCuenta._id
      );

      return res.status(500).json({
        mensaje:
          'No fue posible enviar el código de verificación'
      });
    }

    // Respuesta

    res.status(201).json({

      mensaje:
        'Cuenta del sitio creada correctamente. Revisa tu correo para verificarla.',

      cuenta: {

        id:
          nuevaCuenta._id,

        nombre:
          nuevaCuenta.nombre,

        apellido:
          nuevaCuenta.apellido,

        correo:
          nuevaCuenta.correo,

        telefono:
          nuevaCuenta.telefono,

        activo:
          nuevaCuenta.activo,

        isVerified:
          nuevaCuenta.isVerified,

        rol:
          'sitio'
      }

    });

  } catch (error) {

    console.error(
      'Error al registrar cuenta del sitio:',
      error
    );

    res.status(500).json({

      mensaje:
        'Error al crear la cuenta del sitio',

      error:
        error.message

    });
  }
};


// ==========================================
// VERIFICAR CORREO
// ==========================================

const verificarCorreo = async (req, res) => {
  try {

    const {
      correo,
      codigo
    } = req.body;

    // Validar datos

    if (!correo || !codigo) {

      return res.status(400).json({

        mensaje:
          'Correo y código son obligatorios'

      });
    }

    // Normalizar correo

    const correoNormalizado =
      correo.toLowerCase().trim();

    // Buscar cuenta

    const cuenta =
      await CuentaSitio.findOne({
        correo:
          correoNormalizado
      });

    if (!cuenta) {

      return res.status(404).json({

        mensaje:
          'No existe una cuenta con ese correo'

      });
    }

    // Comprobar si ya está verificada

    if (cuenta.isVerified) {

      return res.status(400).json({

        mensaje:
          'El correo ya fue verificado'

      });
    }

    // Comprobar código

    if (
      cuenta.codigoVerificacion !==
      codigo.toString()
    ) {

      return res.status(400).json({

        mensaje:
          'El código de verificación es incorrecto'

      });
    }

    // Comprobar expiración

    if (
      !cuenta.codigoVerificacionExpiracion ||
      cuenta.codigoVerificacionExpiracion <
      new Date()
    ) {

      return res.status(400).json({

        mensaje:
          'El código de verificación ha expirado'

      });
    }

    // Marcar correo como verificado

    cuenta.isVerified = true;

    // Limpiar código

    cuenta.codigoVerificacion = null;

    cuenta.codigoVerificacionExpiracion =
      null;

    await cuenta.save();

    res.status(200).json({

      mensaje:
        'Correo verificado correctamente',

      isVerified:
        true

    });

  } catch (error) {

    console.error(
      'Error al verificar correo:',
      error
    );

    res.status(500).json({

      mensaje:
        'Error al verificar el correo',

      error:
        error.message

    });
  }
};


// ==========================================
// INICIAR SESIÓN
// ==========================================

const iniciarSesion = async (req, res) => {
  try {

    const {
      correo,
      password
    } = req.body;

    // Validar campos

    if (!correo || !password) {

      return res.status(400).json({

        mensaje:
          'Correo y contraseña son obligatorios'

      });
    }

    // Normalizar correo

    const correoNormalizado =
      correo.toLowerCase().trim();

    // Buscar cuenta

    const cuenta =
      await CuentaSitio.findOne({

        correo:
          correoNormalizado

      }).select('+password');

    if (!cuenta) {

      return res.status(401).json({

        mensaje:
          'Correo o contraseña incorrectos'

      });
    }

    // Verificar correo

    if (!cuenta.isVerified) {

      return res.status(403).json({

        mensaje:
          'Debes verificar tu correo antes de iniciar sesión'

      });
    }

    // Verificar si la cuenta está activa

    if (!cuenta.activo) {

      return res.status(403).json({

        mensaje:
          'La cuenta del sitio está inactiva'

      });
    }

    // Comparar contraseña

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

    // Crear token

    const token =
      jwt.sign(

        {
          id:
            cuenta._id,

          correo:
            cuenta.correo,

          rol:
            'sitio'
        },

        process.env.JWT_SECRET,

        {
          expiresIn:
            '7d'
        }

      );

    // Respuesta

    res.status(200).json({

      mensaje:
        'Inicio de sesión del sitio exitoso',

      token,

      cuenta: {

        id:
          cuenta._id,

        nombre:
          cuenta.nombre,

        apellido:
          cuenta.apellido,

        correo:
          cuenta.correo,

        telefono:
          cuenta.telefono,

        rol:
          'sitio',

        activo:
          cuenta.activo,

        isVerified:
          cuenta.isVerified

      }

    });

  } catch (error) {

    console.error(
      'Error al iniciar sesión como sitio:',
      error
    );

    res.status(500).json({

      mensaje:
        'Error al iniciar sesión como sitio',

      error:
        error.message

    });
  }
};


// ==========================================
// RECUPERAR CONTRASEÑA
// ==========================================

const recuperarPassword = async (req, res) => {
  try {

    const {
      correo
    } = req.body;

    // Validar correo

    if (!correo) {

      return res.status(400).json({

        mensaje:
          'El correo es obligatorio'

      });
    }

    // Normalizar correo

    const correoNormalizado =
      correo.toLowerCase().trim();

    // Buscar cuenta

    const cuenta =
      await CuentaSitio.findOne({

        correo:
          correoNormalizado

      });

    if (!cuenta) {

      return res.status(404).json({

        mensaje:
          'No existe una cuenta con ese correo'

      });
    }

    // Generar código de recuperación

    const codigoRecuperacion =
      Math.floor(
        100000 + Math.random() * 900000
      ).toString();

    // Guardar código

    cuenta.codigoRecuperacion =
      codigoRecuperacion;

    cuenta.codigoRecuperacionExpiracion =
      new Date(
        Date.now() +
        10 * 60 * 1000
      );

    // Limpiar token anterior

    cuenta.tokenRecuperacion =
      null;

    cuenta.tokenRecuperacionExpiracion =
      null;

    await cuenta.save();

    // Enviar código

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

    res.status(200).json({

      mensaje:
        'Código de recuperación enviado al correo'

    });

  } catch (error) {

    console.error(
      'Error al recuperar contraseña:',
      error
    );

    res.status(500).json({

      mensaje:
        'Error al recuperar contraseña',

      error:
        error.message

    });
  }
};


// ==========================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// ==========================================

const verificarCodigoRecuperacion =
  async (req, res) => {

    try {

      const {
        correo,
        codigo
      } = req.body;

      // Validar datos

      if (!correo || !codigo) {

        return res.status(400).json({

          mensaje:
            'Correo y código son obligatorios'

        });
      }

      // Normalizar correo

      const correoNormalizado =
        correo.toLowerCase().trim();

      // Buscar cuenta

      const cuenta =
        await CuentaSitio.findOne({

          correo:
            correoNormalizado

        });

      if (!cuenta) {

        return res.status(404).json({

          mensaje:
            'No existe una cuenta con ese correo'

        });
      }

      // Comprobar código

      if (
        cuenta.codigoRecuperacion !==
        codigo.toString()
      ) {

        return res.status(400).json({

          mensaje:
            'El código de recuperación es incorrecto'

        });
      }

      // Comprobar expiración

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

      // Generar token temporal

      const tokenRecuperacion =
        crypto
          .randomBytes(32)
          .toString('hex');

      // Guardar token

      cuenta.tokenRecuperacion =
        tokenRecuperacion;

      cuenta.tokenRecuperacionExpiracion =
        new Date(
          Date.now() +
          10 * 60 * 1000
        );

      // Limpiar código utilizado

      cuenta.codigoRecuperacion =
        null;

      cuenta.codigoRecuperacionExpiracion =
        null;

      await cuenta.save();

      res.status(200).json({

        mensaje:
          'Código de recuperación verificado correctamente',

        tokenRecuperacion

      });

    } catch (error) {

      console.error(
        'Error al verificar código de recuperación:',
        error
      );

      res.status(500).json({

        mensaje:
          'Error al verificar código de recuperación',

        error:
          error.message

      });
    }
  };


// ==========================================
// RESTABLECER CONTRASEÑA
// ==========================================

const restablecerPassword =
  async (req, res) => {

    try {

      const {
        tokenRecuperacion,
        nuevaPassword
      } = req.body;

      // Validar datos

      if (
        !tokenRecuperacion ||
        !nuevaPassword
      ) {

        return res.status(400).json({

          mensaje:
            'Token de recuperación y nueva contraseña son obligatorios'

        });
      }

      // Validar longitud

      if (
        nuevaPassword.length < 6
      ) {

        return res.status(400).json({

          mensaje:
            'La nueva contraseña debe tener mínimo 6 caracteres'

        });
      }

      // Buscar cuenta

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

      // Comprobar expiración

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

      // Encriptar nueva contraseña

      cuenta.password =
        await bcrypt.hash(
          nuevaPassword,
          10
        );

      // Limpiar token

      cuenta.tokenRecuperacion =
        null;

      cuenta.tokenRecuperacionExpiracion =
        null;

      await cuenta.save();

      res.status(200).json({

        mensaje:
          'Contraseña restablecida correctamente'

      });

    } catch (error) {

      console.error(
        'Error al restablecer contraseña:',
        error
      );

      res.status(500).json({

        mensaje:
          'Error al restablecer contraseña',

        error:
          error.message

      });
    }
  };


// ==========================================
// EXPORTAR
// ==========================================

module.exports = {

  registrar,

  verificarCorreo,

  iniciarSesion,

  recuperarPassword,

  verificarCodigoRecuperacion,

  restablecerPassword

};