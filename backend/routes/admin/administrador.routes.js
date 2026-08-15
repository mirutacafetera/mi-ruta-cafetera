const express = require('express');

const router = express.Router();

const {
  registrarAdministrador,
  iniciarSesionAdministrador,
  obtenerAdministrador,
  actualizarAdministrador,
  cambiarEstadoAdministrador
} = require('../../controllers/admin/administrador.controller');


// Registrar administrador
router.post('/registrar', registrarAdministrador);

// Login
router.post('/login', iniciarSesionAdministrador);

// Obtener administrador
router.get('/:id', obtenerAdministrador);

// Actualizar administrador
router.put('/:id', actualizarAdministrador);

// Activar / desactivar
router.patch('/:id/estado', cambiarEstadoAdministrador);


module.exports = router;