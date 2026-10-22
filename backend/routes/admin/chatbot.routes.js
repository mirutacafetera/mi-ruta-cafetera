
const express = require('express');

const {
  verificarToken,
  verificarAdministrador,
} = require('../../middlewares/authmiddleware');

const {
  chatConGroq,
} = require('../../controllers/usuario/chat.controller');

const router = express.Router();

// Todas las peticiones requieren un administrador autenticado.
router.use(verificarToken, verificarAdministrador);

// Chat exclusivo del panel administrativo.
router.post('/', chatConGroq);

module.exports = router;
