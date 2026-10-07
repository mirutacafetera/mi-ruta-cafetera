const express = require('express');

const {
  crearSitio,
  obtenerSitios,
  obtenerSitio,
  actualizarSitio,
  eliminarSitio
} = require('../../controllers/admin/sitio.controller');

const { upload } = require('../../middlewares/uploadmiddleware');

const router = express.Router();

// ============================================================
// CREAR SITIO
// ============================================================

router.post(
  '/',
  upload.single('imagen'),
  crearSitio
);

// ============================================================
// OBTENER SITIOS
// ============================================================

router.get(
  '/',
  obtenerSitios
);

// ============================================================
// OBTENER UN SITIO
// ============================================================

router.get(
  '/:id',
  obtenerSitio
);

// ============================================================
// ACTUALIZAR SITIO
// ============================================================

router.put(
  '/:id',
  upload.single('imagen'),
  actualizarSitio
);

// ============================================================
// ELIMINAR SITIO
// ============================================================

router.delete(
  '/:id',
  eliminarSitio
);

module.exports = router;