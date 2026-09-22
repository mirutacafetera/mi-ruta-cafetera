const express = require('express');

const {
  iniciarSesionAdmin,
  obtenerAdministrador,
  recuperarPasswordAdmin,
  verificarCodigoRecuperacionAdmin,
  restablecerPasswordAdmin
} = require(
  '../../controllers/admin/authsitio.controller'
);

const router = express.Router();

// ======================================================
// AUTENTICACIÓN DEL ADMINISTRADOR
// ======================================================

// Iniciar sesión
router.post(
  '/login',
  iniciarSesionAdmin
);

// Recuperar contraseña
router.post(
  '/recuperar-password',
  recuperarPasswordAdmin
);

// Verificar código de recuperación
router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacionAdmin
);

// Restablecer contraseña
router.post(
  '/restablecer-password',
  restablecerPasswordAdmin
);

// Obtener administrador
router.get(
  '/:id',
  obtenerAdministrador
);

module.exports = router;