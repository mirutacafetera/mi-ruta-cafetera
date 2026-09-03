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

const generarCodigo = () => {

  return Math.floor(
    100000 + Math.random() * 900000
  ).toString();

};


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
    // CREAR ADMINISTRADOR
    // -------------------------------------------------

    const administrador =
      new Administrador({

        nombre,

        apellido,

        correo:
          correoNormalizado,

        password,

        telefono,

        activo:
          true,

        isVerified:
          false,

        codigoVerificacion,

        codigoVerificacionExpiracion,

        codigoRecuperacion:
          null,

        codigoRecuperacionExpiracion:
          null,

        tokenRecuperacion:
          null,

        tokenRecuperacionExpiracion:
          null

      });


    // -------------------------------------------------
    // GUARDAR ADMINISTRADOR
    // -------------------------------------------------

    await administrador.save();


    // -------------------------------------------------
    // ENVIAR CÓDIGO POR CORREO
    // -------------------------------------------------

    await enviarCodigoVerificacion(
      administrador.correo,
      administrador.nombre,
      codigoVerificacion
    );


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(201).json({

      mensaje:
        'Administrador registrado correctamente. Revisa tu correo para verificar tu cuenta.',

      administrador: {

        id:
          administrador._id,

        nombre:
          administrador.nombre,

        apellido:
          administrador.apellido,

        correo:
          administrador.correo,

        telefono:
          administrador.telefono,

        activo:
          administrador.activo,

        isVerified:
          administrador.isVerified

      }

    });

  } catch (error) {

    console.error(
      'Error al registrar administrador:',
      error
    );

    return res.status(500).json({

      mensaje:
        'Error al registrar administrador',

      error:
        error.message

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
    // BUSCAR ADMINISTRADOR
    // -------------------------------------------------

    const administrador =
      await Administrador.findOne({

        correo:
          correoNormalizado

      });


    if (!administrador) {

      return res.status(404).json({

        mensaje:
          'Administrador no encontrado'

      });

    }


    // -------------------------------------------------
    // VERIFICAR SI YA ESTÁ VERIFICADO
    // -------------------------------------------------

    if (administrador.isVerified) {

      return res.status(400).json({

        mensaje:
          'El correo ya está verificado'

      });

    }


    // -------------------------------------------------
    // VERIFICAR QUE EXISTA EL CÓDIGO
    // -------------------------------------------------

    if (!administrador.codigoVerificacion) {

      return res.status(400).json({

        mensaje:
          'No existe un código de verificación activo'

      });

    }


    // -------------------------------------------------
    // VERIFICAR EXPIRACIÓN
    // -------------------------------------------------

    if (
      !administrador.codigoVerificacionExpiracion ||
      administrador.codigoVerificacionExpiracion <
        new Date()
    ) {

      administrador.codigoVerificacion =
        null;

      administrador.codigoVerificacionExpiracion =
        null;

      await administrador.save();


      return res.status(400).json({

        mensaje:
          'El código de verificación ha expirado'

      });

    }


    // -------------------------------------------------
    // COMPARAR CÓDIGO
    // -------------------------------------------------

    if (
      administrador.codigoVerificacion !==
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

    administrador.isVerified =
      true;


    // -------------------------------------------------
    // ELIMINAR CÓDIGO UTILIZADO
    // -------------------------------------------------

    administrador.codigoVerificacion =
      null;

    administrador.codigoVerificacionExpiracion =
      null;


    await administrador.save();


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({

      mensaje:
        'Correo del administrador verificado correctamente. Ya puedes iniciar sesión.',

      administrador: {

        id:
          administrador._id,

        nombre:
          administrador.nombre,

        apellido:
          administrador.apellido,

        correo:
          administrador.correo,

        isVerified:
          administrador.isVerified

      }

    });

  } catch (error) {

    console.error(
      'Error al verificar correo del administrador:',
      error
    );

    return res.status(500).json({

      mensaje:
        'Error al verificar el correo del administrador',

      error:
        error.message

    });

  }

};


// =====================================================
// INICIAR SESIÓN ADMINISTRADOR
// =====================================================

const iniciarSesionAdministrador = async (
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
    // BUSCAR ADMINISTRADOR
    // -------------------------------------------------
    // password tiene select:false,
    // por eso utilizamos .select('+password')
    // -------------------------------------------------

    const administrador =
      await Administrador
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
    // VERIFICAR CORREO
    // -------------------------------------------------

    if (!administrador.isVerified) {

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

          id:
            administrador._id.toString(),

          correo:
            administrador.correo,

          rol:
            'admin'

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
        'Inicio de sesión de administrador exitoso',

      token,

      administrador: {

        id:
          administrador._id,

        nombre:
          administrador.nombre,

        apellido:
          administrador.apellido,

        correo:
          administrador.correo,

        telefono:
          administrador.telefono,

        activo:
          administrador.activo,

        isVerified:
          administrador.isVerified,

        rol:
          'admin'

      }

    });

  } catch (error) {

    console.error(
      'Error al iniciar sesión del administrador:',
      error
    );

    return res.status(500).json({

      mensaje:
        'Error al iniciar sesión del administrador',

      error:
        error.message

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
    // BUSCAR ADMINISTRADOR
    // -------------------------------------------------

    const administrador =
      await Administrador.findOne({

        correo:
          correoNormalizado

      });


    if (!administrador) {

      return res.status(404).json({

        mensaje:
          'No existe un administrador con ese correo'

      });

    }


    // -------------------------------------------------
    // VERIFICAR QUE LA CUENTA ESTÉ VERIFICADA
    // -------------------------------------------------

    if (!administrador.isVerified) {

      return res.status(403).json({

        mensaje:
          'Debes verificar tu correo antes de recuperar la contraseña'

      });

    }


    // -------------------------------------------------
    // GENERAR CÓDIGO
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

    administrador.codigoRecuperacion =
      codigoRecuperacion;

    administrador.codigoRecuperacionExpiracion =
      codigoRecuperacionExpiracion;


    // -------------------------------------------------
    // ELIMINAR TOKEN ANTERIOR
    // -------------------------------------------------

    administrador.tokenRecuperacion =
      null;

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
        'Código de recuperación enviado a tu correo'

    });

  } catch (error) {

    console.error(
      'Error al solicitar recuperación del administrador:',
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

const verificarCodigoRecuperacionAdministrador = async (
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
    // BUSCAR ADMINISTRADOR
    // -------------------------------------------------

    const administrador =
      await Administrador.findOne({

        correo:
          correoNormalizado

      });


    if (!administrador) {

      return res.status(404).json({

        mensaje:
          'Administrador no encontrado'

      });

    }


    // -------------------------------------------------
    // VERIFICAR CÓDIGO
    // -------------------------------------------------

    if (!administrador.codigoRecuperacion) {

      return res.status(400).json({

        mensaje:
          'No existe un código de recuperación activo'

      });

    }


    // -------------------------------------------------
    // VERIFICAR EXPIRACIÓN
    // -------------------------------------------------

    if (
      !administrador.codigoRecuperacionExpiracion ||
      administrador.codigoRecuperacionExpiracion <
        new Date()
    ) {

      administrador.codigoRecuperacion =
        null;

      administrador.codigoRecuperacionExpiracion =
        null;

      await administrador.save();


      return res.status(400).json({

        mensaje:
          'El código de recuperación ha expirado'

      });

    }


    // -------------------------------------------------
    // COMPARAR CÓDIGO
    // -------------------------------------------------

    if (
      administrador.codigoRecuperacion !==
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

    administrador.tokenRecuperacion =
      tokenRecuperacion;

    administrador.tokenRecuperacionExpiracion =
      tokenRecuperacionExpiracion;


    // -------------------------------------------------
    // ELIMINAR CÓDIGO UTILIZADO
    // -------------------------------------------------

    administrador.codigoRecuperacion =
      null;

    administrador.codigoRecuperacionExpiracion =
      null;


    await administrador.save();


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
      'Error al verificar código de recuperación del administrador:',
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

const restablecerPasswordAdministrador = async (
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
    // BUSCAR ADMINISTRADOR
    // -------------------------------------------------

    const administrador =
      await Administrador.findOne({

        tokenRecuperacion

      });


    if (!administrador) {

      return res.status(400).json({

        mensaje:
          'Token de recuperación inválido'

      });

    }


    // -------------------------------------------------
    // VERIFICAR EXPIRACIÓN
    // -------------------------------------------------

    if (
      !administrador.tokenRecuperacionExpiracion ||
      administrador.tokenRecuperacionExpiracion <
        new Date()
    ) {

      administrador.tokenRecuperacion =
        null;

      administrador.tokenRecuperacionExpiracion =
        null;

      await administrador.save();


      return res.status(400).json({

        mensaje:
          'El token de recuperación ha expirado'

      });

    }


    // -------------------------------------------------
    // CAMBIAR CONTRASEÑA
    // -------------------------------------------------
    // El modelo Administrador la vuelve a encriptar
    // mediante pre('save').
    // -------------------------------------------------

    administrador.password =
      nuevaPassword;


    // -------------------------------------------------
    // ELIMINAR TOKEN
    // -------------------------------------------------

    administrador.tokenRecuperacion =
      null;

    administrador.tokenRecuperacionExpiracion =
      null;


    await administrador.save();


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({

      mensaje:
        'Contraseña del administrador restablecida correctamente'

    });

  } catch (error) {

    console.error(
      'Error al restablecer contraseña del administrador:',
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
// OBTENER ADMINISTRADOR
// =====================================================

const obtenerAdministrador = async (
  req,
  res
) => {

  try {

    const administrador =
      await Administrador
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

      error:
        error.message

    });

  }

};


// =====================================================
// ACTUALIZAR ADMINISTRADOR
// =====================================================

const actualizarAdministrador = async (
  req,
  res
) => {

  try {

    const {
      nombre,
      apellido,
      telefono
    } = req.body;


    // -------------------------------------------------
    // VERIFICAR PROPIETARIO
    // -------------------------------------------------

    if (
      req.usuario &&
      req.usuario.id !==
        req.params.id
    ) {

      return res.status(403).json({

        mensaje:
          'No puedes modificar otro administrador'

      });

    }


    // -------------------------------------------------
    // BUSCAR Y ACTUALIZAR
    // -------------------------------------------------

    const administrador =
      await Administrador.findByIdAndUpdate(

        req.params.id,

        {
          nombre,
          apellido,
          telefono
        },

        {
          new: true,
          runValidators: true
        }

      ).select('-password');


    if (!administrador) {

      return res.status(404).json({

        mensaje:
          'Administrador no encontrado'

      });

    }


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

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

      error:
        error.message

    });

  }

};


// =====================================================
// CAMBIAR ESTADO DEL ADMINISTRADOR
// =====================================================

const cambiarEstadoAdministrador = async (
  req,
  res
) => {

  try {

    const {
      activo
    } = req.body;


    // -------------------------------------------------
    // VALIDAR ACTIVO
    // -------------------------------------------------

    if (typeof activo !== 'boolean') {

      return res.status(400).json({

        mensaje:
          'El campo activo debe ser true o false'

      });

    }


    // -------------------------------------------------
    // ACTUALIZAR ESTADO
    // -------------------------------------------------

    const administrador =
      await Administrador.findByIdAndUpdate(

        req.params.id,

        {
          activo
        },

        {
          new: true,
          runValidators: true
        }

      ).select('-password');


    if (!administrador) {

      return res.status(404).json({

        mensaje:
          'Administrador no encontrado'

      });

    }


    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({

      mensaje:
        activo
          ? 'Administrador activado correctamente'
          : 'Administrador desactivado correctamente',

      administrador

    });

  } catch (error) {

    console.error(
      'Error al cambiar estado del administrador:',
      error
    );

    return res.status(500).json({

      mensaje:
        'Error al cambiar estado del administrador',

      error:
        error.message

    });

  }

};


// =====================================================
// EXPORTAR
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

  cambiarEstadoAdministrador

};