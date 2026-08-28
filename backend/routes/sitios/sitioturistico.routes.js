const express = require('express');

const router = express.Router();

const {
  obtenerSitios,
  obtenerSitio,
} = require(
  '../../controllers/sitio/sitioturistico.controller'
);

// ============================================================
// LISTAR SITIOS TURÍSTICOS
// ============================================================

router.get(
  '/',
  obtenerSitios
);

// ============================================================
// OBTENER SITIO POR ID
// ============================================================

router.get(
  '/:id',
  obtenerSitio
);

module.exports = router;