const express = require('express');

const router = express.Router();

const {
  obtenerResenasPorSitio,
  crearResena,
  actualizarResena,
  eliminarResena
} = require('../../controllers/usuario/resenas.controller');

router.get('/sitio/:sitioId', obtenerResenasPorSitio);

router.post('/', crearResena);

router.put('/:id', actualizarResena);

router.delete('/:id', eliminarResena);

module.exports = router;