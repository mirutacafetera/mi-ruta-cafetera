const express = require('express');

const router = express.Router();

const {
  loginAdministradorConGoogle
} = require('../../controllers/auth/googleCuentas.controller');

const {
  registrarAdministrador,
  verificarCodigoVerificacionAdministrador,
  iniciarSesionAdministrador,
  solicitarRecuperacionAdministrador,
  verificarCodigoRecuperacionAdministrador,
  restablecerPasswordAdministrador,
  obtenerAdministrador,
  actualizarAdministrador,
  cambiarEstadoAdministrador
} = require('../../controllers/admin/administrador.controller');


// =====================================================
// AUTENTICACIÓN DEL ADMINISTRADOR
// =====================================================

// Registrar administrador
router.post(
  '/registrar',
  registrarAdministrador
);


// Verificar correo después del registro
router.post(
  '/verificar-correo',
  verificarCodigoVerificacionAdministrador
);


// Iniciar sesión
router.post(
  '/login',
  iniciarSesionAdministrador
);

// Iniciar sesión con Google (solo cuentas de administrador existentes)
router.post(
  '/login-google',
  loginAdministradorConGoogle
);


// Solicitar recuperación de contraseña
router.post(
  '/recuperar-password',
  solicitarRecuperacionAdministrador
);


// Verificar código de recuperación
router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacionAdministrador
);


// Restablecer contraseña
router.post(
  '/restablecer-password',
  restablecerPasswordAdministrador
);


// =====================================================
// ADMINISTRADOR
// =====================================================

// Obtener administrador
router.get(
  '/:id',
  obtenerAdministrador
);


// Actualizar administrador
router.put(
  '/:id',
  actualizarAdministrador
);


// Activar / desactivar administrador
router.patch(
  '/:id/estado',
  cambiarEstadoAdministrador
);


module.exports = router;
