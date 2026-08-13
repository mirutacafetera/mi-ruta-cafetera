const express = require('express');

const router = express.Router();

const {
  obtenerMultimedia,
  actualizarMultimedia
} = require('../../controllers/sitio/multimedia.controller');

router.get('/:id', obtenerMultimedia);

router.put('/:id', actualizarMultimedia);

module.exports = router;