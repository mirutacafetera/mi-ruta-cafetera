const express = require('express');

const router = express.Router();

const {
  obtenerRutas,
  crearRuta,
  actualizarRuta,
  eliminarRuta,
} = require(
  '../../controllers/usuario/rutas.controller'
);

const {
  calcularRuta,
} = require(
  '../../controllers/ruta/ruta.controller'
);

// ============================================================
// CALCULAR RUTA REAL POR CARRETERA
// ============================================================

router.post(
  '/calcular',
  calcularRuta
);

// ============================================================
// RUTAS GUARDADAS DEL USUARIO
// ============================================================

router.get(
  '/:usuarioId',
  obtenerRutas
);

router.post(
  '/',
  crearRuta
);

router.put(
  '/:id',
  actualizarRuta
);

router.delete(
  '/:id',
  eliminarRuta
);

module.exports = router;