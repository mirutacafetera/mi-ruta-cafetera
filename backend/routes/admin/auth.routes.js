const express = require('express');

const router = express.Router();

const {
  registrar,
  iniciarSesion
} = require('../../controllers/admin/auth.controller');


// POST /auth/registro
router.post('/registro', registrar);

// POST /auth/login
router.post('/login', iniciarSesion);


module.exports = router;