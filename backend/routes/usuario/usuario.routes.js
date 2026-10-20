const express = require('express');

const router = express.Router();

const {
  crearLimitador
} = require(
  '../../middlewares/ratelimitmiddleware'
);

// Edición del perfil: 30 solicitudes cada 10 minutos.
const limitarEdicion = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 30,
  mensaje:
    'Has hecho muchos cambios seguidos. Intenta de nuevo en unos minutos.'
});

// Eliminación de cuenta: 5 intentos cada 10 minutos
// (protege la comprobación de contraseña).
const limitarEliminacion = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 5,
  mensaje:
    'Demasiados intentos. Intenta de nuevo en unos minutos.'
});

const {
  loginWithGoogle
} = require(
  '../../controllers/usuario/google.controller'
);

const {
  verificarToken
} = require(
  '../../middlewares/authmiddleware'
);

const {
  registrarUsuario,
  verificarCorreo,
  iniciarSesionUsuario,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword,
  obtenerMiPerfil,
  actualizarUsuario,
  eliminarUsuario
} = require(
  '../../controllers/usuario/usuario.controller'
);

// ======================================================
// AUTENTICACIÓN DE USUARIOS
// ======================================================

// Registrar usuario
router.post(
  '/registrar',
  registrarUsuario
);

// Verificar correo
router.post(
  '/verificar-correo',
  verificarCorreo
);

// Iniciar sesión
router.post(
  '/login',
  iniciarSesionUsuario
);

// Iniciar sesión con Google
router.post(
  '/login-google',
  loginWithGoogle
);

// Recuperar contraseña
router.post(
  '/recuperar-password',
  recuperarPassword
);

// Verificar código de recuperación
router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacion
);

// Restablecer contraseña
router.post(
  '/restablecer-password',
  restablecerPassword
);

// ======================================================
// USUARIO
// ======================================================

// Obtener mi perfil
router.get(
  '/perfil',
  verificarToken,
  obtenerMiPerfil
);

// Actualizar mi perfil (nombre, apellido, teléfono, ciudad, foto y avatar)
router.put(
  '/:id',
  verificarToken,
  limitarEdicion,
  actualizarUsuario
);

// Eliminar cuenta (anonimiza; exige confirmación e identidad)
router.delete(
  '/:id',
  verificarToken,
  limitarEliminacion,
  eliminarUsuario
);

module.exports = router;