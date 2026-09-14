const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const AuthSitio = require('../../models/admin/authsitio');

// ======================================================
// CREAR CUENTA DEL SITIO
// ======================================================

const crearCuentaSitio = async (req, res) => {
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

    // Verificar si ya existe
    const sitioExistente = await AuthSitio.findOne({
      correo: correo.toLowerCase().trim()
    });

    if (sitioExistente) {
      return res.status(400).json({
        mensaje:
          'Ya existe una cuenta de sitio con este correo'
      });
    }

    // Encriptar contraseña
    const passwordEncriptada =
      await bcrypt.hash(password, 10);

    // Crear cuenta
    const nuevoSitio = new AuthSitio({
      nombre,
      apellido,
      correo: correo.toLowerCase().trim(),
      password: passwordEncriptada,
      telefono
    });

    await nuevoSitio.save();

    return res.status(201).json({
      mensaje:
        'Cuenta del sitio creada correctamente',

      sitio: {
        id: nuevoSitio._id,
        nombre: nuevoSitio.nombre,
        apellido: nuevoSitio.apellido,
        correo: nuevoSitio.correo,
        telefono: nuevoSitio.telefono,
        rol: nuevoSitio.rol,
        activo: nuevoSitio.activo
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

// ======================================================
// INICIAR SESIÓN DEL SITIO
// ======================================================

const iniciarSesionSitio = async (req, res) => {
  try {
    const {
      correo,
      password
    } = req.body;

    if (!correo || !password) {
      return res.status(400).json({
        mensaje:
          'Correo y contraseña son obligatorios'
      });
    }

    const sitio = await AuthSitio
      .findOne({
        correo: correo.toLowerCase().trim()
      })
      .select('+password');

    if (!sitio) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    if (!sitio.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del sitio está inactiva'
      });
    }

    const passwordCorrecta =
      await bcrypt.compare(
        password,
        sitio.password
      );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    const token = jwt.sign(
      {
        id: sitio._id.toString(),
        correo: sitio.correo,
        rol: 'sitio'
      },
      process.env.JWT_SECRET,
      {
        expiresIn:
          process.env.JWT_EXPIRES_IN || '1d'
      }
    );

    return res.status(200).json({
      mensaje:
        'Inicio de sesión exitoso',

      token,

      sitio: {
        id: sitio._id,
        nombre: sitio.nombre,
        apellido: sitio.apellido,
        correo: sitio.correo,
        telefono: sitio.telefono,
        rol: sitio.rol,
        activo: sitio.activo
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

// ======================================================
// OBTENER CUENTA DEL SITIO
// ======================================================

const obtenerSitio = async (req, res) => {
  try {
    const { id } = req.params;

    const sitio = await AuthSitio.findById(id);

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Cuenta del sitio no encontrada'
      });
    }

    return res.status(200).json(sitio);

  } catch (error) {

    console.error(
      'Error al obtener sitio:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al obtener la cuenta del sitio'
    });
  }
};

// ======================================================
// SOLICITAR RECUPERACIÓN DE CONTRASEÑA
// ======================================================

const recuperarPasswordSitio = async (req, res) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return res.status(400).json({
        mensaje:
          'El correo es obligatorio'
      });
    }

    const sitio = await AuthSitio.findOne({
      correo: correo.toLowerCase().trim()
    });

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'No existe una cuenta con este correo'
      });
    }

    const codigo =
      crypto.randomInt(100000, 1000000).toString();

    sitio.codigoRecuperacion = codigo;

    sitio.codigoRecuperacionExpiracion =
      new Date(Date.now() + 10 * 60 * 1000);

    await sitio.save();

    // Por ahora devolvemos el código para poder probar.
    // Después podemos conectarlo con tu sistema de correo.

    return res.status(200).json({
      mensaje:
        'Código de recuperación generado',

      codigo
    });

  } catch (error) {

    console.error(
      'Error en recuperación:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al solicitar recuperación'
    });
  }
};

// ======================================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// ======================================================

const verificarCodigoRecuperacionSitio = async (
  req,
  res
) => {
  try {
    const {
      correo,
      codigo
    } = req.body;

    const sitio = await AuthSitio.findOne({
      correo: correo.toLowerCase().trim()
    });

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Cuenta del sitio no encontrada'
      });
    }

    if (
      sitio.codigoRecuperacion !== codigo
    ) {
      return res.status(400).json({
        mensaje:
          'Código de recuperación incorrecto'
      });
    }

    if (
      !sitio.codigoRecuperacionExpiracion ||
      sitio.codigoRecuperacionExpiracion <
        new Date()
    ) {
      return res.status(400).json({
        mensaje:
          'El código de recuperación ha expirado'
      });
    }

    return res.status(200).json({
      mensaje:
        'Código de recuperación válido'
    });

  } catch (error) {

    console.error(
      'Error verificando código:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al verificar el código'
    });
  }
};

// ======================================================
// RESTABLECER CONTRASEÑA
// ======================================================

const restablecerPasswordSitio = async (
  req,
  res
) => {
  try {
    const {
      correo,
      codigo,
      nuevaPassword
    } = req.body;

    if (
      !correo ||
      !codigo ||
      !nuevaPassword
    ) {
      return res.status(400).json({
        mensaje:
          'Correo, código y nueva contraseña son obligatorios'
      });
    }

    const sitio = await AuthSitio
      .findOne({
        correo: correo.toLowerCase().trim()
      })
      .select('+password');

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Cuenta del sitio no encontrada'
      });
    }

    if (
      sitio.codigoRecuperacion !== codigo
    ) {
      return res.status(400).json({
        mensaje:
          'Código de recuperación incorrecto'
      });
    }

    if (
      !sitio.codigoRecuperacionExpiracion ||
      sitio.codigoRecuperacionExpiracion <
        new Date()
    ) {
      return res.status(400).json({
        mensaje:
          'El código de recuperación ha expirado'
      });
    }

    sitio.password =
      await bcrypt.hash(
        nuevaPassword,
        10
      );

    sitio.codigoRecuperacion = null;
    sitio.codigoRecuperacionExpiracion = null;

    await sitio.save();

    return res.status(200).json({
      mensaje:
        'Contraseña restablecida correctamente'
    });

  } catch (error) {

    console.error(
      'Error restableciendo contraseña:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al restablecer la contraseña'
    });
  }
};

// ======================================================
// EXPORTAR FUNCIONES
// ======================================================

module.exports = {
  crearCuentaSitio,
  iniciarSesionSitio,
  obtenerSitio,
  recuperarPasswordSitio,
  verificarCodigoRecuperacionSitio,
  restablecerPasswordSitio
};