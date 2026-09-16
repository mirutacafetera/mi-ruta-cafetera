const CuentaSitio = require('../../models/sitio/auth');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { enviarCodigoRecuperacion } = require('../../utils/mailer');

// INICIAR SESIÓN

const iniciarSesion = async (req, res) => {
  try {
    const { correo, password } = req.body;

    if (!correo || !password) {
      return res.status(400).json({
        mensaje: 'Correo y contraseña son obligatorios'
      });
    }

    const cuenta = await CuentaSitio.findOne({
      correo: correo.toLowerCase().trim()
    }).select('+password');

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

    const passwordCorrecta = await bcrypt.compare(password, cuenta.password);

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    const token = jwt.sign(
      {
        id: cuenta._id,
        sitioId: cuenta.sitioId,
        correo: cuenta.correo,
        rol: 'sitio'
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      mensaje: 'Inicio de sesión del sitio exitoso',
      token,
      cuenta: {
        id: cuenta._id,
        sitioId: cuenta.sitioId,
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono,
        rol: 'sitio',
        activo: cuenta.activo
      }
    });

  } catch (error) {
    console.error('Error al iniciar sesión como sitio:', error);

    return res.status(500).json({
      mensaje: 'Error al iniciar sesión como sitio'
    });
  }
};


// RECUPERAR CONTRASEÑA

const recuperarPassword = async (req, res) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return res.status(400).json({
        mensaje: 'El correo es obligatorio'
      });
    }

    const cuenta = await CuentaSitio.findOne({
      correo: correo.toLowerCase().trim()
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
    cuenta.codigoRecuperacionExpiracion = new Date(Date.now() + 10 * 60 * 1000);
    cuenta.tokenRecuperacion = null;
    cuenta.tokenRecuperacionExpiracion = null;

    await cuenta.save();

    try {
      await enviarCodigoRecuperacion(cuenta.correo, cuenta.nombre, codigo);
    } catch (errorCorreo) {
      cuenta.codigoRecuperacion = null;
      cuenta.codigoRecuperacionExpiracion = null;
      await cuenta.save();

      console.error('Error enviando correo:', errorCorreo.message);

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

const verificarCodigoRecuperacion = async (req, res) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje: 'Correo y código son obligatorios'
      });
    }

    const cuenta = await CuentaSitio.findOne({
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
    cuenta.tokenRecuperacionExpiracion = new Date(Date.now() + 10 * 60 * 1000);
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

const restablecerPassword = async (req, res) => {
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

    const cuenta = await CuentaSitio.findOne({
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
    console.error('Error al restablecer contraseña:', error);

    return res.status(500).json({
      mensaje: 'Error al restablecer contraseña'
    });
  }
};


// EXPORTAR

module.exports = {
  iniciarSesion,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
};