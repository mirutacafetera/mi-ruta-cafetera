const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  obtenerContenidos,
  obtenerContenido,
  crearContenido,
  actualizarContenido,
  desactivarContenido,
  activarContenido,
  eliminarContenido
} = require('../../controllers/sitio/contenido.controller');


// =====================================================
// CONTENIDO
// =====================================================

// Consultas públicas
router.get(
  '/sitio/:sitioId',
  obtenerContenidos
);

router.get(
  '/:id',
  obtenerContenido
);


// Operaciones privadas del sitio
router.post(
  '/',
  verificarToken,
  verificarSitio,
  crearContenido
);

router.put(
  '/:id',
  verificarToken,
  verificarSitio,
  actualizarContenido
);

router.put(
  '/:id/desactivar',
  verificarToken,
  verificarSitio,
  desactivarContenido
);

router.put(
  '/:id/activar',
  verificarToken,
  verificarSitio,
  activarContenido
);

router.delete(
  '/:id',
  verificarToken,
  verificarSitio,
  eliminarContenido
);


module.exports = router;