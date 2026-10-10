const express = require('express');

const router = express.Router();

const {
  obtenerRecomendaciones
} = require('../../controllers/usuario/ai.controller');

const {
  verificarToken
} = require('../../middlewares/authmiddleware');

const {
  crearLimitador
} = require('../../middlewares/ratelimitmiddleware');

// 10 solicitudes cada 10 minutos por usuario.
const limitarRecomendaciones = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 10,
  mensaje:
    'Has pedido muchas recomendaciones seguidas. ' +
    'Intenta de nuevo en unos minutos.'
});

// =====================================================
// RECOMENDACIONES CON IA
// POST /api/v1/ai/recommendations
// =====================================================

router.post(
  '/recommendations',
  verificarToken,
  limitarRecomendaciones,
  obtenerRecomendaciones
);

module.exports = router;