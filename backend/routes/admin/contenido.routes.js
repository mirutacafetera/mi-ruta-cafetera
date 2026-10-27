
const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarAdministrador,
} = require('../../middlewares/authmiddleware');

const {
  obtenerContenidos,
  obtenerContenido,
  actualizarContenido,
  aprobarContenido,
  rechazarContenido,
  desactivarContenido,
  activarContenido,
  eliminarContenido,
} = require('../../controllers/admin/contenido.controller');

// Consultar contenidos.
router.get('/', verificarToken, verificarAdministrador, obtenerContenidos);

// Consultar un contenido específico.
router.get('/:id', verificarToken, verificarAdministrador, obtenerContenido);

// Editar información del contenido.
router.put('/:id', verificarToken, verificarAdministrador, actualizarContenido);

// Aprobar o rechazar contenido.
router.put(
  '/:id/aprobar',
  verificarToken,
  verificarAdministrador,
  aprobarContenido
);

router.put(
  '/:id/rechazar',
  verificarToken,
  verificarAdministrador,
  rechazarContenido
);

// Activar o desactivar contenido.
router.put(
  '/:id/desactivar',
  verificarToken,
  verificarAdministrador,
  desactivarContenido
);

router.put(
  '/:id/activar',
  verificarToken,
  verificarAdministrador,
  activarContenido
);

// Eliminar contenido.
router.delete(
  '/:id',
  verificarToken,
  verificarAdministrador,
  eliminarContenido
);

module.exports = router;
