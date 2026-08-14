const express = require('express');

const router = express.Router();

const {
  crearCuentaSitio,
  obtenerCuentaSitio,
  actualizarCuentaSitio,
  eliminarCuentaSitio
} = require('../../controllers/sitio/cuentaSitios.controller');


router.post('/', crearCuentaSitio);

router.get('/:id', obtenerCuentaSitio);

router.put('/:id', actualizarCuentaSitio);

router.delete('/:id', eliminarCuentaSitio);


module.exports = router;