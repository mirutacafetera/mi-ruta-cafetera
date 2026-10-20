
const express = require('express');
const router = express.Router();

const {
  verificarToken,
  verificarAdministrador,
} = require('../../middlewares/authmiddleware');

const {
  obtenerActividadesPendientes,
  obtenerActividad,
  aprobarActividad,
  rechazarActividad,
} = require('../../controllers/admin/actividades.controller');

// Obtener actividades pendientes
router.get(
  '/pendientes',
  verificarToken,
  verificarAdministrador,
  obtenerActividadesPendientes
);

// Obtener una actividad por ID
router.get(
  '/:id',
  verificarToken,
  verificarAdministrador,
  obtenerActividad
);

// Aprobar actividad
router.put(
  '/:id/aprobar',
  verificarToken,
  verificarAdministrador,
  aprobarActividad
);

// Rechazar actividad
router.put(
  '/:id/rechazar',
  verificarToken,
  verificarAdministrador,
  rechazarActividad
);

module.exports = router;
