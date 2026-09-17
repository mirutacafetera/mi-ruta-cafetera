const express = require('express');

const router = express.Router();

const {
  loginWithGoogle
} = require(
  '../../controllers/usuario/google.controller'
);

const {
  registrarUsuario,
  verificarCorreo,
  iniciarSesionUsuario,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword,
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
} = require(
  '../../controllers/usuario/usuario.controller'
);

// ======================================================
// AUTENTICACIÃ“N DE USUARIOS
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

// Iniciar sesiÃ³n
router.post(
  '/login',
  iniciarSesionUsuario
);

// Iniciar sesión con Google
router.post(
  '/login-google',
  loginWithGoogle
);


// Recuperar contraseÃ±a
router.post(
  '/recuperar-password',
  recuperarPassword
);

// Verificar cÃ³digo de recuperaciÃ³n
router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacion
);

// Restablecer contraseÃ±a
router.post(
  '/restablecer-password',
  restablecerPassword
);

// ======================================================
// USUARIO
// ======================================================

// Obtener usuario
router.get(
  '/:id',
  obtenerUsuario
);

// Actualizar usuario
router.put(
  '/:id',
  actualizarUsuario
);

// Eliminar cuenta
router.delete(
  '/:id',
  eliminarUsuario
);

module.exports = router;
