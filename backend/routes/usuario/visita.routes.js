const express = require('express');

const router = express.Router();

const {
  obtenerVisitas,
  registrarVisita
} = require('../../controllers/usuario/visitas.controller');

router.get('/:usuarioId', obtenerVisitas);

router.post('/', registrarVisita);

module.exports = router;