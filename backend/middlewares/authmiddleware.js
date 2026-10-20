const jwt = require('jsonwebtoken');

const Usuario = require('../models/usuario/usuario');

// =====================================================
// VERIFICAR TOKEN JWT
// =====================================================

const verificarToken = async (req, res, next) => {
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
      sitioId: decoded.sitioId,
      correo: decoded.correo,
      rol: decoded.rol
   };

    // -------------------------------------------------
    // CUENTAS DE USUARIO: DEBEN SEGUIR EXISTIENDO
    // -------------------------------------------------
    //
    // Un token emitido antes de eliminar la cuenta deja de ser
    // válido. Los tokens de administrador y de sitio no se ven
    // afectados.

    if (decoded.rol === 'usuario') {
      let cuenta;

      try {
        cuenta = await Usuario
          .findById(decoded.id)
          .select('_id eliminadoAt')
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
    }

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
// VERIFICAR QUE SEA CUENTA DE SITIO
// =====================================================

const verificarSitio = (
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

  if (req.usuario.rol !== 'sitio') {
    return res.status(403).json({
      mensaje:
        'No tienes permisos de sitio'
    });
  }

  // -------------------------------------------------
  // COMPROBAR SITIO ASOCIADO
  // -------------------------------------------------

  if (!req.usuario.sitioId) {
    return res.status(403).json({
      mensaje:
        'La cuenta no tiene un sitio asociado'
    });
  }

  // -------------------------------------------------
  // CONTINUAR
  // -------------------------------------------------

  next();
};


// =====================================================
// VERIFICAR QUE SEA UN USUARIO (VISITANTE)
// =====================================================

const verificarUsuario = (
  req,
  res,
  next
) => {

  if (!req.usuario) {
    return res.status(401).json({
      mensaje: 'Debes iniciar sesión'
    });
  }

  if (req.usuario.rol !== 'usuario') {
    return res.status(403).json({
      mensaje:
        'Esta operación es solo para cuentas de usuario'
    });
  }

  next();
};

// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  verificarToken,
  verificarAdministrador,
  verificarSitio,
  verificarUsuario
};
