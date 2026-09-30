const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarSitio
} = require('../../middlewares/authmiddleware');

const {
  obtenerInformacion,
  actualizarInformacion
} = require('../../controllers/sitio/informacion.controller');


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


module.exports = router;