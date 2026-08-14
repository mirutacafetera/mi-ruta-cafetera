const express = require('express');

const router = express.Router();

const {
  obtenerResenas,
  obtenerCalificacionPromedio
} = require('../../controllers/sitio/resenas.controller');

router.get('/:id', obtenerResenas);

router.get('/:id/promedio', obtenerCalificacionPromedio);

module.exports = router;