const express = require('express');

const router = express.Router();

const {
  obtenerNotificaciones,
  marcarLeida
} = require('../../controllers/usuario/notificaciones.controller');

const {
  verificarToken,
  verificarUsuario
} = require('../../middlewares/authmiddleware');

// Las notificaciones son privadas: requieren sesión de usuario
// y solo devuelven las del propio usuario.
router.use(verificarToken, verificarUsuario);

router.get('/', obtenerNotificaciones);

// Compatibilidad con la ruta anterior (debe ser el mismo usuario).
router.get('/:usuarioId', obtenerNotificaciones);

router.put('/:id/leida', marcarLeida);

module.exports = router;
