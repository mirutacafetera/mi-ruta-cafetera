
const express = require('express');
const router = express.Router();

const {
  obtenerReportesSitios,
  obtenerReporteSitio,
  responderReporteSitio,
} = require('../../controllers/admin/reportesSitios.controller');

const {
  verificarToken,
  verificarAdministrador,
} = require('../../middlewares/authmiddleware');

router.get(
  '/',
  verificarToken,
  verificarAdministrador,
  obtenerReportesSitios,
);

router.get(
  '/:id',
  verificarToken,
  verificarAdministrador,
  obtenerReporteSitio,
);

router.put(
  '/:id',
  verificarToken,
  verificarAdministrador,
  responderReporteSitio,
);

module.exports = router;
