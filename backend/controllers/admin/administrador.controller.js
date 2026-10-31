
// =====================================================
// CONTROLADOR DE AUTENTICACIÓN Y GESTIÓN DE ADMINISTRADORES
// =====================================================

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const Administrador = require('../../models/admin/administrador');

const {
  enviarCodigoVerificacion,
  enviarCodigoRecuperacion
} = require('../../utils/mailer');

// =====================================================
// GENERAR CÓDIGO DE 6 DÍGITOS
// =====================================================

const generarCodigo = () =>
  Math.floor(100000 + Math.random() * 900000).toString();

// =====================================================
// REGISTRAR ADMINISTRADOR
// =====================================================

const registrarAdministrador = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      correo,
      password,
      telefono
    } = req.body;

    if (!nombre || !apellido || !correo || !password) {
      return res.status(400).json({
        mensaje:
          'Nombre, apellido, correo y contraseña son obligatorios'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        mensaje:
          'La contraseña debe tener mínimo 6 caracteres'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const administradorExistente =
      await Administrador.findOne({
        correo: correoNormalizado
      });

    if (administradorExistente) {
      return res.status(400).json({
        mensaje:
          'El correo ya está registrado como administrador'
      });
    }

    const codigoVerificacion = generarCodigo();

    const administrador = new Administrador({
      nombre,
      apellido,
      correo: correoNormalizado,
      password,
      telefono,
      fotoPerfil: null,
      activo: true,
      isVerified: false,
      codigoVerificacion,
      codigoVerificacionExpiracion:
        new Date(Date.now() + 10 * 60 * 1000),
      codigoRecuperacion: null,
      codigoRecuperacionExpiracion: null,
      tokenRecuperacion: null,
      tokenRecuperacionExpiracion: null
    });

    await administrador.save();

    await enviarCodigoVerificacion(
      administrador.correo,
      administrador.nombre,
      codigoVerificacion
    );

    return res.status(201).json({
      mensaje:
        'Administrador registrado correctamente. Revisa tu correo para verificar tu cuenta.',
      administrador: {
        id: administrador._id,
        nombre: administrador.nombre,
        apellido: administrador.apellido,
        correo: administrador.correo,
        telefono: administrador.telefono,
        fotoPerfil: administrador.fotoPerfil,
        activo: administrador.activo,
        isVerified: administrador.isVerified
      }
    });
  } catch (error) {
    console.error(
      'Error al registrar administrador:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al registrar administrador',
      error: error.message
    });
  }
};

// =====================================================
// VERIFICAR CORREO DEL ADMINISTRADOR
// =====================================================

const verificarCodigoVerificacionAdministrador = async (
  req,
  res
) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje: 'Correo y código son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const administrador = await Administrador.findOne({
      correo: correoNormalizado
    });

    if (!administrador) {
      return res.status(404).json({
        mensaje: 'Administrador no encontrado'
      });
    }

    if (administrador.isVerified) {
      return res.status(400).json({
        mensaje: 'El correo ya está verificado'
      });
    }

    if (
      !administrador.codigoVerificacion ||
      !administrador.codigoVerificacionExpiracion ||
      administrador.codigoVerificacionExpiracion < new Date()
    ) {
      administrador.codigoVerificacion = null;
      administrador.codigoVerificacionExpiracion = null;

      await administrador.save();

      return res.status(400).json({
        mensaje: 'El código de verificación ha expirado'
      });
    }

    if (
      administrador.codigoVerificacion !==
      codigo.toString().trim()
    ) {
      return res.status(400).json({
        mensaje:
          'El código de verificación es incorrecto'
      });
    }

    administrador.isVerified = true;
    administrador.codigoVerificacion = null;
    administrador.codigoVerificacionExpiracion = null;

    await administrador.save();

    return res.status(200).json({
      mensaje:
        'Correo del administrador verificado correctamente. Ya puedes iniciar sesión.',
      administrador: {
        id: administrador._id,
        nombre: administrador.nombre,
        apellido: administrador.apellido,
        correo: administrador.correo,
        telefono: administrador.telefono,
        fotoPerfil: administrador.fotoPerfil,
        isVerified: administrador.isVerified
      }
    });
  } catch (error) {
    console.error(
      'Error al verificar correo:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al verificar el correo del administrador',
      error: error.message
    });
  }
};

// =====================================================
// INICIAR SESIÓN DEL ADMINISTRADOR
// =====================================================

