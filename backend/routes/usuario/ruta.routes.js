const express = require('express');

const router = express.Router();

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
// CONTROLADOR DE CÁLCULO DE RUTAS
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
// Este endpoint debe estar definido antes de las rutas
// dinámicas.
//
// Recibe:
//
// {
//   "puntos": [
//     {
//       "latitud": 2.20,
//       "longitud": -75.60
//     },
//     {
//       "latitud": 2.21,
//       "longitud": -75.61
//     }
//   ]
// }
//
// Mínimo: 2 puntos.
//
// Puede recibir 2, 3, 4, 5 o más sitios.
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
// Esta ruta debe estar ANTES de /:usuarioId,
// porque "predefinidas" podría ser interpretado
// como un usuarioId.
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
// ============================================================

router.get(
  '/:usuarioId',
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
// ============================================================

router.post(
  '/',
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
// ============================================================

router.put(
  '/:id',
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
// ============================================================

router.delete(
  '/:id',
  eliminarRuta
);

// ============================================================
// EXPORTAR ROUTER
// ============================================================

module.exports = router;