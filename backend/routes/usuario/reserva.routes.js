const express = require('express');

const router = express.Router();

const {
  obtenerReservas,
  crearReserva,
  actualizarReserva,
  cancelarReserva
} = require('../../controllers/usuario/reservas.controller');

const {
  verificarToken
} = require('../../middlewares/authmiddleware');


// =====================================================
// OBTENER RESERVAS
// =====================================================

router.get(
  '/',
  verificarToken,
  obtenerReservas
);


// =====================================================
// CREAR RESERVA
// =====================================================

router.post(
  '/',
  verificarToken,
  crearReserva
);


// =====================================================
// ACTUALIZAR RESERVA
// =====================================================

router.put(
  '/:id',
  verificarToken,
  actualizarReserva
);


// =====================================================
// CANCELAR RESERVA
// =====================================================

router.put(
  '/:id/cancelar',
  verificarToken,
  cancelarReserva
);


module.exports = router;