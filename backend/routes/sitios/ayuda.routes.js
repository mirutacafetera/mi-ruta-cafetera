const express = require('express');

const router = express.Router();

const {
  crearReporteSitio,
  obtenerMisReportesSitio
} = require('../../controllers/sitio/ayuda.controller');

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

// Crear un reporte o sugerencia.
router.post(
  '/',
  verificarToken,
  verificarSitio,
  crearReporteSitio
);

// Consultar únicamente los reportes del sitio autenticado.
router.get(
  '/',
  verificarToken,
  verificarSitio,
  obtenerMisReportesSitio
);

module.exports = router;
