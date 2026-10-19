const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');

const {
  obtenerProductosPendientes,
  obtenerProducto,
  aprobarProducto,
  rechazarProducto
} = require('../../controllers/admin/productos.controller');

router.get(
  '/pendientes',
  verificarToken,
  verificarAdministrador,
  obtenerProductosPendientes
);

router.get(
  '/:id',
  verificarToken,
  verificarAdministrador,
  obtenerProducto
);

router.put(
  '/:id/aprobar',
  verificarToken,
  verificarAdministrador,
  aprobarProducto
);

router.put(
  '/:id/rechazar',
  verificarToken,
  verificarAdministrador,
  rechazarProducto
);

module.exports = router;