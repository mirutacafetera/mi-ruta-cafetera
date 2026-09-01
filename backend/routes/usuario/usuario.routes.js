const express = require('express');

const router = express.Router();

const {
  registrarUsuario,
  iniciarSesionUsuario,
  verificarCodigoVerificacion,
  solicitarRecuperacion,
  verificarCodigoRecuperacion,
  restablecerPassword,
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
} = require('../../controllers/usuario/usuario.controller');


// =====================================================
// AUTENTICACIÓN
// =====================================================

// Registrar usuario
router.post(
  '/registrar',
  registrarUsuario
);

// Iniciar sesión
router.post(
  '/login',
  iniciarSesionUsuario
);

// Verificar correo después del registro
router.post(
  '/verificar-correo',
  verificarCodigoVerificacion
);

// Solicitar recuperación de contraseña
router.post(
  '/recuperar-password',
  solicitarRecuperacion
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


// =====================================================
// PERFIL DE USUARIO
// =====================================================

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