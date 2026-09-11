const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');

const Usuario = require('../../models/usuario/usuario');

const googleClient = new OAuth2Client(
  process.env.GOOGLE_CLIENT_ID
);

const loginWithGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        mensaje: 'No se proporcionó el token de Google'
      });
    }

    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID
    });

    const payload = ticket.getPayload();

    if (!payload) {
      return res.status(401).json({
        mensaje: 'No se pudo obtener la información de Google'
      });
    }

    const {
      sub: googleId,
      email,
      email_verified: emailVerificado,
      given_name: nombre,
      family_name: apellido,
      picture: fotoPerfil
    } = payload;

    if (!email) {
      return res.status(400).json({
        mensaje: 'La cuenta de Google no proporciona un correo'
      });
    }

    if (!emailVerificado) {
      return res.status(401).json({
        mensaje: 'El correo de Google no está verificado'
      });
    }

    const correoNormalizado = email.toLowerCase().trim();

    let usuario = await Usuario
      .findOne({
        correo: correoNormalizado
      })
      .select('+password');

    if (!usuario) {
      usuario = await Usuario.create({
        nombre: nombre || 'Usuario',
        apellido: apellido || '',
        correo: correoNormalizado,
        password: `GOOGLE_${googleId}_${Date.now()}`,
        fotoPerfil: fotoPerfil || '',
        correoVerificado: true
      });
    } else {
      let necesitaGuardar = false;

      if (
        fotoPerfil &&
        usuario.fotoPerfil !== fotoPerfil
      ) {
        usuario.fotoPerfil = fotoPerfil;
        necesitaGuardar = true;
      }

      if (!usuario.correoVerificado) {
        usuario.correoVerificado = true;
        necesitaGuardar = true;
      }

      if (necesitaGuardar) {
        await usuario.save();
      }
    }

    const token = jwt.sign(
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

    return res.status(200).json({
      mensaje: 'Inicio de sesión con Google exitoso',
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
      'Error en login con Google:',
      error
    );

    return res.status(401).json({
      mensaje: 'No se pudo autenticar con Google',
      error: error.message
    });
  }
};

module.exports = {
  loginWithGoogle
};