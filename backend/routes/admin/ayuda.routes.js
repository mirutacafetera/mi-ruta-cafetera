const express = require('express');

const router = express.Router();

const {
  obtenerReportes,
  obtenerReporte,
  responderReporte
} = require('../../controllers/admin/ayuda.controller');

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');


// =====================================================
// OBTENER TODOS LOS REPORTES
// =====================================================

router.get(
  '/',
  verificarToken,
  verificarAdministrador,
  obtenerReportes
);


// =====================================================
// OBTENER UN REPORTE
// =====================================================

router.get(
  '/:id',
  verificarToken,
  verificarAdministrador,
  obtenerReporte
);


// =====================================================
// RESPONDER / ACTUALIZAR REPORTE
// =====================================================

router.put(
  '/:id',
  verificarToken,
  verificarAdministrador,
  responderReporte
);


module.exports = router;