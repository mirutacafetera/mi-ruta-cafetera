
const express = require('express');

const {
  crearCuentaSitio,
  verificarCorreoSitio,
  iniciarSesion,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
} = require('../../controllers/admin/authsitio.controller');

const {
  solicitarCodigoCambioCuenta,
  verificarCodigoCambioCuenta
} = require('../../controllers/admin/verificacionCuentaSitio.controller');

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

// =====================================================
// GESTIÓN DE CUENTAS DE SITIOS - ADMINISTRADOR
// =====================================================

router.get(
  '/cuentas',
  verificarToken,
  verificarAdministrador,
  obtenerCuentas
);

router.post(
  '/crear-cuenta-sitio',
  verificarToken,
  verificarAdministrador,
  crearCuentaSitio
);

router.put(
  '/cuentas/:cuentaId',
  verificarToken,
  verificarAdministrador,
  actualizarCuenta
);

router.patch(
  '/cuentas/:cuentaId/estado',
  verificarToken,
  verificarAdministrador,
  cambiarEstadoCuenta
);

router.delete(
  '/eliminar-sitio/:id',
  verificarToken,
  verificarAdministrador,
  eliminarSitio
);

// =====================================================
// AUTORIZACIÓN DE CAMBIOS DE CORREO Y CONTRASEÑA
// EXCLUSIVA DEL ADMINISTRADOR
// =====================================================

router.post(
  '/cuentas/:cuentaId/solicitar-codigo-cambio',
  verificarToken,
  verificarAdministrador,
  solicitarCodigoCambioCuenta
);

router.post(
  '/cuentas/:cuentaId/verificar-codigo-cambio',
  verificarToken,
  verificarAdministrador,
  verificarCodigoCambioCuenta
);

// =====================================================
// AUTENTICACIÓN DE LA CUENTA DEL SITIO
// SE CONSERVAN LAS FUNCIONES EXISTENTES
// =====================================================

router.post('/login', iniciarSesion);

router.post('/verificar-correo', verificarCorreoSitio);

router.post('/recuperar-password', recuperarPassword);

router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacion
);

router.post('/restablecer-password', restablecerPassword);

module.exports = router;
