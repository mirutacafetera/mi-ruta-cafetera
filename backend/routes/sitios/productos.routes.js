const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const { upload } = require('../../middlewares/uploadmiddleware');

const {
  obtenerProductos,
  obtenerProductosPropietario,
  crearProducto,
  actualizarProducto,
  enviarProductoRevision,
  eliminarProducto,
  subirImagenesProducto,
  eliminarImagenProducto,
  establecerImagenPrincipalProducto
} = require('../../controllers/sitio/productos.controller');

router.get(
  '/:id/propietario',
  verificarToken,
  verificarSitio,
  obtenerProductosPropietario
);

router.get(
  '/:id',
  obtenerProductos
);

router.post(
  '/:id',
  verificarToken,
  verificarSitio,
  crearProducto
);

router.post(
  '/:id/:productoId/imagenes',
  verificarToken,
  verificarSitio,
  upload.array('imagenes', 10),
  subirImagenesProducto
);

router.delete(
  '/:id/:productoId/imagenes',
  verificarToken,
  verificarSitio,
  eliminarImagenProducto
);

router.put(
  '/:id/:productoId/imagen-principal',
  verificarToken,
  verificarSitio,
  establecerImagenPrincipalProducto
);

router.put(
  '/:id/:productoId',
  verificarToken,
  verificarSitio,
  actualizarProducto
);

router.put(
  '/:id/:productoId/enviar-revision',
  verificarToken,
  verificarSitio,
  enviarProductoRevision
);

router.delete(
  '/:id/:productoId',
  verificarToken,
  verificarSitio,
  eliminarProducto
);

module.exports = router;