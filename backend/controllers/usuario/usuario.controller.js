const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const Usuario = require('../../models/usuario/usuario');

const {
  enviarCodigoVerificacion,
  enviarCodigoRecuperacion
} = require('../../utils/mailer');


// =====================================================
// GENERAR CÓDIGO DE 6 DÍGITOS
// =====================================================

const generarCodigo = () => {
  return Math.floor(
    100000 + Math.random() * 900000
  ).toString();
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
    // VALIDAR CONTRASEÑA
    // -------------------------------------------------

    if (password.length < 6) {
      return res.status(400).json({
        mensaje:
          'La contraseña debe tener mínimo 6 caracteres'
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
        mensaje:
          'El correo ya está registrado'
      });
    }


    // -------------------------------------------------
    // GENERAR CÓDIGO DE VERIFICACIÓN
    // -------------------------------------------------

    const codigoVerificacion =
      generarCodigo();


    // -------------------------------------------------
    // CÓDIGO VÁLIDO DURANTE 10 MINUTOS
    // -------------------------------------------------

    const codigoVerificacionExpiracion =
      new Date(
        Date.now() + 10 * 60 * 1000
      );


    // -------------------------------------------------
    // CREAR USUARIO
    // -------------------------------------------------
    // La contraseña NO se encripta aquí.
    //
    // El modelo Usuario la encripta automáticamente
    // mediante:
    //
    // usuarioSchema.pre('save', ...)
    // -------------------------------------------------

    const usuario = new Usuario({

      nombre,

      apellido,

      correo: correoNormalizado,

      password,

      telefono,

      ciudad,

      fotoPerfil,

      isVerified: false,

      codigoVerificacion,

      codigoVerificacionExpiracion,

      codigoRecuperacion: null,

      codigoRecuperacionExpiracion: null,

      tokenRecuperacion: null,

      tokenRecuperacionExpiracion: null,

      rol: 'usuario'

    });


    // -------------------------------------------------
    // GUARDAR USUARIO
    // -------------------------------------------------

    await usuario.save();


    // -------------------------------------------------
    // ENVIAR CÓDIGO POR BREVO
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

        id:
          usuario._id,

        nombre:
          usuario.nombre,

        apellido:
          usuario.apellido,

        correo:
          usuario.correo,

        telefono:
          usuario.telefono,

        ciudad:
          usuario.ciudad,

        fotoPerfil:
          usuario.fotoPerfil,

        isVerified:
          usuario.isVerified

      }

    });

  } catch (error) {

    console.error(
      'Error al registrar usuario:',
      error
    );

    return res.status(500).json({

      mensaje:
        'Error al registrar usuario',

      error:
        error.message

    });
  }
};


// =====================================================
// VERIFICAR CORREO DEL USUARIO
// =====================================================

