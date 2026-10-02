const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio,
} = require('../../middlewares/authmiddleware');

const {
  upload,
} = require('../../middlewares/uploadmiddleware');

const {
  obtenerMultimedia,
  subirImagen,
  actualizarMultimedia,
} = require('../../controllers/sitio/multimedia.controller');

// ======================================================
// OBTENER MULTIMEDIA
// ======================================================

router.get(
  '/:id',
  obtenerMultimedia
);

// ======================================================
// SUBIR IMAGEN
// ======================================================

router.post(
  '/',
  verificarToken,
  verificarSitio,
  upload.single('imagen'),
  subirImagen
);

// ======================================================
// ACTUALIZAR MULTIMEDIA
// ======================================================

router.put(
  '/:id',
  verificarToken,
  verificarSitio,
  actualizarMultimedia
);

module.exports = router;