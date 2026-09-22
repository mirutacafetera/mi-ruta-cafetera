const bcrypt = require('bcryptjs');

const jwt = require('jsonwebtoken');

const crypto = require('crypto');

const AuthAdmin = require(
  '../../models/admin/authsitio'
);

const {
  enviarCodigoRecuperacion
} = require('../../utils/mailer');

// =====================================================
// INICIAR SESIÓN ADMINISTRADOR
// =====================================================

const iniciarSesionAdmin = async (req, res) => {
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
    // BUSCAR ADMINISTRADOR
    // -------------------------------------------------

    const administrador =
      await AuthAdmin
        .findOne({
          correo: correoNormalizado
        })
        .select('+password');

    if (!administrador) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    // -------------------------------------------------
    // VERIFICAR ESTADO
    // -------------------------------------------------

    if (!administrador.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del administrador está inactiva'
      });
    }

    // -------------------------------------------------
    // COMPARAR CONTRASEÑA
    // -------------------------------------------------

    const passwordCorrecta =
      await bcrypt.compare(
        password,
        administrador.password
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
          id: administrador._id.toString(),
          correo: administrador.correo,
          rol: 'admin'
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

      administrador: {
        id: administrador._id,
        nombre: administrador.nombre,
        apellido: administrador.apellido,
        correo: administrador.correo,
        telefono: administrador.telefono,
        rol: administrador.rol,
        activo: administrador.activo
      }
    });

  } catch (error) {
    console.error(
      'Error al iniciar sesión como administrador:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al iniciar sesión como administrador',
      error: error.message
    });
  }
};

// =====================================================
// OBTENER ADMINISTRADOR
// =====================================================

const obtenerAdministrador = async (req, res) => {
  try {
    const administrador =
      await AuthAdmin
        .findById(req.params.id)
        .select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje:
          'Administrador no encontrado'
      });
    }

    return res.status(200).json(
      administrador
    );

  } catch (error) {
    console.error(
      'Error al obtener administrador:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al obtener administrador',
      error: error.message
    });
  }
};

// =====================================================
// RECUPERAR CONTRASEÑA
// =====================================================

const recuperarPasswordAdmin = async (req, res) => {
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
    // BUSCAR ADMINISTRADOR
    // -------------------------------------------------

    const administrador =
      await AuthAdmin.findOne({
        correo: correoNormalizado
      });

    if (!administrador) {
      return res.status(404).json({
        mensaje:
          'No existe un administrador con ese correo'
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

    administrador.codigoRecuperacion =
      codigoRecuperacion;

    administrador.codigoRecuperacionExpiracion =
      codigoRecuperacionExpiracion;

    administrador.tokenRecuperacion = null;

    administrador.tokenRecuperacionExpiracion =
      null;

    await administrador.save();

    // -------------------------------------------------
    // ENVIAR CÓDIGO
    // -------------------------------------------------

    await enviarCodigoRecuperacion(
      administrador.correo,
      administrador.nombre,
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
      'Error al recuperar contraseña del administrador:',
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

const verificarCodigoRecuperacionAdmin =
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
      // BUSCAR ADMINISTRADOR
      // ------------------------------------------------

      const administrador =
        await AuthAdmin.findOne({
          correo: correoNormalizado
        });

      if (!administrador) {
        return res.status(404).json({
          mensaje:
            'Administrador no encontrado'
        });
      }

      // ------------------------------------------------
      // VERIFICAR CÓDIGO
      // ------------------------------------------------

      if (
        administrador.codigoRecuperacion !==
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
        !administrador.codigoRecuperacionExpiracion ||
        administrador.codigoRecuperacionExpiracion <
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
        crypto
          .randomBytes(32)
          .toString('hex');

      const tokenRecuperacionExpiracion =
        new Date(
          Date.now() +
          10 * 60 * 1000
        );

      // ------------------------------------------------
      // GUARDAR TOKEN
      // ------------------------------------------------

      administrador.tokenRecuperacion =
        tokenRecuperacion;

      administrador.tokenRecuperacionExpiracion =
        tokenRecuperacionExpiracion;

      administrador.codigoRecuperacion = null;

      administrador.codigoRecuperacionExpiracion =
        null;

      await administrador.save();

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

const restablecerPasswordAdmin =
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
      // VALIDAR CONTRASEÑA
      // ------------------------------------------------

      if (nuevaPassword.length < 6) {
        return res.status(400).json({
          mensaje:
            'La contraseña debe tener al menos 6 caracteres'
        });
      }

      // ------------------------------------------------
      // BUSCAR ADMINISTRADOR
      // ------------------------------------------------

      const administrador =
        await AuthAdmin.findOne({
          tokenRecuperacion
        });

      if (!administrador) {
        return res.status(400).json({
          mensaje:
            'El token de recuperación no es válido'
        });
      }

      // ------------------------------------------------
      // VERIFICAR EXPIRACIÓN
      // ------------------------------------------------

      if (
        !administrador.tokenRecuperacionExpiracion ||
        administrador.tokenRecuperacionExpiracion <
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

      administrador.password =
        await bcrypt.hash(
          nuevaPassword,
          10
        );

      // ------------------------------------------------
      // LIMPIAR TOKEN
      // ------------------------------------------------

      administrador.tokenRecuperacion = null;

      administrador.tokenRecuperacionExpiracion =
        null;

      await administrador.save();

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
// EXPORTAR
// =====================================================

module.exports = {
  iniciarSesionAdmin,
  obtenerAdministrador,
  recuperarPasswordAdmin,
  verificarCodigoRecuperacionAdmin,
  restablecerPasswordAdmin
};