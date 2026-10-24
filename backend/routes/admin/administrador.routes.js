
const express = require('express');

const router = express.Router();

const {
  loginAdministradorConGoogle
} = require('../../controllers/auth/googleCuentas.controller');

const {
  uploadFotoAdmin
} = require('../../middlewares/uploadmiddleware');

const {
  registrarAdministrador,
  verificarCodigoVerificacionAdministrador,
  iniciarSesionAdministrador,
  solicitarRecuperacionAdministrador,
  verificarCodigoRecuperacionAdministrador,
  restablecerPasswordAdministrador,
  obtenerAdministrador,
  actualizarAdministrador,
  cambiarEstadoAdministrador,
  subirFotoAdministrador
} = require('../../controllers/admin/administrador.controller');

// =====================================================
// AUTENTICACIÓN DEL ADMINISTRADOR
// =====================================================

router.post(
  '/registrar',
  registrarAdministrador
);

router.post(
  '/verificar-correo',
  verificarCodigoVerificacionAdministrador
);

router.post(
  '/login',
  iniciarSesionAdministrador
);

router.post(
  '/login-google',
  loginAdministradorConGoogle
);

router.post(
  '/recuperar-password',
  solicitarRecuperacionAdministrador
);

router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacionAdministrador
);

router.post(
  '/restablecer-password',
  restablecerPasswordAdministrador
);

// =====================================================
// FOTO DE PERFIL DEL ADMINISTRADOR
// =====================================================

router.post(
  '/:id/foto',
  uploadFotoAdmin.single('foto'),
  subirFotoAdministrador
);

// =====================================================
// ADMINISTRADOR
// =====================================================

router.get(
  '/:id',
  obtenerAdministrador
);

router.put(
  '/:id',
  actualizarAdministrador
);

router.patch(
  '/:id/estado',
  cambiarEstadoAdministrador
);

module.exports = router;
