const express = require('express');

const router = express.Router();

const {
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
} = require('../../controllers/usuario/usuario.controller');

console.log('obtenerUsuario:', typeof obtenerUsuario);
console.log('actualizarUsuario:', typeof actualizarUsuario);
console.log('eliminarUsuario:', typeof eliminarUsuario);

router.get('/:id', obtenerUsuario);
router.put('/:id', actualizarUsuario);
router.delete('/:id', eliminarUsuario);

module.exports = router;