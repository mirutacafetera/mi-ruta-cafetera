const express = require('express');

const router = express.Router();

const {
  obtenerMultimedia,
  actualizarMultimedia
} = require('../../controllers/sitio/multimedia.controller');


// Obtener todas las imágenes, videos y audios de un sitio
router.get('/:id', obtenerMultimedia);


// Actualizar un recurso multimedia específico
router.put('/:id', actualizarMultimedia);


module.exports = router;