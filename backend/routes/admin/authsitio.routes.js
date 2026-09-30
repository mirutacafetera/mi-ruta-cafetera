const express = require('express');

const {
  crearCuentaSitio,
  iniciarSesion,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
} = require(
  '../../controllers/admin/authsitio.controller'
);

const {
  verificarToken,
  verificarAdministrador
} = require(
  '../../middlewares/authmiddleware'
);

const router = express.Router();

// =====================================================
// CREAR CUENTA DE SITIO
// SOLO ADMINISTRADOR
// =====================================================

router.post(
  '/crear-cuenta-sitio',
  verificarToken,
  verificarAdministrador,
  crearCuentaSitio
);

// =====================================================
// INICIAR SESIÓN DEL SITIO
// =====================================================

router.post(
  '/login',
  iniciarSesion
);

// =====================================================
// RECUPERAR CONTRASEÑA DEL SITIO
// =====================================================

router.post(
  '/recuperar-password',
  recuperarPassword
);

// =====================================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// =====================================================

router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacion
);

// =====================================================
// RESTABLECER CONTRASEÑA
// =====================================================

router.post(
  '/restablecer-password',
  restablecerPassword
);

module.exports = router;