
const crypto = require('crypto');
const bcrypt = require('bcryptjs');

const CuentaSitio = require('../../models/sitio/auth');
const VerificacionCuentaSitio = require('../../models/admin/verificacionCuentaSitio');

const {
  enviarCodigoAutorizacionAdmin
} = require('../../utils/mailer');

// =====================================================
// GENERAR HASH DEL CÓDIGO
// =====================================================

const generarHashCodigo = (codigo) => {
  return crypto
    .createHash('sha256')
    .update(codigo)
    .digest('hex');
};

// =====================================================
// SOLICITAR CÓDIGO PARA CAMBIAR CORREO O CONTRASEÑA
// =====================================================

const solicitarCodigoCambioCuenta = async (req, res) => {
  try {
    const { cuentaId } = req.params;
    const { correo, password } = req.body;

    const adminId = req.usuario.id;

    const cuenta = await CuentaSitio.findById(cuentaId);

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta de sitio no encontrada.'
      });
    }

    const cambiarCorreo = typeof correo === 'string' &&
      correo.trim() !== '' &&
      correo.trim().toLowerCase() !== cuenta.correo;

    const cambiarPassword = typeof password === 'string' &&
      password.trim() !== '';

    if (!cambiarCorreo && !cambiarPassword) {
      return res.status(400).json({
        mensaje: 'Debes indicar el nuevo correo o la nueva contraseña.'
      });
    }

    // Si cambia el correo, también debe proporcionar una contraseña.
    if (cambiarCorreo && !cambiarPassword) {
      return res.status(400).json({
        mensaje: 'Para cambiar el correo también debes proporcionar una contraseña.'
      });
    }

    if (cambiarCorreo) {
      const correoNormalizado = correo.trim().toLowerCase();

      const correoValido = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(
        correoNormalizado
      );

      if (!correoValido) {
        return res.status(400).json({
          mensaje: 'El correo electrónico no tiene un formato válido.'
        });
      }

      const correoExistente = await CuentaSitio.findOne({
        correo: correoNormalizado,
        _id: { $ne: cuenta._id }
      });

      if (correoExistente) {
        return res.status(409).json({
          mensaje: 'El correo ya está registrado en otra cuenta.'
        });
      }
    }

    if (cambiarPassword && password.length < 6) {
      return res.status(400).json({
        mensaje: 'La contraseña debe tener al menos 6 caracteres.'
      });
    }

    // El código llega al correo nuevo si se cambia.
    // Si solo cambia la contraseña, llega al correo actual.
    const correoDestino = cambiarCorreo
      ? correo.trim().toLowerCase()
      : cuenta.correo;

    const passwordHash = cambiarPassword
      ? await bcrypt.hash(password, 10)
      : null;

    const codigo = crypto.randomInt(100000, 1000000).toString();

    const codigoHash = generarHashCodigo(codigo);

    const expiracion = new Date(Date.now() + 10 * 60 * 1000);

    // Eliminar solicitudes anteriores de esta cuenta y administrador.
    await VerificacionCuentaSitio.deleteMany({
      cuentaId: cuenta._id,
      adminId
    });

    const verificacion = new VerificacionCuentaSitio({
      cuentaId: cuenta._id,
      adminId,
      correoDestino,
      codigoHash,
      expiracion,
      cambios: {
        correo: cambiarCorreo
          ? correo.trim().toLowerCase()
          : null,
        passwordHash
      }
    });

    await verificacion.save();

    try {
      await enviarCodigoAutorizacionAdmin(
        correoDestino,
        cuenta.nombre,
        codigo
      );
    } catch (errorEnvio) {
      await VerificacionCuentaSitio.deleteOne({
        _id: verificacion._id
      });

      throw errorEnvio;
    }

    return res.status(200).json({
      mensaje: 'Código de autorización enviado correctamente.',
      correoDestino,
      expiracion
    });

  } catch (error) {
    console.error(
      'Error al solicitar código para modificar cuenta:',
      error
    );

    return res.status(500).json({
      mensaje: 'No se pudo enviar el código de autorización.'
    });
  }
};

// =====================================================
// VERIFICAR CÓDIGO Y APLICAR CAMBIOS
// =====================================================

const verificarCodigoCambioCuenta = async (req, res) => {
  try {
    const { cuentaId } = req.params;
    const { codigo } = req.body;

    const adminId = req.usuario.id;

    if (
      typeof codigo !== 'string' ||
      !/^\d{6}$/.test(codigo)
    ) {
      return res.status(400).json({
        mensaje: 'Debes ingresar un código válido de seis dígitos.'
      });
    }

    const verificacion = await VerificacionCuentaSitio.findOne({
      cuentaId,
      adminId
    }).select('+codigoHash +cambios.passwordHash');

    if (!verificacion) {
      return res.status(404).json({
        mensaje: 'No existe una solicitud de verificación pendiente.'
      });
    }

    if (verificacion.expiracion <= new Date()) {
      await VerificacionCuentaSitio.deleteOne({
        _id: verificacion._id
      });

      return res.status(400).json({
        mensaje: 'El código ha vencido. Solicita uno nuevo.'
      });
    }

    const codigoIngresado = generarHashCodigo(codigo);

    const hashGuardado = Buffer.from(
      verificacion.codigoHash,
      'hex'
    );

    const hashIngresado = Buffer.from(
      codigoIngresado,
      'hex'
    );

    if (
      hashGuardado.length !== hashIngresado.length ||
      !crypto.timingSafeEqual(hashGuardado, hashIngresado)
    ) {
      return res.status(400).json({
        mensaje: 'El código de verificación es incorrecto.'
      });
    }

    const cuenta = await CuentaSitio.findById(cuentaId);

    if (!cuenta) {
      await VerificacionCuentaSitio.deleteOne({
        _id: verificacion._id
      });

      return res.status(404).json({
        mensaje: 'La cuenta de sitio ya no existe.'
      });
    }

    // Comprobar nuevamente que el correo no haya sido registrado.
    if (verificacion.cambios.correo) {
      const correoExistente = await CuentaSitio.findOne({
        correo: verificacion.cambios.correo,
        _id: { $ne: cuenta._id }
      });

      if (correoExistente) {
        return res.status(409).json({
          mensaje: 'El correo ya está registrado en otra cuenta.'
        });
      }

      cuenta.correo = verificacion.cambios.correo;
      cuenta.correoVerificado = true;
    }

    if (verificacion.cambios.passwordHash) {
      cuenta.password = verificacion.cambios.passwordHash;
    }

    await cuenta.save();

    // El código se elimina después de aplicar los cambios.
    await VerificacionCuentaSitio.deleteOne({
      _id: verificacion._id
    });

    return res.status(200).json({
      mensaje: 'Los cambios de la cuenta se verificaron y actualizaron correctamente.',
      cuenta: {
        id: cuenta._id.toString(),
        sitioId: cuenta.sitioId.toString(),
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono || '',
        activo: cuenta.activo
      }
    });

  } catch (error) {
    console.error(
      'Error al verificar código de cambio de cuenta:',
      error
    );

    return res.status(500).json({
      mensaje: 'No se pudieron aplicar los cambios de la cuenta.'
    });
  }
};

// =====================================================
// EXPORTAR CONTROLADORES
// =====================================================

module.exports = {
  solicitarCodigoCambioCuenta,
  verificarCodigoCambioCuenta
};
