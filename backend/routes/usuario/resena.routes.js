const express = require('express');

const router = express.Router();

// ======================================================
// CONTROLADORES
// ======================================================

const {
  obtenerResenasPorSitio,
  crearResena,
  actualizarResena,
  eliminarResena
} = require('../../controllers/usuario/resenas.controller');

const uploadResenas = require('../../middlewares/uploadresenas');

// ======================================================
// MIDDLEWARE DE AUTENTICACIÓN
// ======================================================

const {
  verificarToken
} = require('../../middlewares/authmiddleware');

// ======================================================
// OBTENER RESEÑAS DE UN SITIO
// ======================================================

router.get(
  '/sitio/:sitioId',
  obtenerResenasPorSitio
);

// ======================================================
// CREAR RESEÑA
// ======================================================

router.post(
  '/',
  verificarToken,
  uploadResenas.array('imagenes', 10),
  crearResena
);

// ======================================================
// ACTUALIZAR RESEÑA
// ======================================================

router.put(
  '/:id',
  verificarToken,
  actualizarResena
);

// ======================================================
// ELIMINAR RESEÑA
// ======================================================

router.delete(
  '/:id',
  verificarToken,
  eliminarResena
);

// ======================================================
// EXPORTAR
// ======================================================

module.exports = router;