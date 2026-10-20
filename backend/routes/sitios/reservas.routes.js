const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva,
  obtenerNotificacionesSitio,
  marcarNotificacionSitioLeida
} = require('../../controllers/sitio/reservas.controller');


// =====================================================
// NOTIFICACIONES DEL ESTABLECIMIENTO
//
// Van antes de las rutas con parámetros para que
// "notificaciones" no se interprete como el id de un sitio.
// =====================================================

router.get(
  '/notificaciones',
  verificarToken,
  verificarSitio,
  obtenerNotificacionesSitio
);

router.put(
  '/notificaciones/:id/leida',
  verificarToken,
  verificarSitio,
  marcarNotificacionSitioLeida
);


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
