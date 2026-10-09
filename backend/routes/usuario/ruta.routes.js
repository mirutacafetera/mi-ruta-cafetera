const express = require('express');

const router = express.Router();

const {
  verificarToken
} = require('../../middlewares/authmiddleware');

// ============================================================
// CONTROLADOR CRUD DE RUTAS DEL USUARIO
// ============================================================

const {
  obtenerRutas,
  obtenerRutasPredefinidas,
  crearRuta,
  actualizarRuta,
  eliminarRuta
} = require(
  '../../controllers/usuario/rutas.controller'
);

// ============================================================
// CONTROLADOR DE CALCULO DE RUTAS
// ============================================================

const {
  calcularRuta
} = require(
  '../../controllers/ruta/ruta.controller'
);

// ============================================================
// CALCULAR RUTA REAL POR CARRETERA
// ============================================================
//
// POST
//
// /api/rutas/calcular
//
// Endpoint publico para calcular el recorrido real.
// ============================================================

router.post(
  '/calcular',
  calcularRuta
);

// ============================================================
// OBTENER RUTAS PREDEFINIDAS
// ============================================================
//
// GET
//
// /api/rutas/predefinidas
//
// Endpoint publico.
// ============================================================

router.get(
  '/predefinidas',
  obtenerRutasPredefinidas
);

// ============================================================
// OBTENER RUTAS DE UN USUARIO
// ============================================================
//
// GET
//
// /api/rutas/:usuarioId
//
// Requiere autenticacion.
// El controlador verificara que el usuario autenticado
// sea el propietario de las rutas consultadas.
// ============================================================

router.get(
  '/:usuarioId',
  verificarToken,
  obtenerRutas
);

// ============================================================
// CREAR RUTA
// ============================================================
//
// POST
//
// /api/rutas
//
// Requiere autenticacion.
// ============================================================

router.post(
  '/',
  verificarToken,
  crearRuta
);

// ============================================================
// ACTUALIZAR RUTA
// ============================================================
//
// PUT
//
// /api/rutas/:id
//
// Requiere autenticacion.
// El controlador verificara la propiedad de la ruta.
// ============================================================

router.put(
  '/:id',
  verificarToken,
  actualizarRuta
);

// ============================================================
// ELIMINAR RUTA
// ============================================================
//
// DELETE
//
// /api/rutas/:id
//
// Requiere autenticacion.
// El controlador verificara la propiedad de la ruta.
// ============================================================

router.delete(
  '/:id',
  verificarToken,
  eliminarRuta
);

// ============================================================
// EXPORTAR ROUTER
// ============================================================

module.exports = router;