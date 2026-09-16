const express = require('express');

const router = express.Router();

const {
  crearCuentaSitio,
  iniciarSesionSitio,
  obtenerSitio,
  recuperarPasswordSitio,
  verificarCodigoRecuperacionSitio,
  restablecerPasswordSitio,
  eliminarCuentaSitio
} = require('../../controllers/admin/authsitio.controller');


// ======================================================
// CREAR SITIO + CUENTA DEL RESPONSABLE
// ======================================================

router.post(
  '/',
  crearCuentaSitio
);


// ======================================================
// INICIAR SESIÓN DEL SITIO
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

// ======================================================
// ELIMINAR CUENTA
// ======================================================

router.delete(
  '/:id',
  eliminarCuentaSitio
);

module.exports = router;