const express = require('express');

const router = express.Router();

const {
  obtenerContenidos,
  obtenerContenido,
  actualizarContenido,
  desactivarContenido,
  activarContenido,
  eliminarContenido
} = require('../../controllers/admin/contenido.controller');

router.get('/', obtenerContenidos);

router.get('/:id', obtenerContenido);

router.put('/:id', actualizarContenido);

router.put('/:id/desactivar', desactivarContenido);

router.put('/:id/activar', activarContenido);

router.delete('/:id', eliminarContenido);

module.exports = router;