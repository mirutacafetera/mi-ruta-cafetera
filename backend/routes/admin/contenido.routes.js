
const express = require('express');

const router = express.Router();

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

// Consultar todos los contenidos o filtrar por estado.
router.get('/', obtenerContenidos);

// Consultar un contenido específico.
router.get('/:id', obtenerContenido);

// Editar información del contenido.
router.put('/:id', actualizarContenido);

// Moderación del administrador.
router.put('/:id/aprobar', aprobarContenido);
router.put('/:id/rechazar', rechazarContenido);

// Activar o desactivar un contenido ya aprobado.
router.put('/:id/desactivar', desactivarContenido);
router.put('/:id/activar', activarContenido);

// Eliminar un contenido.
router.delete('/:id', eliminarContenido);

module.exports = router;
