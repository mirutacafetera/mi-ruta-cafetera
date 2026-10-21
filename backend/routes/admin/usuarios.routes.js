const express = require('express');

const router = express.Router();

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');

const {
  obtenerUsuarios,
  obtenerUsuario,
  desactivarUsuario,
  activarUsuario,
  eliminarUsuario
} = require('../../controllers/admin/usuarios.controller');

// Proteger todas las rutas de este archivo.
router.use(verificarToken, verificarAdministrador);

// Obtener todos los usuarios.
router.get('/', obtenerUsuarios);

// Obtener un usuario por su ID.
router.get('/:id', obtenerUsuario);

// Desactivar una cuenta.
router.put('/:id/desactivar', desactivarUsuario);

// Activar una cuenta.
router.put('/:id/activar', activarUsuario);

// Eliminar y anonimizar una cuenta.
router.delete('/:id', eliminarUsuario);

module.exports = router;