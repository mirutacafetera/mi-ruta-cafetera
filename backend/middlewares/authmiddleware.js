const jwt = require('jsonwebtoken');
const Usuario = require('../models/usuario/usuario');

// =====================================================
// VERIFICAR TOKEN JWT
// =====================================================

const verificarToken = async (req, res, next) => {
  try {
    const authorization = req.headers.authorization;

    if (!authorization) {
      return res.status(401).json({
        mensaje: 'No se proporcionó un token de autenticación'
      });
    }

    const partes = authorization.split(' ');

    if (partes.length !== 2 || partes[0] !== 'Bearer') {
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

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const id =
      decoded.id ||
      decoded._id ||
      decoded.administradorId ||
      decoded.adminId ||
      decoded.usuarioId ||
      decoded.sub;

    req.usuario = {
      id,
      _id: id,
      sitioId: decoded.sitioId,
      correo: decoded.correo,
      rol: decoded.rol || decoded.role
    };

    // Comprobar que la cuenta de usuario siga existiendo.
    if (req.usuario.rol === 'usuario') {
      let cuenta;

      try {
        cuenta = await Usuario.findById(id)
          .select('_id activo eliminadoAt')
          .lean();
      } catch (errorBusqueda) {
        console.error(
          'Error al comprobar la cuenta del token:',
          errorBusqueda
        );

        return res.status(500).json({
          mensaje: 'No se pudo verificar tu sesión'
        });
      }

      if (!cuenta || cuenta.eliminadoAt) {
        return res.status(401).json({
          mensaje: 'Tu cuenta ya no existe o fue eliminada'
        });
      }

      if (cuenta.activo === false) {
        return res.status(403).json({
          mensaje: 'Tu cuenta está desactivada'
        });
      }
    }

    next();
  } catch (error) {
    console.error('Error al verificar token:', error);

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
// VERIFICAR ADMINISTRADOR
// =====================================================

const verificarAdministrador = (req, res, next) => {
  if (!req.usuario) {
    return res.status(401).json({
      mensaje: 'Debes iniciar sesión'
    });
  }

  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({
      mensaje: 'No tienes permisos de administrador'
    });
  }

  if (!req.usuario.id) {
    return res.status(401).json({
      mensaje: 'No se pudo identificar al administrador'
    });
  }

  next();
};

// =====================================================
// VERIFICAR CUENTA DE SITIO
// =====================================================

const verificarSitio = (req, res, next) => {
  if (!req.usuario) {
    return res.status(401).json({
      mensaje: 'Debes iniciar sesión'
    });
  }

  if (req.usuario.rol !== 'sitio') {
    return res.status(403).json({
      mensaje: 'No tienes permisos de sitio'
    });
  }

  if (!req.usuario.sitioId) {
    return res.status(403).json({
      mensaje: 'La cuenta no tiene un sitio asociado'
    });
  }

  next();
};

// =====================================================
// VERIFICAR USUARIO VISITANTE
// =====================================================

const verificarUsuario = (req, res, next) => {
  if (!req.usuario) {
    return res.status(401).json({
      mensaje: 'Debes iniciar sesión'
    });
  }

  if (req.usuario.rol !== 'usuario') {
    return res.status(403).json({
      mensaje: 'Esta operación es solo para cuentas de usuario'
    });
  }

  next();
};

// =====================================================
// EXPORTAR MIDDLEWARES
// =====================================================

module.exports = {
  verificarToken,
  verificarAdministrador,
  verificarSitio,
  verificarUsuario
};