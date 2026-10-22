const express = require('express');
const router = express.Router();

const {
  verificarToken,
  verificarAdministrador
} = require('../../middlewares/authmiddleware');

const {
  listarPredefinidas,
  crearPredefinida,
  actualizarPredefinida
} = require('../../controllers/admin/rutaPredefinida.controller');

// Todas las operaciones exigen sesión de administrador.
router.use(verificarToken, verificarAdministrador);

router.get('/', listarPredefinidas);
router.post('/', crearPredefinida);
router.put('/:id', actualizarPredefinida);

module.exports = router;
