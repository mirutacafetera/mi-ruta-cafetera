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

const {
  obtenerHistorialRevisionIA,
} = require('../../controllers/admin/historial_revision_ia.controller');

// Todas las operaciones requieren un administrador autenticado.
router.use(verificarToken, verificarAdministrador);

// Obtener contenidos pendientes de revisión.
router.get('/pendientes', obtenerContenidosPendientes);

// NUEVO: consultar el historial de revisiones realizadas por la IA.
router.get('/historial-ia', obtenerHistorialRevisionIA);

// Obtener el detalle de un contenido.
router.get('/:id', obtenerDetalleContenido);

// Aprobar contenido manualmente.
router.put('/:id/aprobar', aprobarContenido);

// Rechazar contenido manualmente.
router.put('/:id/rechazar', rechazarContenido);

module.exports = router;