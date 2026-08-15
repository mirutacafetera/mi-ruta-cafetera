const express = require('express');

const router = express.Router();

const {
  iniciarSesion
} = require('../../controllers/sitio/cuentaSitios.controller');


// =====================================================
// AUTENTICACIÓN DE CUENTA DEL SITIO
// =====================================================

router.post('/login', iniciarSesion);


module.exports = router;