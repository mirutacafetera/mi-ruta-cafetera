const express = require('express');

const router = express.Router();

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

// Actualizar usuario
router.put(
  '/:id',
  verificarToken,
  actualizarUsuario
);

// Eliminar cuenta
router.delete(
  '/:id',
  verificarToken,
  eliminarUsuario
);

module.exports = router;