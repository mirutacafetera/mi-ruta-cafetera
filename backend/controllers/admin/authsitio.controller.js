const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const AuthSitio = require('../../models/admin/authsitio');
const SitioTuristico = require('../../models/admin/sitio');
const { enviarCodigoRecuperacion } = require('../../utils/mailer');


// CREAR CUENTA DEL RESPONSABLE DEL SITIO

const crearCuentaSitio = async (req, res) => {
  try {
    const { sitioId, nombre, apellido, correo, password, telefono } = req.body;

    if (!sitioId || !nombre || !apellido || !correo || !password) {
      return res.status(400).json({
        mensaje: 'Sitio, nombre, apellido, correo y contraseña son obligatorios'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(sitioId)) {
      return res.status(400).json({
        mensaje: 'El sitioId no tiene un formato válido'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        mensaje: 'La contraseña debe tener mínimo 6 caracteres'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();
    const sitio = await SitioTuristico.findById(sitioId);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'El sitio turístico no existe'
      });
    }

    if (!sitio.activo) {
      return res.status(400).json({
        mensaje: 'El sitio turístico está inactivo'
      });
    }

    const cuentaSitioExistente = await AuthSitio.findOne({
      sitioId: sitio._id
    });

    if (cuentaSitioExistente) {
      return res.status(400).json({
        mensaje: 'Este sitio turístico ya tiene una cuenta asociada'
      });
    }

    const cuentaExistente = await AuthSitio.findOne({
      correo: correoNormalizado
    });

    if (cuentaExistente) {
      return res.status(400).json({
        mensaje: 'Ya existe una cuenta de sitio con este correo'
      });
    }

    const passwordEncriptada = await bcrypt.hash(password, 10);

    const nuevaCuenta = new AuthSitio({
      sitioId: sitio._id,
      nombre,
      apellido,
      correo: correoNormalizado,
      password: passwordEncriptada,
      telefono: telefono || '',
      rol: 'sitio',
      activo: true
    });

    await nuevaCuenta.save();

    return res.status(201).json({
      mensaje: 'Cuenta del sitio creada correctamente',
      cuenta: {
        id: nuevaCuenta._id,
        sitioId: nuevaCuenta.sitioId,
        nombre: nuevaCuenta.nombre,
        apellido: nuevaCuenta.apellido,
        correo: nuevaCuenta.correo,
        telefono: nuevaCuenta.telefono,
        rol: nuevaCuenta.rol,
        activo: nuevaCuenta.activo
      }
    });

  } catch (error) {
    console.error('Error al crear cuenta del sitio:', error);

    if (error.code === 11000) {
      if (error.keyPattern?.sitioId) {
        return res.status(400).json({
          mensaje: 'Este sitio turístico ya tiene una cuenta asociada'
        });
      }

      if (error.keyPattern?.correo) {
        return res.status(400).json({
          mensaje: 'Ya existe una cuenta de sitio con este correo'
        });
      }
    }

    return res.status(500).json({
      mensaje: 'Error al crear la cuenta del sitio'
    });
  }
};


// INICIAR SESIÓN

const iniciarSesionSitio = async (req, res) => {
  try {
    const { correo, password } = req.body;

    if (!correo || !password) {
      return res.status(400).json({
        mensaje: 'Correo y contraseña son obligatorios'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const cuenta = await AuthSitio.findOne({
      correo: correoNormalizado
    })
      .select('+password')
      .populate('sitioId');

    if (!cuenta) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje: 'La cuenta del sitio está inactiva'
      });
    }

    if (!cuenta.sitioId) {
      return res.status(403).json({
        mensaje: 'La cuenta no tiene un sitio turístico asociado'
      });
    }

    if (!cuenta.sitioId.activo) {
      return res.status(403).json({
        mensaje: 'El sitio turístico está inactivo'
      });
    }

    const passwordCorrecta = await bcrypt.compare(
      password,
      cuenta.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    const token = jwt.sign(
      {
        id: cuenta._id.toString(),
        sitioId: cuenta.sitioId._id.toString(),
        correo: cuenta.correo,
        rol: 'sitio'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRES_IN || '1d'
      }
    );

    return res.status(200).json({
      mensaje: 'Inicio de sesión exitoso',
      token,
      cuenta: {
        id: cuenta._id,
        sitioId: cuenta.sitioId._id,
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono,
        rol: cuenta.rol,
        activo: cuenta.activo
      },
      sitio: {
        id: cuenta.sitioId._id,
        nombre: cuenta.sitioId.nombre,
        descripcion: cuenta.sitioId.descripcion,
        direccion: cuenta.sitioId.direccion,
        ciudad: cuenta.sitioId.ciudad,
        departamento: cuenta.sitioId.departamento,
        latitud: cuenta.sitioId.latitud,
        longitud: cuenta.sitioId.longitud,
        categoria: cuenta.sitioId.categoria,
        activo: cuenta.sitioId.activo
      }
    });

  } catch (error) {
    console.error('Error al iniciar sesión:', error);

    return res.status(500).json({
      mensaje: 'Error al iniciar sesión'
    });
  }
};


// OBTENER CUENTA

const obtenerSitio = async (req, res) => {
  try {
    const cuenta = await AuthSitio.findById(req.params.id)
      .populate('sitioId');

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta del sitio no encontrada'
      });
    }

    return res.status(200).json(cuenta);

  } catch (error) {
    console.error('Error al obtener cuenta del sitio:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener la cuenta del sitio'
    });
  }
};


// RECUPERAR CONTRASEÑA

