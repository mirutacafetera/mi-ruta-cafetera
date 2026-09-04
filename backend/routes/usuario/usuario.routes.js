const express = require('express');

const router = express.Router();

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
  actualizarUsuario
);

// Eliminar cuenta
router.delete(
  '/:id',
  eliminarUsuario
);

module.exports = router;