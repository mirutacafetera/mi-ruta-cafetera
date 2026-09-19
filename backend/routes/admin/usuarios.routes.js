const express = require('express');

const router = express.Router();

const {
  obtenerUsuarios,
  obtenerUsuario,
  desactivarUsuario,
  activarUsuario,
  eliminarUsuario
} = require('../../controllers/admin/usuarios.controller');

router.get('/', obtenerUsuarios);

router.get('/:id', obtenerUsuario);

router.put('/:id/desactivar', desactivarUsuario);

router.put('/:id/activar', activarUsuario);

router.delete('/:id', eliminarUsuario);

module.exports = router;