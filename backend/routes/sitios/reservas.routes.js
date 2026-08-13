const express = require('express');

const router = express.Router();

const {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva
} = require('../../controllers/sitio/reservas.controller');

router.get('/:id', obtenerReservas);

router.get('/:id/:reservaId', obtenerReserva);

router.put('/:id/:reservaId/estado', actualizarEstadoReserva);

module.exports = router;