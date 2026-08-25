const express = require('express');

const router = express.Router();

const {
  crearSitio,
  obtenerSitios,
  obtenerSitioPorId,
  actualizarSitio,
  desactivarSitio
} = require('../../controllers/admin/authsitio.controller');


// CREAR SITIO
router.post('/', crearSitio);

// OBTENER TODOS
router.get('/', obtenerSitios);

// OBTENER UNO
router.get('/:id', obtenerSitioPorId);

// ACTUALIZAR
router.put('/:id', actualizarSitio);

// DESACTIVAR
router.put('/:id/desactivar', desactivarSitio);


module.exports = router;