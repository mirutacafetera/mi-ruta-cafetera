const express = require('express');

const router = express.Router();

const {
  obtenerSitios,
  obtenerSitio,
  crearSitio,
  actualizarSitio,
  desactivarSitio,
  agregarMultimedia
} = require('../../controllers/admin/sitios.controller');

router.get('/', obtenerSitios);

router.get('/:id', obtenerSitio);

router.post('/', crearSitio);

router.put('/:id', actualizarSitio);

router.put('/:id/desactivar', desactivarSitio);

router.put('/:id/multimedia', agregarMultimedia);

module.exports = router;