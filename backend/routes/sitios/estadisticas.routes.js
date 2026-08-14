const express = require('express');

const router = express.Router();

const {
  obtenerEstadisticas
} = require('../../controllers/sitio/estadisticas.controller');

router.get('/:id', obtenerEstadisticas);

module.exports = router;