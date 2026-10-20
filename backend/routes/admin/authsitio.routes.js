const express = require('express');

const {
  crearCuentaSitio,
  iniciarSesion,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
} = require('../../controllers/admin/authsitio.controller');

const {
  eliminarSitio,
  obtenerCuentas,
  actualizarCuenta,
  cambiarEstadoCuenta
} = require('../../controllers/admin/sitio.controller');

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');

const router = express.Router();

// ============================================================
// CONSULTAR CUENTAS
// GET /api/admin/authsitio/cuentas
// ============================================================

router.get(
  '/cuentas',
  verificarToken,
  verificarAdministrador,
  obtenerCuentas
);

// ============================================================
// CREAR CUENTA DEL SITIO
// ============================================================

router.post(
  '/crear-cuenta-sitio',
  verificarToken,
  verificarAdministrador,
  crearCuentaSitio
);

// ============================================================
// ACTUALIZAR CUENTA
// ============================================================

router.put(
  '/cuentas/:cuentaId',
  verificarToken,
  verificarAdministrador,
  actualizarCuenta
);

// ============================================================
// CAMBIAR ESTADO DE CUENTA
// ============================================================

router.patch(
  '/cuentas/:cuentaId/estado',
  verificarToken,
  verificarAdministrador,
  cambiarEstadoCuenta
);

// ============================================================
// ELIMINAR SITIO Y SU CUENTA ASOCIADA
// ============================================================

router.delete(
  '/eliminar-sitio/:id',
  verificarToken,
  verificarAdministrador,
  eliminarSitio
);

// ============================================================
// INICIAR SESIÓN
// ============================================================

router.post(
  '/login',
  iniciarSesion
);

// ============================================================
// RECUPERAR CONTRASEÑA
// ============================================================

router.post(
  '/recuperar-password',
  recuperarPassword
);

// ============================================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// ============================================================

router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacion
);

// ============================================================
// RESTABLECER CONTRASEÑA
// ============================================================

router.post(
  '/restablecer-password',
  restablecerPassword
);

module.exports = router;