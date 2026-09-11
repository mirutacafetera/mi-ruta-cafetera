const express = require('express');

const router = express.Router();


// =====================================================
// CONTROLLER
// =====================================================

const {
  crearReporte,
  obtenerReportes,
  obtenerReporte,
  responderReporte,
  cambiarEstadoReporte
} = require('../../controllers/ayuda/reporte.controller');


// =====================================================
// MIDDLEWARE
// =====================================================

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');


// =====================================================
// CREAR REPORTE
// Usuario o sitio autenticado
// =====================================================

router.post(
  '/',
  verificarToken,
  crearReporte
);


// =====================================================
// OBTENER TODOS LOS REPORTES
// Solo administrador
// =====================================================

router.get(
  '/',
  verificarToken,
  verificarAdministrador,
  obtenerReportes
);


// =====================================================
// OBTENER UN REPORTE
// Solo administrador
// =====================================================

router.get(
  '/:id',
  verificarToken,
  verificarAdministrador,
  obtenerReporte
);


// =====================================================
// RESPONDER REPORTE
// Solo administrador
// =====================================================

router.put(
  '/:id/responder',
  verificarToken,
  verificarAdministrador,
  responderReporte
);


// =====================================================
// CAMBIAR ESTADO
// Solo administrador
// =====================================================

router.put(
  '/:id/estado',
  verificarToken,
  verificarAdministrador,
  cambiarEstadoReporte
);


module.exports = router;