const express = require('express');

const router = express.Router();

const {
  crearUsuario,
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
} = require('../../controllers/usuario/usuario.controller');

router.post('/', crearUsuario);
router.get('/:id', obtenerUsuario);
router.put('/:id', actualizarUsuario);
router.delete('/:id', eliminarUsuario);

module.exports = router;