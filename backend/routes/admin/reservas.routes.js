
const express = require('express');
const router = express.Router();

const {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva
} = require('../../controllers/admin/reservas.controller');

const { verificarToken } = require('../../middlewares/authmiddleware');

// Consultar todas las reservas
router.get('/', verificarToken, obtenerReservas);

// Consultar una reserva por ID
router.get('/:id', verificarToken, obtenerReserva);

// Actualizar el estado de una reserva
router.patch('/:id/estado', verificarToken, actualizarEstadoReserva);

module.exports = router;
