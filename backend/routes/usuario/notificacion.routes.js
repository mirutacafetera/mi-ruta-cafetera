const express = require('express');

const router = express.Router();

const {
  obtenerNotificaciones,
  contarNoLeidas,
  marcarLeida,
  marcarTodasLeidas
} = require('../../controllers/usuario/notificaciones.controller');

const {
  verificarToken,
  verificarUsuario
} = require('../../middlewares/authmiddleware');

// Las notificaciones son privadas: requieren sesión de usuario
// y solo devuelven las del propio usuario.
router.use(verificarToken, verificarUsuario);

router.get('/', obtenerNotificaciones);

// Deben ir antes de '/:usuarioId' para no confundirse con un id.
router.get('/no-leidas/total', contarNoLeidas);

// Compatibilidad con la ruta anterior (debe ser el mismo usuario).
router.get('/:usuarioId', obtenerNotificaciones);

router.put('/leidas/todas', marcarTodasLeidas);

router.put('/:id/leida', marcarLeida);

module.exports = router;
