const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarAdministrador,
} = require('../../middlewares/authmiddleware');

const {
  obtenerContenidosPendientes,
  obtenerDetalleContenido,
  aprobarContenido,
  rechazarContenido,
} = require('../../controllers/admin/moderacionContenido.controller');

// Todas las operaciones requieren un administrador autenticado.
router.use(verificarToken, verificarAdministrador);

router.get('/pendientes', obtenerContenidosPendientes);

router.get('/:id', obtenerDetalleContenido);

router.put('/:id/aprobar', aprobarContenido);

router.put('/:id/rechazar', rechazarContenido);

module.exports = router;