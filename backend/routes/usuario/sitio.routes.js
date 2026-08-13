const express = require('express');

const router = express.Router();

const {
  obtenerSitios,
  obtenerSitio,
  buscarSitios,
  filtrarPorCategoria
} = require('../../controllers/usuario/sitios.controller');

router.get('/', obtenerSitios);

router.get('/buscar', buscarSitios);

router.get('/categoria/:categoriaId', filtrarPorCategoria);

router.get('/:id', obtenerSitio);

module.exports = router;