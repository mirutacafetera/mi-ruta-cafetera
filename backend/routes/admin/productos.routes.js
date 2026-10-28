
const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');

const {
  obtenerProductosPendientes,
  obtenerProductosPorEstado,
  obtenerProducto,
  aprobarProducto,
  rechazarProducto,
  eliminarProducto
} = require('../../controllers/admin/productos.controller');

router.get(
  '/pendientes',
  verificarToken,
  verificarAdministrador,
  obtenerProductosPendientes
);

router.get(
  '/estado/:estado',
  verificarToken,
  verificarAdministrador,
  obtenerProductosPorEstado
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

router.delete(
  '/:id',
  verificarToken,
  verificarAdministrador,
  eliminarProducto
);

module.exports = router;
