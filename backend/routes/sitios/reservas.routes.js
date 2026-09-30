const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva
} = require('../../controllers/sitio/reservas.controller');


// =====================================================
// RESERVAS
// =====================================================

// Operaciones privadas del sitio
router.get(
  '/:id',
  verificarToken,
  verificarSitio,
  obtenerReservas
);

router.get(
  '/:id/:reservaId',
  verificarToken,
  verificarSitio,
  obtenerReserva
);

router.put(
  '/:id/:reservaId/estado',
  verificarToken,
  verificarSitio,
  actualizarEstadoReserva
);


module.exports = router;