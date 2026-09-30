const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  obtenerActividades,
  crearActividad,
  actualizarActividad,
  desactivarActividad
} = require('../../controllers/sitio/actividades.controller');

router.get('/:id', obtenerActividades);

router.post('/:id', verificarToken, verificarSitio, crearActividad);

router.put('/:id/:actividadId', verificarToken, verificarSitio, actualizarActividad);

router.put('/:id/:actividadId/desactivar', verificarToken, verificarSitio, desactivarActividad);

module.exports = router;