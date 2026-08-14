const express = require('express');

const router = express.Router();

const {
  obtenerResenas,
  obtenerResena,
  actualizarResena,
  desactivarResena,
  eliminarResena
} = require('../../controllers/admin/resenas.controller');

router.get('/', obtenerResenas);

router.get('/:id', obtenerResena);

router.put('/:id', actualizarResena);

router.put('/:id/desactivar', desactivarResena);

router.delete('/:id', eliminarResena);

module.exports = router;