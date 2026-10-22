const express = require('express');

const router = express.Router();

const {
  crearReporte,
  obtenerMisReportes
} = require('../../controllers/usuario/ayuda.controller');

const {
  verificarToken,
  verificarUsuario
} = require('../../middlewares/authmiddleware');

const {
  crearLimitador
} = require('../../middlewares/ratelimitmiddleware');

// Envío de reportes: 5 cada 10 minutos por usuario.
const limitarEnvio = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 5,
  mensaje:
    'Has enviado varios reportes seguidos. Intenta de nuevo en unos minutos.'
});


// Crear reporte (solo cuentas de usuario)
router.post(
  '/',
  verificarToken,
  verificarUsuario,
  limitarEnvio,
  crearReporte
);


// Ver mis reportes (solo cuentas de usuario)
router.get(
  '/',
  verificarToken,
  verificarUsuario,
  obtenerMisReportes
);


module.exports = router;
