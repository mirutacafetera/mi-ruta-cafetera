const bcrypt = require('bcryptjs');

const jwt = require('jsonwebtoken');

const crypto = require('crypto');

const Usuario = require(
  '../../models/usuario/usuario'
);

const {
  enviarCodigoVerificacion,
  enviarCodigoRecuperacion
} = require('../../utils/mailer');

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

      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        correo: usuario.correo,
        telefono: usuario.telefono,
        ciudad: usuario.ciudad,
        fotoPerfil: usuario.fotoPerfil
      }
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
// OBTENER USUARIO
// =====================================================

const obtenerUsuario = async (req, res) => {
  try {
    const usuario =
      await Usuario
        .findById(req.params.id)
        .select('-password');

    if (!usuario) {
      return res.status(404).json({
        mensaje:
          'Usuario no encontrado'
      });
    }

    return res.status(200).json(
      usuario
    );
  } catch (error) {
    console.error(
      'Error al obtener usuario:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al obtener el usuario',
      error: error.message
    });
  }
};

// =====================================================
// ACTUALIZAR USUARIO
// =====================================================

const actualizarUsuario = async (
  req,
  res
) => {
  try {
    const {
      nombre,
      apellido,
      telefono,
      ciudad,
      fotoPerfil
    } = req.body;

    // -------------------------------------------------
    // VERIFICAR PROPIETARIO
    // -------------------------------------------------

    if (
      req.usuario.id !==
      req.params.id
    ) {
      return res.status(403).json({
        mensaje:
          'No puedes modificar otro usuario'
      });
    }

    // -------------------------------------------------
    // ACTUALIZAR DATOS
    // -------------------------------------------------

    const usuario =
      await Usuario.findByIdAndUpdate(
        req.params.id,
        {
          nombre,
          apellido,
          telefono,
          ciudad,
          fotoPerfil
        },
        {
          new: true,
          runValidators: true
        }
      ).select('-password');

    if (!usuario) {
      return res.status(404).json({
        mensaje:
          'Usuario no encontrado'
      });
    }

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Perfil actualizado correctamente',

      usuario
    });
  } catch (error) {
    console.error(
      'Error al actualizar usuario:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al actualizar el perfil',
      error: error.message
    });
  }
};

// =====================================================
// ELIMINAR USUARIO
// =====================================================

const eliminarUsuario = async (
  req,
  res
) => {
  try {
    // -------------------------------------------------
    // VERIFICAR PROPIETARIO
    // -------------------------------------------------

    if (
      req.usuario.id !==
      req.params.id
    ) {
      return res.status(403).json({
        mensaje:
          'No puedes eliminar otro usuario'
      });
    }

    // -------------------------------------------------
    // ELIMINAR USUARIO
    // -------------------------------------------------

    const usuario =
      await Usuario.findByIdAndDelete(
        req.params.id
      );

    if (!usuario) {
      return res.status(404).json({
        mensaje:
          'Usuario no encontrado'
      });
    }

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      mensaje:
        'Cuenta eliminada correctamente'
    });
  } catch (error) {
    console.error(
      'Error al eliminar usuario:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al eliminar la cuenta',
      error: error.message
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
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
};