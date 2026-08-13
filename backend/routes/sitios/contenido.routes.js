const express = require('express');

const router = express.Router();

const {
  obtenerContenidos,
  obtenerContenido,
  crearContenido,
  actualizarContenido,
  desactivarContenido,
  activarContenido,
  eliminarContenido
} = require('../../controllers/sitio/contenido.controller');

router.get('/sitio/:sitioId', obtenerContenidos);

router.get('/:id', obtenerContenido);

router.post('/', crearContenido);

router.put('/:id', actualizarContenido);

router.put('/:id/desactivar', desactivarContenido);

router.put('/:id/activar', activarContenido);

router.delete('/:id', eliminarContenido);

module.exports = router;