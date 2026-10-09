const express = require('express');

const router = express.Router();

const {
  verificarToken
} = require('../../middlewares/authmiddleware');

const {
  obtenerFavoritos,
  agregarFavorito,
  eliminarFavorito
} = require('../../controllers/usuario/favoritos.controller');


/**
 * =========================================================
 * FAVORITOS DEL USUARIO
 * =========================================================
 *
 * Todas las operaciones de favoritos son privadas.
 *
 * El usuario debe enviar:
 *
 * Authorization: Bearer TOKEN
 *
 * =========================================================
 */


/**
 * =========================================================
 * OBTENER FAVORITOS
 * =========================================================
 *
 * GET
 * /api/favoritos/:usuarioId
 *
 * Se mantiene :usuarioId para no romper Flutter.
 *
 * El middleware verifica el JWT y el controller
 * comprueba que ese ID corresponda al usuario autenticado.
 */
router.get(
  '/:usuarioId',
  verificarToken,
  obtenerFavoritos
);


/**
 * =========================================================
 * AGREGAR FAVORITO
 * =========================================================
 *
 * POST
 * /api/favoritos
 *
 * Requiere autenticación.
 */
router.post(
  '/',
  verificarToken,
  agregarFavorito
);


/**
 * =========================================================
 * ELIMINAR FAVORITO
 * =========================================================
 *
 * DELETE
 * /api/favoritos/:id
 *
 * Requiere autenticación.
 *
 * El controller verifica además que el favorito
 * pertenezca al usuario autenticado.
 */
router.delete(
  '/:id',
  verificarToken,
  eliminarFavorito
);


/**
 * =========================================================
 * EXPORTAR
 * =========================================================
 */

module.exports = router;