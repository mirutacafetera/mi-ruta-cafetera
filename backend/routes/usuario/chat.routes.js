const express = require('express');

const {
  chatConGroq
} = require('../../controllers/usuario/chat.controller');

const {
  verificarToken
} = require('../../middlewares/authmiddleware');

const {
  crearLimitador
} = require('../../middlewares/ratelimitmiddleware');

const router = express.Router();

// 30 mensajes cada 10 minutos por usuario.
const limitarChat = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 30,
  mensaje:
    'Has enviado muchos mensajes seguidos. ' +
    'Intenta de nuevo en unos minutos.'
});

// ======================================================
// CHAT CON GROQ
// POST /api/chat
//
// Requiere Authorization: Bearer <token> de un usuario.
// El controlador rechaza además cuentas de sitio y admin.
// ======================================================

router.post(
  '/',
  verificarToken,
  limitarChat,
  chatConGroq
);

module.exports = router;
