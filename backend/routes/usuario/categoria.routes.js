const express = require('express');

const router = express.Router();

const {
  obtenerCategorias
} = require('../../controllers/usuario/categorias.controller');

router.get('/', obtenerCategorias);

module.exports = router;