const verificarCodigoVerificacion = async (
  req,
  res
) => {

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

        correo:
          correoNormalizado

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

    if (usuario.isVerified) {

      return res.status(400).json({

        mensaje:
          'El correo ya está verificado'

      });
    }


    // -------------------------------------------------
    // VERIFICAR QUE EXISTA EL CÓDIGO
    // -------------------------------------------------

    if (!usuario.codigoVerificacion) {

      return res.status(400).json({

        mensaje:
          'No existe un código de verificación activo'

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

      usuario.codigoVerificacion =
        null;

      usuario.codigoVerificacionExpiracion =
        null;

      await usuario.save();


      return res.status(400).json({

        mensaje:
          'El código de verificación ha expirado'

      });
    }


    // -------------------------------------------------
    // COMPARAR CÓDIGO
    // -------------------------------------------------

    if (
      usuario.codigoVerificacion !==
      codigo.toString().trim()
    ) {

      return res.status(400).json({

        mensaje:
          'El código de verificación es incorrecto'

      });
    }


    // -------------------------------------------------
    // VERIFICAR CUENTA
    // -------------------------------------------------

    usuario.isVerified =
      true;


    // -------------------------------------------------
    // ELIMINAR CÓDIGO UTILIZADO
    // -------------------------------------------------

    usuario.codigoVerificacion =
      null;

    usuario.codigoVerificacionExpiracion =
      null;


    await usuario.save();


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({

      mensaje:
        'Correo verificado correctamente. Ya puedes iniciar sesión.',

      usuario: {

        id:
          usuario._id,

        nombre:
          usuario.nombre,

        apellido:
          usuario.apellido,

        correo:
          usuario.correo,

        isVerified:
          usuario.isVerified

      }

    });

  } catch (error) {

    console.error(
      'Error al verificar correo:',
      error
    );

    return res.status(500).json({

      mensaje:
        'Error al verificar el correo',

      error:
        error.message

    });
  }
};


// =====================================================
// INICIAR SESIÓN
// =====================================================

const iniciarSesionUsuario = async (
  req,
  res
) => {

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
    // password tiene select:false en el modelo,
    // por eso usamos .select('+password')
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

    if (!usuario.isVerified) {

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

          id:
            usuario._id.toString(),

          correo:
            usuario.correo,

          rol:
            usuario.rol

        },

        process.env.JWT_SECRET,

        {

          expiresIn:
            process.env.JWT_EXPIRES_IN ||
            '1d'

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

        id:
          usuario._id,

        nombre:
          usuario.nombre,

        apellido:
          usuario.apellido,

        correo:
          usuario.correo,

        telefono:
          usuario.telefono,

        ciudad:
          usuario.ciudad,

        fotoPerfil:
          usuario.fotoPerfil,

        rol:
          usuario.rol,

        isVerified:
          usuario.isVerified

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

      error:
        error.message

    });
  }
};


// =====================================================
// SOLICITAR RECUPERACIÓN DE CONTRASEÑA
// =====================================================

const solicitarRecuperacion = async (
  req,
  res
) => {

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
    // BUSCAR USUARIO
    // -------------------------------------------------

    const usuario =
      await Usuario.findOne({

        correo:
          correoNormalizado

      });


    if (!usuario) {

      return res.status(404).json({

        mensaje:
          'No existe un usuario con ese correo'

      });
    }


    // -------------------------------------------------
    // GENERAR CÓDIGO DE RECUPERACIÓN
    // -------------------------------------------------

    const codigoRecuperacion =
      generarCodigo();


    // -------------------------------------------------
    // CÓDIGO VÁLIDO DURANTE 10 MINUTOS
    // -------------------------------------------------

    const codigoRecuperacionExpiracion =
      new Date(
        Date.now() + 10 * 60 * 1000
      );


    // -------------------------------------------------
    // GUARDAR CÓDIGO
    // -------------------------------------------------

    usuario.codigoRecuperacion =
      codigoRecuperacion;

    usuario.codigoRecuperacionExpiracion =
      codigoRecuperacionExpiracion;


    // -------------------------------------------------
    // ELIMINAR TOKEN ANTERIOR
    // -------------------------------------------------

    usuario.tokenRecuperacion =
      null;

    usuario.tokenRecuperacionExpiracion =
      null;


    await usuario.save();


    // -------------------------------------------------
    // ENVIAR CÓDIGO POR BREVO
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
        'Código de recuperación enviado a tu correo'

    });

  } catch (error) {

    console.error(
      'Error al solicitar recuperación:',
      error
    );

    return res.status(500).json({

      mensaje:
        'Error al solicitar recuperación',

      error:
        error.message

    });
  }
};


// =====================================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// =====================================================

