const express = require('express');

const router = express.Router();

const {
  obtenerNotificaciones,
  crearNotificacion,
  marcarLeida
} = require('../../controllers/usuario/notificaciones.controller');

router.get('/:usuarioId', obtenerNotificaciones);

router.post('/', crearNotificacion);

router.put('/:id/leida', marcarLeida);

module.exports = router;