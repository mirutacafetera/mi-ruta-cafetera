const express = require('express');

const router = express.Router();

const {
  obtenerFavoritos,
  agregarFavorito,
  eliminarFavorito
} = require('../../controllers/usuario/favoritos.controller');

router.get('/:usuarioId', obtenerFavoritos);

router.post('/', agregarFavorito);

router.delete('/:id', eliminarFavorito);

module.exports = router;