const iniciarSesionAdministrador = async (req, res) => {
  try {
    const { correo, password } = req.body;

    if (!correo || !password) {
      return res.status(400).json({
        mensaje:
          'Correo y contraseña son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const administrador = await Administrador
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

    if (!administrador.activo) {
      return res.status(403).json({
        mensaje:
          'La cuenta del administrador está inactiva'
      });
    }

    if (!administrador.isVerified) {
      return res.status(403).json({
        mensaje:
          'Debes verificar tu correo antes de iniciar sesión'
      });
    }

    const passwordCorrecta = await bcrypt.compare(
      password,
      administrador.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje:
          'Correo o contraseña incorrectos'
      });
    }

    const token = jwt.sign(
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

    return res.status(200).json({
      mensaje:
        'Inicio de sesión de administrador exitoso',
      token,
      administrador: {
        id: administrador._id,
        nombre: administrador.nombre,
        apellido: administrador.apellido,
        correo: administrador.correo,
        telefono: administrador.telefono,
        fotoPerfil: administrador.fotoPerfil,
        activo: administrador.activo,
        isVerified: administrador.isVerified,
        rol: 'admin'
      }
    });
  } catch (error) {
    console.error(
      'Error al iniciar sesión:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al iniciar sesión del administrador',
      error: error.message
    });
  }
};

// =====================================================
// SOLICITAR RECUPERACIÓN DE CONTRASEÑA
// =====================================================

const solicitarRecuperacionAdministrador = async (
  req,
  res
) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return res.status(400).json({
        mensaje: 'El correo es obligatorio'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const administrador = await Administrador.findOne({
      correo: correoNormalizado
    });

    if (!administrador) {
      return res.status(404).json({
        mensaje:
          'No existe un administrador con ese correo'
      });
    }

    if (!administrador.isVerified) {
      return res.status(403).json({
        mensaje:
          'Debes verificar tu correo antes de recuperar la contraseña'
      });
    }

    const codigoRecuperacion = generarCodigo();

    administrador.codigoRecuperacion =
      codigoRecuperacion;

    administrador.codigoRecuperacionExpiracion =
      new Date(Date.now() + 10 * 60 * 1000);

    administrador.tokenRecuperacion = null;
    administrador.tokenRecuperacionExpiracion = null;

    await administrador.save();

    await enviarCodigoRecuperacion(
      administrador.correo,
      administrador.nombre,
      codigoRecuperacion
    );

    return res.status(200).json({
      mensaje:
        'Código de recuperación enviado a tu correo'
    });
  } catch (error) {
    console.error(
      'Error al solicitar recuperación:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al solicitar recuperación',
      error: error.message
    });
  }
};

// =====================================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// =====================================================

const verificarCodigoRecuperacionAdministrador = async (
  req,
  res
) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje: 'Correo y código son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const administrador = await Administrador.findOne({
      correo: correoNormalizado
    });

    if (!administrador) {
      return res.status(404).json({
        mensaje: 'Administrador no encontrado'
      });
    }

    if (
      !administrador.codigoRecuperacion ||
      !administrador.codigoRecuperacionExpiracion ||
      administrador.codigoRecuperacionExpiracion < new Date()
    ) {
      administrador.codigoRecuperacion = null;
      administrador.codigoRecuperacionExpiracion = null;

      await administrador.save();

      return res.status(400).json({
        mensaje:
          'El código de recuperación ha expirado'
      });
    }

    if (
      administrador.codigoRecuperacion !==
      codigo.toString().trim()
    ) {
      return res.status(400).json({
        mensaje:
          'El código de recuperación es incorrecto'
      });
    }

    const tokenRecuperacion =
      crypto.randomBytes(32).toString('hex');

    administrador.tokenRecuperacion =
      tokenRecuperacion;

    administrador.tokenRecuperacionExpiracion =
      new Date(Date.now() + 10 * 60 * 1000);

    administrador.codigoRecuperacion = null;
    administrador.codigoRecuperacionExpiracion = null;

    await administrador.save();

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

// =====================================================
// RESTABLECER CONTRASEÑA
// =====================================================

