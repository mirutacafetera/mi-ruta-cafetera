const express = require('express');

const router = express.Router();

const {
  obtenerNotificaciones,
  marcarLeida
} = require('../../controllers/usuario/notificaciones.controller');

router.get('/:usuarioId', obtenerNotificaciones);

router.put('/:id/leida', marcarLeida);

module.exports = router;