const verificarCodigoRecuperacion = async (
  req,
  res
) => {

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

        correo:
          correoNormalizado

      });


    if (!usuario) {

      return res.status(404).json({

        mensaje:
          'Usuario no encontrado'

      });
    }


    // -------------------------------------------------
    // VERIFICAR CÓDIGO
    // -------------------------------------------------

    if (!usuario.codigoRecuperacion) {

      return res.status(400).json({

        mensaje:
          'No existe un código de recuperación activo'

      });
    }


    // -------------------------------------------------
    // VERIFICAR EXPIRACIÓN
    // -------------------------------------------------

    if (
      !usuario.codigoRecuperacionExpiracion ||
      usuario.codigoRecuperacionExpiracion <
        new Date()
    ) {

      usuario.codigoRecuperacion =
        null;

      usuario.codigoRecuperacionExpiracion =
        null;

      await usuario.save();


      return res.status(400).json({

        mensaje:
          'El código de recuperación ha expirado'

      });
    }


    // -------------------------------------------------
    // COMPARAR CÓDIGO
    // -------------------------------------------------

    if (
      usuario.codigoRecuperacion !==
      codigo.toString().trim()
    ) {

      return res.status(400).json({

        mensaje:
          'El código de recuperación es incorrecto'

      });
    }


    // -------------------------------------------------
    // GENERAR TOKEN TEMPORAL
    // -------------------------------------------------

    const tokenRecuperacion =
      crypto
        .randomBytes(32)
        .toString('hex');


    // -------------------------------------------------
    // TOKEN VÁLIDO DURANTE 10 MINUTOS
    // -------------------------------------------------

    const tokenRecuperacionExpiracion =
      new Date(
        Date.now() + 10 * 60 * 1000
      );


    // -------------------------------------------------
    // GUARDAR TOKEN
    // -------------------------------------------------

    usuario.tokenRecuperacion =
      tokenRecuperacion;

    usuario.tokenRecuperacionExpiracion =
      tokenRecuperacionExpiracion;


    // -------------------------------------------------
    // EL CÓDIGO YA FUE UTILIZADO
    // -------------------------------------------------

    usuario.codigoRecuperacion =
      null;

    usuario.codigoRecuperacionExpiracion =
      null;


    await usuario.save();


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

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

      error:
        error.message

    });
  }
};


// =====================================================
// RESTABLECER CONTRASEÑA
// =====================================================

const restablecerPassword = async (
  req,
  res
) => {

  try {

    const {
      tokenRecuperacion,
      nuevaPassword
    } = req.body;


    // -------------------------------------------------
    // VALIDAR DATOS
    // -------------------------------------------------

    if (
      !tokenRecuperacion ||
      !nuevaPassword
    ) {

      return res.status(400).json({

        mensaje:
          'Token de recuperación y nueva contraseña son obligatorios'

      });
    }


    // -------------------------------------------------
    // VALIDAR CONTRASEÑA
    // -------------------------------------------------

    if (nuevaPassword.length < 6) {

      return res.status(400).json({

        mensaje:
          'La contraseña debe tener mínimo 6 caracteres'

      });
    }


    // -------------------------------------------------
    // BUSCAR USUARIO
    // -------------------------------------------------

    const usuario =
      await Usuario.findOne({

        tokenRecuperacion

      });


    if (!usuario) {

      return res.status(400).json({

        mensaje:
          'Token de recuperación inválido'

      });
    }


    // -------------------------------------------------
    // VERIFICAR EXPIRACIÓN
    // -------------------------------------------------

    if (
      !usuario.tokenRecuperacionExpiracion ||
      usuario.tokenRecuperacionExpiracion <
        new Date()
    ) {

      usuario.tokenRecuperacion =
        null;

      usuario.tokenRecuperacionExpiracion =
        null;

      await usuario.save();


      return res.status(400).json({

        mensaje:
          'El token de recuperación ha expirado'

      });
    }


    // -------------------------------------------------
    // CAMBIAR CONTRASEÑA
    // -------------------------------------------------
    // El modelo Usuario vuelve a encriptarla
    // automáticamente mediante pre('save').
    // -------------------------------------------------

    usuario.password =
      nuevaPassword;


    // -------------------------------------------------
    // ELIMINAR TOKEN
    // -------------------------------------------------

    usuario.tokenRecuperacion =
      null;

    usuario.tokenRecuperacionExpiracion =
      null;


    await usuario.save();


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

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

      error:
        error.message

    });
  }
};


// =====================================================
// OBTENER USUARIO
// =====================================================

const obtenerUsuario = async (
  req,
  res
) => {

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

      error:
        error.message

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
    // BUSCAR USUARIO
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

      error:
        error.message

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

      error:
        error.message

    });
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {

  registrarUsuario,

  verificarCodigoVerificacion,

  iniciarSesionUsuario,

  solicitarRecuperacion,

  verificarCodigoRecuperacion,

  restablecerPassword,

  obtenerUsuario,

  actualizarUsuario,

  eliminarUsuario

};