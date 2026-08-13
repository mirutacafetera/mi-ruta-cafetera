const Usuario = require('../../models/usuario/usuario');

// OBTENER PERFIL
const obtenerUsuario = async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.params.id)
      .select('-password');

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    res.json(usuario);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener el usuario',
      error: error.message
    });
  }
};


// ACTUALIZAR PERFIL
const actualizarUsuario = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      telefono,
      ciudad,
      fotoPerfil
    } = req.body;

    const usuario = await Usuario.findByIdAndUpdate(
      req.params.id,
      {
        nombre,
        apellido,
        telefono,
        ciudad,
        fotoPerfil
      },
      {
        new: true,
        runValidators: true
      }
    ).select('-password');

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    res.json({
      mensaje: 'Perfil actualizado correctamente',
      usuario
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar el perfil',
      error: error.message
    });
  }
};


// ELIMINAR CUENTA
const eliminarUsuario = async (req, res) => {
  try {
    const usuario = await Usuario.findByIdAndDelete(req.params.id);

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    res.json({
      mensaje: 'Cuenta eliminada correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar la cuenta',
      error: error.message
    });
  }
};

module.exports = {
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
};

console.log('CARGANDO USUARIO CONTROLLER');
console.log({
  obtenerUsuario: typeof obtenerUsuario,
  actualizarUsuario: typeof actualizarUsuario,
  eliminarUsuario: typeof eliminarUsuario
});