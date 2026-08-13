const express = require('express');

const router = express.Router();

const {
  obtenerSitios,
  obtenerSitio,
  crearSitio,
  actualizarSitio,
  desactivarSitio,
  activarSitio,
  eliminarSitio
} = require('../../controllers/sitio/sitioturistico.controller');

router.get('/', obtenerSitios);

router.get('/:id', obtenerSitio);

router.post('/', crearSitio);

router.put('/:id', actualizarSitio);

router.put('/:id/desactivar', desactivarSitio);

router.put('/:id/activar', activarSitio);

router.delete('/:id', eliminarSitio);

module.exports = router;