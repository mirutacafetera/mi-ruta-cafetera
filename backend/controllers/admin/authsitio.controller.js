const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const CuentaSitio = require(
  '../../models/sitio/auth'
);

const SitioTuristico = require(
  '../../models/admin/sitio'
);

const {
  enviarCodigoRecuperacion
} = require('../../utils/mailer');

// =====================================================
// CREAR CUENTA DE SITIO TURÍSTICO
// SOLO PUEDE SER EJECUTADA POR UN ADMINISTRADOR
// =====================================================

const crearCuentaSitio = async (req, res) => {
  try {
    const {
      sitioId,
      nombre,
      apellido,
      correo,
      password,
      telefono
    } = req.body;

    // -------------------------------------------------
    // VALIDAR CAMPOS OBLIGATORIOS
    // -------------------------------------------------

    if (
      !sitioId ||
      !nombre ||
      !apellido ||
      !correo ||
      !password
    ) {
      return res.status(400).json({
        mensaje:
          'sitioId, nombre, apellido, correo y contraseña son obligatorios'
      });
    }

    // -------------------------------------------------
    // VALIDAR CONTRASEÑA
    // -------------------------------------------------

    if (password.length < 6) {
      return res.status(400).json({
        mensaje:
          'La contraseña debe tener al menos 6 caracteres'
      });
    }

    // -------------------------------------------------
    // NORMALIZAR CORREO
    // -------------------------------------------------

    const correoNormalizado =
      correo.toLowerCase().trim();

    // -------------------------------------------------
    // VERIFICAR QUE EL SITIO EXISTA
    // -------------------------------------------------

    const sitio =
      await SitioTuristico.findById(sitioId);

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'El sitio turístico no existe'
      });
    }

    // -------------------------------------------------
    // VERIFICAR SI EL SITIO YA TIENE CUENTA
    // -------------------------------------------------

    const cuentaPorSitio =
      await CuentaSitio.findOne({
        sitioId: sitio._id
      });

    if (cuentaPorSitio) {
      return res.status(409).json({
        mensaje:
          'Este sitio turístico ya tiene una cuenta'
      });
    }

    // -------------------------------------------------
    // VERIFICAR SI EL CORREO YA ESTÁ REGISTRADO
    // -------------------------------------------------

    const cuentaPorCorreo =
      await CuentaSitio.findOne({
        correo: correoNormalizado
      });

    if (cuentaPorCorreo) {
      return res.status(409).json({
        mensaje:
          'El correo ya está registrado para una cuenta de sitio'
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
    // CREAR CUENTA
    // -------------------------------------------------

    const cuenta =
      await CuentaSitio.create({
        sitioId: sitio._id,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        correo: correoNormalizado,
        password: passwordEncriptada,
        telefono: telefono
          ? telefono.trim()
          : '',
        activo: true
      });

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(201).json({
      mensaje:
        'Cuenta del sitio creada correctamente',

      cuenta: {
        id: cuenta._id.toString(),
        sitioId: cuenta.sitioId.toString(),
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono,
        activo: cuenta.activo
      }
    });

  } catch (error) {
    console.error(
      'Error al crear cuenta del sitio:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al crear la cuenta del sitio'
    });
  }
};

// =====================================================
// INICIAR SESIÓN DEL SITIO TURÍSTICO
// =====================================================

const iniciarSesion = async (req, res) => {
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
    // BUSCAR CUENTA DEL SITIO
    // -------------------------------------------------

    const cuenta =
      await CuentaSitio
        .findOne({
          correo: correoNormalizado
        })
        .select('+password');

    if (!cuenta) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    // -------------------------------------------------
    // VERIFICAR ESTADO
    // -------------------------------------------------

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del sitio está inactiva'
      });
    }

    // -------------------------------------------------
    // COMPARAR CONTRASEÑA
    // -------------------------------------------------

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

    // -------------------------------------------------
    // CREAR JWT
    // -------------------------------------------------

    const token =
      jwt.sign(
        {
          id: cuenta._id.toString(),
          sitioId: cuenta.sitioId.toString(),
          correo: cuenta.correo,
          rol: 'sitio'
        },
        process.env.JWT_SECRET,
        {
          expiresIn:
            process.env.JWT_EXPIRES_IN || '7d'
        }
      );

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Inicio de sesión exitoso',

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
    });

  } catch (error) {
    console.error(
      'Error al iniciar sesión del sitio:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al iniciar sesión'
    });
  }
};

