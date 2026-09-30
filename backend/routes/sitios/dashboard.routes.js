const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  obtenerDashboard
} = require('../../controllers/sitio/dashboard.controller');


// =====================================================
// DASHBOARD DEL SITIO
// =====================================================

router.get(
  '/',
  verificarToken,
  verificarSitio,
  obtenerDashboard
);


module.exports = router;