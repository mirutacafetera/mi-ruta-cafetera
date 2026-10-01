const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  upload
} = require('../../middlewares/uploadmiddleware');

const {
  obtenerInformacion,
  actualizarInformacion,
  subirImagenPrincipal
} = require(
  '../../controllers/sitio/informacion.controller'
);


// ======================================================
// INFORMACIÓN DEL SITIO AUTENTICADO
// ======================================================

// Obtener información

router.get(
  '/',
  verificarToken,
  verificarSitio,
  obtenerInformacion
);


// Actualizar información

router.put(
  '/',
  verificarToken,
  verificarSitio,
  actualizarInformacion
);


// ======================================================
// IMAGEN PRINCIPAL DEL SITIO
// ======================================================

router.post(
  '/imagen',
  verificarToken,
  verificarSitio,
  upload.single('imagen'),
  subirImagenPrincipal
);


module.exports = router;