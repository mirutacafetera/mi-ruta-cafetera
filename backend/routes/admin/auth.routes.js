const express = require('express');

const router = express.Router();

const {
  iniciarSesion
} = require('../../controllers/admin/auth.controller');

router.post('/login', iniciarSesion);

module.exports = router;