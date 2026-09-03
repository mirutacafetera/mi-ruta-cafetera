const express = require('express');

const {
  crearCuentaSitio
} = require('../../controllers/admin/authsitio.controller');

const router = express.Router();

// ======================================================
// CUENTAS DE SITIOS
// ======================================================

// El administrador crea una cuenta para un sitio existente
router.post('/cuenta', crearCuentaSitio);

module.exports = router;