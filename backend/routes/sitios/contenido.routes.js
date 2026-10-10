const express = require('express');

const router = express.Router();

// ============================================================
// AUTENTICACIÓN
// ============================================================

const {
  verificarToken,
  verificarSitio,
} = require('../../middlewares/authmiddleware');

// ============================================================
// MIDDLEWARES DE CARGA
// ============================================================

const {
  upload,
  uploadAudio,
} = require('../../middlewares/uploadmiddleware');

// ============================================================
// CONTROLADOR PRINCIPAL DE CONTENIDO
// ============================================================

const {
  obtenerContenidos,
  obtenerMisContenidos,
  obtenerContenido,
  crearContenido,
  actualizarContenido,
  enviarContenidoRevision,
  subirImagenesContenido,
  eliminarContenido,
} = require('../../controllers/sitio/contenido.controller');

// ============================================================
// CONTROLADOR DE AUDIOGUÍAS
// ============================================================

const {
  subirAudioGuia,
  eliminarAudioGuia,
} = require('../../controllers/sitio/contenido.audioguia.controller');

// ============================================================
// CONTENIDO PÚBLICO
// GET /api/sitiosturisticos/contenido/sitio/:sitioId
// ============================================================

router.get(
  '/sitio/:sitioId',
  obtenerContenidos,
);

// ============================================================
// CONTENIDOS DEL SITIO AUTENTICADO
// GET /api/sitiosturisticos/contenido/mis-contenidos
// ============================================================

router.get(
  '/mis-contenidos',
  verificarToken,
  verificarSitio,
  obtenerMisContenidos,
);

// ============================================================
// OBTENER UN CONTENIDO
// GET /api/sitiosturisticos/contenido/:id
// ============================================================

router.get(
  '/:id',
  obtenerContenido,
);

// ============================================================
// CREAR CONTENIDO
// POST /api/sitiosturisticos/contenido
// ============================================================

router.post(
  '/',
  verificarToken,
  verificarSitio,
  crearContenido,
);

// ============================================================
// ACTUALIZAR CONTENIDO
// PUT /api/sitiosturisticos/contenido/:id
// ============================================================

router.put(
  '/:id',
  verificarToken,
  verificarSitio,
  actualizarContenido,
);

// ============================================================
// ENVIAR CONTENIDO A REVISIÓN
// PUT /:id/enviar-revision
// ============================================================

router.put(
  '/:id/enviar-revision',
  verificarToken,
  verificarSitio,
  enviarContenidoRevision,
);

// ============================================================
// ELIMINAR CONTENIDO
// DELETE /:id
// ============================================================

router.delete(
  '/:id',
  verificarToken,
  verificarSitio,
  eliminarContenido,
);

// ============================================================
// SUBIR IMÁGENES
// POST /:id/imagenes
// ============================================================

router.post(
  '/:id/imagenes',
  verificarToken,
  verificarSitio,
  (req, res, next) => {
    upload.fields([
      { name: 'imagenPrincipal', maxCount: 1 },
      { name: 'imagenes', maxCount: 10 },
    ])(req, res, (error) => {
      if (error) {
        console.error('Error al recibir imágenes:', error);

        return res.status(400).json({
          mensaje: 'No se pudieron recibir las imágenes.',
          error: error.message,
        });
      }

      next();
    });
  },
  subirImagenesContenido,
);

// ============================================================
// SUBIR AUDIOGUÍA
// POST /:id/audioguias
// ============================================================

router.post(
  '/:id/audioguias',
  verificarToken,
  verificarSitio,
  (req, res, next) => {
    uploadAudio.single('audio')(req, res, (error) => {
      if (error) {
        console.error('Error al recibir audioguía:', error);

        return res.status(400).json({
          mensaje: error.message || 'No se pudo recibir el audio.',
        });
      }

      next();
    });
  },
  subirAudioGuia,
);

// ============================================================
// ELIMINAR AUDIOGUÍA
// DELETE /:id/audioguias/:audioId
// ============================================================

router.delete(
  '/:id/audioguias/:audioId',
  verificarToken,
  verificarSitio,
  eliminarAudioGuia,
);

module.exports = router;