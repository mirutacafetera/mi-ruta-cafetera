const express = require('express');

const router = express.Router();

const {
  obtenerInformacion,
  actualizarInformacion
} = require('../../controllers/sitio/informacion.controller');

router.get('/:id', obtenerInformacion);

router.put('/:id', actualizarInformacion);

module.exports = router;