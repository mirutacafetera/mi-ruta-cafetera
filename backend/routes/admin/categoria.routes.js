const express = require('express');

const router = express.Router();

const {
  obtenerCategorias,
  obtenerCategoria,
  crearCategoria,
  actualizarCategoria,
  eliminarCategoria
} = require(
  '../../controllers/admin/categoria.controller'
);

router.get(
  '/',
  obtenerCategorias
);

router.get(
  '/:id',
  obtenerCategoria
);

router.post(
  '/',
  crearCategoria
);

router.put(
  '/:id',
  actualizarCategoria
);

router.delete(
  '/:id',
  eliminarCategoria
);

module.exports = router;