const recuperarPasswordSitio = async (req, res) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return res.status(400).json({
        mensaje: 'El correo es obligatorio'
      });
    }

    const correoNormalizado = correo.toLowerCase().trim();

    const cuenta = await AuthSitio.findOne({
      correo: correoNormalizado
    });

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'No existe una cuenta con este correo'
      });
    }

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje: 'La cuenta del sitio está inactiva'
      });
    }

    if (!cuenta.sitioId) {
      return res.status(403).json({
        mensaje: 'La cuenta no tiene un sitio turístico asociado'
      });
    }

    const codigo = crypto.randomInt(100000, 1000000).toString();

    cuenta.codigoRecuperacion = codigo;
    cuenta.codigoRecuperacionExpiracion =
      new Date(Date.now() + 10 * 60 * 1000);

    cuenta.tokenRecuperacion = null;
    cuenta.tokenRecuperacionExpiracion = null;

    await cuenta.save();

    try {
      await enviarCodigoRecuperacion(
        cuenta.correo,
        cuenta.nombre,
        codigo
      );
    } catch (errorCorreo) {
      cuenta.codigoRecuperacion = null;
      cuenta.codigoRecuperacionExpiracion = null;

      await cuenta.save();

      console.error(
        'Error enviando correo de recuperación:',
        errorCorreo.message
      );

      return res.status(500).json({
        mensaje: 'No fue posible enviar el código al correo'
      });
    }

    return res.status(200).json({
      mensaje: 'Código de recuperación enviado al correo'
    });

  } catch (error) {
    console.error('Error al solicitar recuperación:', error);

    return res.status(500).json({
      mensaje: 'Error al solicitar recuperación'
    });
  }
};


// VERIFICAR CÓDIGO Y GENERAR TOKEN

const verificarCodigoRecuperacionSitio = async (req, res) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje: 'Correo y código son obligatorios'
      });
    }

    const cuenta = await AuthSitio.findOne({
      correo: correo.toLowerCase().trim()
    });

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta del sitio no encontrada'
      });
    }

    if (cuenta.codigoRecuperacion !== codigo) {
      return res.status(400).json({
        mensaje: 'Código de recuperación incorrecto'
      });
    }

    if (
      !cuenta.codigoRecuperacionExpiracion ||
      cuenta.codigoRecuperacionExpiracion < new Date()
    ) {
      return res.status(400).json({
        mensaje: 'El código de recuperación ha expirado'
      });
    }

    const tokenRecuperacion = crypto.randomBytes(32).toString('hex');

    cuenta.tokenRecuperacion = tokenRecuperacion;
    cuenta.tokenRecuperacionExpiracion =
      new Date(Date.now() + 10 * 60 * 1000);

    cuenta.codigoRecuperacion = null;
    cuenta.codigoRecuperacionExpiracion = null;

    await cuenta.save();

    return res.status(200).json({
      mensaje: 'Código de recuperación válido',
      tokenRecuperacion
    });

  } catch (error) {
    console.error('Error verificando código:', error);

    return res.status(500).json({
      mensaje: 'Error al verificar el código'
    });
  }
};


// RESTABLECER CONTRASEÑA

const restablecerPasswordSitio = async (req, res) => {
  try {
    const {
      tokenRecuperacion,
      nuevaPassword,
      confirmarPassword
    } = req.body;

    if (!tokenRecuperacion || !nuevaPassword || !confirmarPassword) {
      return res.status(400).json({
        mensaje: 'Token, nueva contraseña y confirmación son obligatorios'
      });
    }

    if (nuevaPassword.length < 6) {
      return res.status(400).json({
        mensaje: 'La nueva contraseña debe tener mínimo 6 caracteres'
      });
    }

    if (nuevaPassword !== confirmarPassword) {
      return res.status(400).json({
        mensaje: 'Las contraseñas no coinciden'
      });
    }

    const cuenta = await AuthSitio.findOne({
      tokenRecuperacion
    }).select('+password');

    if (!cuenta) {
      return res.status(400).json({
        mensaje: 'El token de recuperación no es válido'
      });
    }

    if (
      !cuenta.tokenRecuperacionExpiracion ||
      cuenta.tokenRecuperacionExpiracion < new Date()
    ) {
      return res.status(400).json({
        mensaje: 'El token de recuperación ha expirado'
      });
    }

    cuenta.password = await bcrypt.hash(nuevaPassword, 10);

    cuenta.tokenRecuperacion = null;
    cuenta.tokenRecuperacionExpiracion = null;
    cuenta.codigoRecuperacion = null;
    cuenta.codigoRecuperacionExpiracion = null;

    await cuenta.save();

    return res.status(200).json({
      mensaje: 'Contraseña restablecida correctamente'
    });

  } catch (error) {
    console.error('Error restableciendo contraseña:', error);

    return res.status(500).json({
      mensaje: 'Error al restablecer la contraseña'
    });
  }
};


// ELIMINAR CUENTA

const eliminarCuentaSitio = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        mensaje: 'El ID de la cuenta no es válido'
      });
    }

    const cuenta = await AuthSitio.findById(req.params.id);

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta del sitio no encontrada'
      });
    }

    await AuthSitio.findByIdAndDelete(req.params.id);

    return res.status(200).json({
      mensaje: 'Cuenta del sitio eliminada correctamente'
    });

  } catch (error) {
    console.error('Error al eliminar cuenta:', error);

    return res.status(500).json({
      mensaje: 'Error al eliminar la cuenta del sitio'
    });
  }
};


// EXPORTAR

module.exports = {
  crearCuentaSitio,
  iniciarSesionSitio,
  obtenerSitio,
  recuperarPasswordSitio,
  verificarCodigoRecuperacionSitio,
  restablecerPasswordSitio,
  eliminarCuentaSitio
};