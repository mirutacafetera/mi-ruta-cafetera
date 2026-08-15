const express = require('express');

const router = express.Router();

const {
  registrar,
  iniciarSesion
} = require('../../controllers/sitio/auth.controller');


// REGISTRAR CUENTA
router.post('/registro', registrar);


// INICIAR SESIÓN
router.post('/login', iniciarSesion);


module.exports = router;