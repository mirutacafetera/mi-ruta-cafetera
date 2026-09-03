const express = require('express');

const {
  crearCuentaSitio
} = require('../../controllers/admin/authsitio.controller');

const router = express.Router();

// ======================================================
// CREAR CUENTA DEL SITIO
// ======================================================

// El administrador crea una cuenta para un sitio
// turístico que ya existe.
router.post('/cuenta', crearCuentaSitio);

module.exports = router;