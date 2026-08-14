const express = require('express');

const router = express.Router();

const {
  registrar,
  iniciarSesion
} = require('../../controllers/usuario/auth.controller');

console.log('registrar:', typeof registrar);
console.log('iniciarSesion:', typeof iniciarSesion);

router.post('/registro', registrar);
router.post('/login', iniciarSesion);

module.exports = router;