const express = require('express');

const router = express.Router();

const {
  crearAdministrador,
  obtenerAdministrador,
  actualizarAdministrador,
  eliminarAdministrador
} = require('../../controllers/admin/administrador.controller');

router.post('/', crearAdministrador);
router.get('/:id', obtenerAdministrador);
router.put('/:id', actualizarAdministrador);
router.delete('/:id', eliminarAdministrador);

module.exports = router;
