const express = require('express');

const router = express.Router();

const {
  obtenerSitios,
  obtenerSitio,
  buscarSitios,
  filtrarPorCategoria
} = require('../../controllers/usuario/sitios.controller');


// Obtener todos los sitios turísticos
router.get('/', obtenerSitios);


// Buscar sitios por nombre
router.get('/buscar', buscarSitios);


// Filtrar sitios por categoría
router.get('/categoria/:categoriaId', filtrarPorCategoria);


// Obtener un sitio turístico específico
router.get('/:id', obtenerSitio);


module.exports = router;