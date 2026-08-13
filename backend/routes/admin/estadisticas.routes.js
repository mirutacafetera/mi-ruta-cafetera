const express = require('express');

const router = express.Router();

const {
  obtenerEstadisticas,
  obtenerEstadisticasGuardadas,
  crearEstadistica
} = require('../../controllers/admin/estadisticas.controller');

router.get('/', obtenerEstadisticas);

router.get('/guardadas', obtenerEstadisticasGuardadas);

router.post('/', crearEstadistica);

module.exports = router;