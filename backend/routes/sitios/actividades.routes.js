const express = require('express');

const router = express.Router();

const {
  obtenerActividades,
  crearActividad,
  actualizarActividad,
  desactivarActividad
} = require('../../controllers/sitio/actividades.controller');

router.get('/:id', obtenerActividades);

router.post('/:id', crearActividad);

router.put('/:id/:actividadId', actualizarActividad);

router.put('/:id/:actividadId/desactivar', desactivarActividad);

module.exports = router;