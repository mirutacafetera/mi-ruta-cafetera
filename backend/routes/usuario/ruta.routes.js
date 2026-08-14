const express = require('express');

const router = express.Router();

const {
  obtenerRutas,
  crearRuta,
  actualizarRuta,
  eliminarRuta
} = require('../../controllers/usuario/rutas.controller');

router.get('/:usuarioId', obtenerRutas);

router.post('/', crearRuta);

router.put('/:id', actualizarRuta);

router.delete('/:id', eliminarRuta);

module.exports = router;