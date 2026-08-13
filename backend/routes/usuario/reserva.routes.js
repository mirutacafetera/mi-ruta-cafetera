const express = require('express');

const router = express.Router();

const {
  obtenerReservas,
  crearReserva,
  actualizarReserva,
  cancelarReserva
} = require('../../controllers/usuario/reservas.controller');

router.get('/:usuarioId', obtenerReservas);

router.post('/', crearReserva);

router.put('/:id', actualizarReserva);

router.put('/:id/cancelar', cancelarReserva);

module.exports = router;