const express = require('express');

const router = express.Router();

const {
  registrarUsuario,
  iniciarSesionUsuario,
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
} = require('../../controllers/usuario/usuario.controller');


// Registrar usuario
router.post('/registrar', registrarUsuario);

// Iniciar sesión
router.post('/login', iniciarSesionUsuario);

// Obtener usuario
router.get('/:id', obtenerUsuario);

// Actualizar usuario
router.put('/:id', actualizarUsuario);

// Eliminar cuenta
router.delete('/:id', eliminarUsuario);


module.exports = router;