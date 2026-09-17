const express = require('express');

const router = express.Router();

const {
  crearReporte,
  obtenerMisReportes
} = require('../../controllers/usuario/ayuda.controller');

const { verificarToken } = require('../../middlewares/authmiddleware');


// Crear reporte
router.post('/', verificarToken, crearReporte);


// Ver mis reportes
router.get('/', verificarToken, obtenerMisReportes);


module.exports = router;