const express = require('express');

const router = express.Router();

const {
  obtenerResenas,
  obtenerResena,
  desactivarResena,
  activarResena,
  eliminarResena
} = require('../../controllers/admin/resenas.controller');

router.get('/', obtenerResenas);

router.get('/:id', obtenerResena);

router.put('/:id/desactivar', desactivarResena);

router.put('/:id/activar', activarResena);

router.delete('/:id', eliminarResena);

module.exports = router;