const restablecerPasswordAdministrador = async (
  req,
  res
) => {
  try {
    const {
      tokenRecuperacion,
      nuevaPassword
    } = req.body;

    if (!tokenRecuperacion || !nuevaPassword) {
      return res.status(400).json({
        mensaje:
          'Token de recuperación y nueva contraseña son obligatorios'
      });
    }

    if (nuevaPassword.length < 6) {
      return res.status(400).json({
        mensaje:
          'La contraseña debe tener mínimo 6 caracteres'
      });
    }

    const administrador = await Administrador.findOne({
      tokenRecuperacion
    });

    if (!administrador) {
      return res.status(400).json({
        mensaje:
          'Token de recuperación inválido'
      });
    }

    if (
      !administrador.tokenRecuperacionExpiracion ||
      administrador.tokenRecuperacionExpiracion < new Date()
    ) {
      administrador.tokenRecuperacion = null;
      administrador.tokenRecuperacionExpiracion = null;

      await administrador.save();

      return res.status(400).json({
        mensaje:
          'El token de recuperación ha expirado'
      });
    }

    administrador.password = nuevaPassword;
    administrador.tokenRecuperacion = null;
    administrador.tokenRecuperacionExpiracion = null;

    await administrador.save();

    return res.status(200).json({
      mensaje:
        'Contraseña del administrador restablecida correctamente'
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

// =====================================================
// OBTENER ADMINISTRADOR POR ID
// =====================================================

const obtenerAdministrador = async (req, res) => {
  try {
    const administrador = await Administrador
      .findById(req.params.id)
      .select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje:
          'Administrador no encontrado'
      });
    }

    return res.status(200).json(administrador);
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
// ACTUALIZAR DATOS DEL ADMINISTRADOR
// =====================================================

const actualizarAdministrador = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      telefono
    } = req.body;

    if (
      req.usuario &&
      req.usuario.id !== req.params.id
    ) {
      return res.status(403).json({
        mensaje:
          'No puedes modificar otro administrador'
      });
    }

    const administrador = await Administrador
      .findByIdAndUpdate(
        req.params.id,
        {
          nombre,
          apellido,
          telefono
        },
        {
          returnDocument: 'after',
          runValidators: true
        }
      )
      .select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje:
          'Administrador no encontrado'
      });
    }

    return res.status(200).json({
      mensaje:
        'Administrador actualizado correctamente',
      administrador
    });
  } catch (error) {
    console.error(
      'Error al actualizar administrador:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al actualizar administrador',
      error: error.message
    });
  }
};

// =====================================================
// SUBIR O ACTUALIZAR FOTO DE PERFIL
// =====================================================

const subirFotoAdministrador = async (req, res) => {
  try {
    const { id } = req.params;

    if (
      req.usuario &&
      req.usuario.id !== id
    ) {
      return res.status(403).json({
        mensaje:
          'No puedes modificar la foto de otro administrador'
      });
    }

    if (!req.file || !req.file.path) {
      return res.status(400).json({
        mensaje:
          'Debes seleccionar una imagen de perfil'
      });
    }

    const administrador = await Administrador
      .findByIdAndUpdate(
        id,
        {
          fotoPerfil: req.file.path
        },
        {
          returnDocument: 'after',
          runValidators: true
        }
      )
      .select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje:
          'Administrador no encontrado'
      });
    }

    return res.status(200).json({
      mensaje:
        'Foto de perfil actualizada correctamente',
      administrador
    });
  } catch (error) {
    console.error(
      'Error al subir la foto del administrador:',
      error
    );

    return res.status(500).json({
      mensaje:
        'No fue posible actualizar la foto de perfil',
      error: error.message
    });
  }
};

// =====================================================
// ACTIVAR O DESACTIVAR ADMINISTRADOR
// =====================================================

const cambiarEstadoAdministrador = async (
  req,
  res
) => {
  try {
    const { activo } = req.body;

    if (typeof activo !== 'boolean') {
      return res.status(400).json({
        mensaje:
          'El campo activo debe ser true o false'
      });
    }

    const administrador = await Administrador
      .findByIdAndUpdate(
        req.params.id,
        { activo },
        {
          returnDocument: 'after',
          runValidators: true
        }
      )
      .select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje:
          'Administrador no encontrado'
      });
    }

    return res.status(200).json({
      mensaje: activo
        ? 'Administrador activado correctamente'
        : 'Administrador desactivado correctamente',
      administrador
    });
  } catch (error) {
    console.error(
      'Error al cambiar estado:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al cambiar estado del administrador',
      error: error.message
    });
  }
};

// =====================================================
// EXPORTAR CONTROLADORES
// =====================================================

module.exports = {
  registrarAdministrador,
  verificarCodigoVerificacionAdministrador,
  iniciarSesionAdministrador,
  solicitarRecuperacionAdministrador,
  verificarCodigoRecuperacionAdministrador,
  restablecerPasswordAdministrador,
  obtenerAdministrador,
  actualizarAdministrador,
  cambiarEstadoAdministrador,
  subirFotoAdministrador
};
