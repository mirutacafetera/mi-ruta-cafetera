const express = require('express');

const router = express.Router();

const {
  crearCuentaSitio,
  iniciarSesionSitio,
  obtenerSitio,
  recuperarPasswordSitio,
  verificarCodigoRecuperacionSitio,
  restablecerPasswordSitio
} = require(
  '../../controllers/admin/authsitio.controller'
);

// ======================================================
// CREAR CUENTA DEL SITIO
// ======================================================

router.post(
  '/registrar',
  crearCuentaSitio
);

// ======================================================
// INICIAR SESIÓN
// ======================================================

router.post(
  '/login',
  iniciarSesionSitio
);

// ======================================================
// OBTENER CUENTA
// ======================================================

router.get(
  '/:id',
  obtenerSitio
);

// ======================================================
// RECUPERAR CONTRASEÑA
// ======================================================

router.post(
  '/recuperar-password',
  recuperarPasswordSitio
);

// ======================================================
// VERIFICAR CÓDIGO
// ======================================================

router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacionSitio
);

// ======================================================
// RESTABLECER CONTRASEÑA
// ======================================================

router.post(
  '/restablecer-password',
  restablecerPasswordSitio
);

module.exports = router;