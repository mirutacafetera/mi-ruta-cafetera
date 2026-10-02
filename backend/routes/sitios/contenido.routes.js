const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio,
} = require('../../middlewares/authmiddleware');

const {
  obtenerContenidos,
  obtenerMisContenidos,
  obtenerContenido,
  crearContenido,
  actualizarContenido,
  enviarContenidoRevision,
  desactivarContenido,
  activarContenido,
} = require('../../controllers/sitio/contenido.controller');

/**
 * =========================================================
 * CONTENIDO PÚBLICO
 * =========================================================
 *
 * Obtiene únicamente contenidos aprobados y activos
 * de un sitio turístico.
 *
 * GET
 * /api/sitiosturisticos/contenido/sitio/:sitioId
 */
router.get(
  '/sitio/:sitioId',
  obtenerContenidos
);

/**
 * =========================================================
 * CONTENIDO DEL SITIO AUTENTICADO
 * =========================================================
 *
 * El sitio puede consultar todos sus contenidos:
 * borradores, pendientes, aprobados y rechazados.
 *
 * GET
 * /api/sitiosturisticos/contenido/mis-contenidos
 */
router.get(
  '/mis-contenidos',
  verificarToken,
  verificarSitio,
  obtenerMisContenidos
);

/**
 * =========================================================
 * OBTENER UN CONTENIDO
 * =========================================================
 */
router.get(
  '/:id',
  obtenerContenido
);

/**
 * =========================================================
 * CREAR CONTENIDO
 * =========================================================
 */
router.post(
  '/',
  verificarToken,
  verificarSitio,
  crearContenido
);

/**
 * =========================================================
 * ACTUALIZAR CONTENIDO
 * =========================================================
 */
router.put(
  '/:id',
  verificarToken,
  verificarSitio,
  actualizarContenido
);

/**
 * =========================================================
 * ENVIAR CONTENIDO A REVISIÓN
 * =========================================================
 */
router.put(
  '/:id/enviar-revision',
  verificarToken,
  verificarSitio,
  enviarContenidoRevision
);

/**
 * =========================================================
 * DESACTIVAR CONTENIDO
 * =========================================================
 */
router.put(
  '/:id/desactivar',
  verificarToken,
  verificarSitio,
  desactivarContenido
);

/**
 * =========================================================
 * ACTIVAR CONTENIDO
 * =========================================================
 */
router.put(
  '/:id/activar',
  verificarToken,
  verificarSitio,
  activarContenido
);

module.exports = router;