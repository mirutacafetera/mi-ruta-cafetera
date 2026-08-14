const express = require('express');

const router = express.Router();

const {
  obtenerUsuarios,
  obtenerUsuario,
  actualizarUsuario,
  desactivarUsuario,
  eliminarUsuario
} = require('../../controllers/admin/usuarios.controller');

router.get('/', obtenerUsuarios);

router.get('/:id', obtenerUsuario);

router.put('/:id', actualizarUsuario);

router.put('/:id/desactivar', desactivarUsuario);

router.delete('/:id', eliminarUsuario);

module.exports = router;