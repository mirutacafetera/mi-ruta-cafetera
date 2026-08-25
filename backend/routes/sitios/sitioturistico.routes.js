const express = require('express');

const router = express.Router();

const {
  obtenerSitios,
  obtenerSitio,
  crearSitio,
  actualizarSitio,
  desactivarSitio,
  activarSitio,
  eliminarSitio
} = require(
  '../../controllers/sitio/sitioturistico.controller'
);

router.get(
  '/',
  obtenerSitios
);

router.patch(
  '/:id/desactivar',
  desactivarSitio
);

router.patch(
  '/:id/activar',
  activarSitio
);

router.get(
  '/:id',
  obtenerSitio
);

router.post(
  '/',
  crearSitio
);

router.put(
  '/:id',
  actualizarSitio
);

router.delete(
  '/:id',
  eliminarSitio
);

module.exports = router;