
const express = require('express');
const router = express.Router();

const {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva
} = require('../../controllers/admin/reservas.controller');

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');

// Solo administradores: estas rutas exponen las reservas de todos
// los sitios y permiten cambiar su estado.

// Consultar todas las reservas
router.get(
  '/',
  verificarToken,
  verificarAdministrador,
  obtenerReservas
);

// Consultar una reserva por ID
router.get(
  '/:id',
  verificarToken,
  verificarAdministrador,
  obtenerReserva
);

// Actualizar el estado de una reserva
router.patch(
  '/:id/estado',
  verificarToken,
  verificarAdministrador,
  actualizarEstadoReserva
);

module.exports = router;
