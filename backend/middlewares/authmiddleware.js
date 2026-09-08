const jwt = require('jsonwebtoken');

// =====================================================
// VERIFICAR TOKEN JWT
// =====================================================

const verificarToken = (req, res, next) => {
  try {
    // -------------------------------------------------
    // OBTENER HEADER AUTHORIZATION
    // -------------------------------------------------

    const authorization = req.headers.authorization;

    if (!authorization) {
      return res.status(401).json({
        mensaje: 'No se proporcionó un token de autenticación'
      });
    }

    // -------------------------------------------------
    // COMPROBAR FORMATO: Bearer TOKEN
    // -------------------------------------------------

    const partes = authorization.split(' ');

    if (
      partes.length !== 2 ||
      partes[0] !== 'Bearer'
    ) {
      return res.status(401).json({
        mensaje: 'Formato de token inválido'
      });
    }

    const token = partes[1];

    if (!token) {
      return res.status(401).json({
        mensaje: 'Token de autenticación no válido'
      });
    }

    // -------------------------------------------------
    // VERIFICAR TOKEN
    // -------------------------------------------------

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    // -------------------------------------------------
    // GUARDAR INFORMACIÓN DEL USUARIO
    // -------------------------------------------------

    req.usuario = {
      id: decoded.id,
      correo: decoded.correo,
      rol: decoded.rol
    };

    // -------------------------------------------------
    // CONTINUAR
    // -------------------------------------------------

    next();

  } catch (error) {

    console.error(
      'Error al verificar token:',
      error
    );

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        mensaje: 'El token ha expirado'
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        mensaje: 'El token no es válido'
      });
    }

    return res.status(401).json({
      mensaje: 'No autorizado'
    });
  }
};


// =====================================================
// VERIFICAR QUE SEA ADMINISTRADOR
// =====================================================

const verificarAdministrador = (
  req,
  res,
  next
) => {

  // -------------------------------------------------
  // COMPROBAR QUE EXISTE USUARIO AUTENTICADO
  // -------------------------------------------------

  if (!req.usuario) {
    return res.status(401).json({
      mensaje: 'Debes iniciar sesión'
    });
  }

  // -------------------------------------------------
  // COMPROBAR ROL
  // -------------------------------------------------

  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({
      mensaje:
        'No tienes permisos de administrador'
    });
  }

  // -------------------------------------------------
  // CONTINUAR
  // -------------------------------------------------

  next();
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  verificarToken,
  verificarAdministrador
};