const express = require('express');

const router = express.Router();

const {
  obtenerSitios,
  obtenerSitio,
  crearSitio,
  actualizarSitio,
  desactivarSitio,
  activarSitio,
  eliminarSitio
} = require('../../controllers/sitio/sitioturistico.controller');


// =====================================================
// SITIOS TURÍSTICOS
// =====================================================

// Obtener todos los sitios activos
router.get('/', obtenerSitios);

// Obtener un sitio por ID
router.get('/:id', obtenerSitio);

// Crear sitio
router.post('/', crearSitio);

// Actualizar sitio
router.put('/:id', actualizarSitio);

// Desactivar sitio
router.patch('/:id/desactivar', desactivarSitio);

// Activar sitio
router.patch('/:id/activar', activarSitio);

// Eliminar sitio
router.delete('/:id', eliminarSitio);


module.exports = router;