const express = require('express');

const router = express.Router();

const {
  registrar,
  verificarCorreo,
  iniciarSesion,
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
} = require('../../controllers/sitio/auth.controller');


// ==========================================
// REGISTRAR CUENTA DEL SITIO
// ==========================================

router.post(
  '/registro',
  registrar
);


// ==========================================
// VERIFICAR CORREO
// ==========================================

router.post(
  '/verificar-correo',
  verificarCorreo
);


// ==========================================
// INICIAR SESIÓN
// ==========================================

router.post(
  '/login',
  iniciarSesion
);


// ==========================================
// RECUPERAR CONTRASEÑA
// ==========================================

router.post(
  '/recuperar-password',
  recuperarPassword
);


// ==========================================
// VERIFICAR CÓDIGO DE RECUPERACIÓN
// ==========================================

router.post(
  '/verificar-codigo-recuperacion',
  verificarCodigoRecuperacion
);


// ==========================================
// RESTABLECER CONTRASEÑA
// ==========================================

router.post(
  '/restablecer-password',
  restablecerPassword
);


// ==========================================
// EXPORTAR
// ==========================================

module.exports = router;