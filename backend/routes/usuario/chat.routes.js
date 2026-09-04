const express = require('express');

const {
  chatConGroq
} = require('../../controllers/usuario/chat.controller');

const router = express.Router();

// ======================================================
// CHAT CON GROQ
// ======================================================

router.post('/', chatConGroq);

module.exports = router;