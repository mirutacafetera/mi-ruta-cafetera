const express = require('express');

const {
  loginWithGoogle
} = require(
  '../../controllers/usuario/google.controller'
);

const router = express.Router();


// ======================================================
// MIDDLEWARE DE AUTENTICACIÓN
// ======================================================

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
  obtenerUsuario,
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

// Obtener usuario

router.get(
  '/:id',
  obtenerUsuario
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