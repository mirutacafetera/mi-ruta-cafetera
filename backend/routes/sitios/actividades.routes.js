const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const { upload } = require('../../middlewares/uploadmiddleware');

const {
  obtenerActividades,
  crearActividad,
  actualizarActividad,
  subirImagenesActividad,
  eliminarImagenActividad,
  establecerImagenPrincipal,
  enviarActividadRevision,
  eliminarActividad
} = require('../../controllers/sitio/actividades.controller');

router.get(
  '/:id',
  obtenerActividades
);

router.post(
  '/:id',
  verificarToken,
  verificarSitio,
  crearActividad
);

router.post(
  '/:id/:actividadId/imagenes',
  verificarToken,
  verificarSitio,
  upload.array('imagenes', 10),
  subirImagenesActividad
);

router.delete(
  '/:id/:actividadId/imagenes',
  verificarToken,
  verificarSitio,
  eliminarImagenActividad
);

router.put(
  '/:id/:actividadId/imagen-principal',
  verificarToken,
  verificarSitio,
  establecerImagenPrincipal
);

router.put(
  '/:id/:actividadId',
  verificarToken,
  verificarSitio,
  actualizarActividad
);

router.put(
  '/:id/:actividadId/enviar-revision',
  verificarToken,
  verificarSitio,
  enviarActividadRevision
);

router.delete(
  '/:id/:actividadId',
  verificarToken,
  verificarSitio,
  eliminarActividad
);

module.exports = router;