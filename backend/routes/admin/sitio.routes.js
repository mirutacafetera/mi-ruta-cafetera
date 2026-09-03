const express = require('express');

const {
  crearSitio,
  obtenerSitios,
  obtenerSitio,
  actualizarSitio,
  eliminarSitio
} = require('../../controllers/admin/sitio.controller');

const router = express.Router();

// ======================================================
// SITIOS TURÍSTICOS - ADMIN
// ======================================================

router.post('/', crearSitio);

router.get('/', obtenerSitios);

router.get('/:id', obtenerSitio);

router.put('/:id', actualizarSitio);

router.delete('/:id', eliminarSitio);

module.exports = router;