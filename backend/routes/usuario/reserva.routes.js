const express = require('express');

const router = express.Router();

const {
  obtenerReservas,
  crearReserva,
  actualizarReserva,
  cancelarReserva
} = require('../../controllers/usuario/reservas.controller');

const {
  verificarToken,
  verificarUsuario
} = require('../../middlewares/authmiddleware');


// =====================================================
// RESERVAS DEL USUARIO
//
// Solo cuentas de usuario: un token de sitio o de
// administrador no puede crear ni consultar reservas
// como si fuera un visitante.
// =====================================================

// OBTENER RESERVAS
router.get(
  '/',
  verificarToken,
  verificarUsuario,
  obtenerReservas
);

// CREAR RESERVA
router.post(
  '/',
  verificarToken,
  verificarUsuario,
  crearReserva
);

// CANCELAR RESERVA
router.put(
  '/:id/cancelar',
  verificarToken,
  verificarUsuario,
  cancelarReserva
);

// ACTUALIZAR RESERVA (solo pendientes)
router.put(
  '/:id',
  verificarToken,
  verificarUsuario,
  actualizarReserva
);


module.exports = router;
