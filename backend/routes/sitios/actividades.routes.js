const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  obtenerActividades,
  crearActividad,
  actualizarActividad,
  enviarActividadRevision,
  desactivarActividad
} = require('../../controllers/sitio/actividades.controller');

// ======================================================
// OBTENER ACTIVIDADES
// ======================================================

router.get(
  '/:id',
  obtenerActividades
);

// ======================================================
// CREAR ACTIVIDAD
// ======================================================

router.post(
  '/:id',
  verificarToken,
  verificarSitio,
  crearActividad
);

// ======================================================
// ACTUALIZAR ACTIVIDAD
// ======================================================

router.put(
  '/:id/:actividadId',
  verificarToken,
  verificarSitio,
  actualizarActividad
);

// ======================================================
// ENVIAR ACTIVIDAD A REVISIÓN
// ======================================================

router.put(
  '/:id/:actividadId/enviar-revision',
  verificarToken,
  verificarSitio,
  enviarActividadRevision
);

// ======================================================
// DESACTIVAR ACTIVIDAD
// ======================================================

router.put(
  '/:id/:actividadId/desactivar',
  verificarToken,
  verificarSitio,
  desactivarActividad
);

module.exports = router;