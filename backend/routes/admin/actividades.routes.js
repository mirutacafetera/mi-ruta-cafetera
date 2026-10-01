const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');

const {
  obtenerActividadesPendientes,
  obtenerActividad,
  aprobarActividad,
  rechazarActividad
} = require(
  '../../controllers/admin/actividades.controller'
);

// =====================================================
// ACTIVIDADES PENDIENTES
// =====================================================

router.get(
  '/pendientes',
  verificarToken,
  verificarAdministrador,
  obtenerActividadesPendientes
);

// =====================================================
// OBTENER ACTIVIDAD
// =====================================================

router.get(
  '/:id',
  verificarToken,
  verificarAdministrador,
  obtenerActividad
);

// =====================================================
// APROBAR ACTIVIDAD
// =====================================================

router.put(
  '/:id/aprobar',
  verificarToken,
  verificarAdministrador,
  aprobarActividad
);

// =====================================================
// RECHAZAR ACTIVIDAD
// =====================================================

router.put(
  '/:id/rechazar',
  verificarToken,
  verificarAdministrador,
  rechazarActividad
);

module.exports = router;