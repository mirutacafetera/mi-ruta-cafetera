const express = require('express');

const router = express.Router();

const {
  obtenerMapas,
  guardarMapa,
  eliminarMapa
} = require('../../controllers/usuario/mapasoffline.controller');

router.get('/:usuarioId', obtenerMapas);

router.post('/', guardarMapa);

router.delete('/:id', eliminarMapa);

module.exports = router;