// =====================================================
// RECUPERAR CONTRASEÑA DEL SITIO
// =====================================================

const recuperarPassword = async (req, res) => {
  try {
    const {
      correo
    } = req.body;

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
    // BUSCAR CUENTA
    // -------------------------------------------------

    const cuenta =
      await CuentaSitio.findOne({
        correo: correoNormalizado
      });

    if (!cuenta) {
      return res.status(404).json({
        mensaje:
          'No existe una cuenta de sitio con ese correo'
      });
    }

    // -------------------------------------------------
    // VERIFICAR ESTADO
    // -------------------------------------------------

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del sitio está inactiva'
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

    cuenta.codigoRecuperacion =
      codigoRecuperacion;

    cuenta.codigoRecuperacionExpiracion =
      codigoRecuperacionExpiracion;

    cuenta.tokenRecuperacion = null;

    cuenta.tokenRecuperacionExpiracion =
      null;

    await cuenta.save();

    // -------------------------------------------------
    // ENVIAR CÓDIGO
    // -------------------------------------------------

    await enviarCodigoRecuperacion(
      cuenta.correo,
      cuenta.nombre,
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
      'Error al recuperar contraseña del sitio:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al solicitar recuperación de contraseña'
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
      // BUSCAR CUENTA
      // ------------------------------------------------

      const cuenta =
        await CuentaSitio.findOne({
          correo: correoNormalizado
        });

      if (!cuenta) {
        return res.status(404).json({
          mensaje:
            'Cuenta del sitio no encontrada'
        });
      }

      // ------------------------------------------------
      // VERIFICAR CÓDIGO
      // ------------------------------------------------

      if (
        cuenta.codigoRecuperacion !==
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
        !cuenta.codigoRecuperacionExpiracion ||
        cuenta.codigoRecuperacionExpiracion <
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

      cuenta.tokenRecuperacion =
        tokenRecuperacion;

      cuenta.tokenRecuperacionExpiracion =
        tokenRecuperacionExpiracion;

      cuenta.codigoRecuperacion = null;

      cuenta.codigoRecuperacionExpiracion =
        null;

      await cuenta.save();

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
        'Error al verificar código de recuperación del sitio:',
        error
      );

      return res.status(500).json({
        mensaje:
          'Error al verificar el código'
      });
    }
  };

// =====================================================
// RESTABLECER CONTRASEÑA DEL SITIO
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
      // VALIDAR CONTRASEÑA
      // ------------------------------------------------

      if (nuevaPassword.length < 6) {
        return res.status(400).json({
          mensaje:
            'La contraseña debe tener al menos 6 caracteres'
        });
      }

      // ------------------------------------------------
      // BUSCAR CUENTA
      // ------------------------------------------------

      const cuenta =
        await CuentaSitio.findOne({
          tokenRecuperacion
        });

      if (!cuenta) {
        return res.status(400).json({
          mensaje:
            'El token de recuperación no es válido'
        });
      }

      // ------------------------------------------------
      // VERIFICAR EXPIRACIÓN
      // ------------------------------------------------

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

      // ------------------------------------------------
      // ENCRIPTAR NUEVA CONTRASEÑA
      // ------------------------------------------------

      cuenta.password =
        await bcrypt.hash(
          nuevaPassword,
          10
        );

      // ------------------------------------------------
      // LIMPIAR TOKEN
      // ------------------------------------------------

      cuenta.tokenRecuperacion = null;

      cuenta.tokenRecuperacionExpiracion =
        null;

      await cuenta.save();

      // ------------------------------------------------
      // RESPUESTA
      // ------------------------------------------------

      return res.status(200).json({
        mensaje:
          'Contraseña restablecida correctamente'
      });

    } catch (error) {
      console.error(
        'Error al restablecer contraseña del sitio:',
        error
      );

      return res.status(500).json({
        mensaje:
          'Error al restablecer la contraseña'
      });
    }
  };

// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  crearCuentaSitio,
  iniciarSesion,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
};