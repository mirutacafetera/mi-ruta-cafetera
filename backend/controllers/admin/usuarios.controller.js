const Usuario = require('../../models/usuario/usuario');

const obtenerUsuarios = async (req, res) => {
  try {
    const usuarios = await Usuario.find()
      .select('-password');

    res.json(usuarios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener usuarios',
      error: error.message
    });
  }
};


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
      mensaje: 'Error al obtener usuario',
      error: error.message
    });
  }
};


const actualizarUsuario = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      telefono,
      ciudad,
      fotoPerfil,
      rol
    } = req.body;

    const usuario = await Usuario.findByIdAndUpdate(
      req.params.id,
      {
        nombre,
        apellido,
        telefono,
        ciudad,
        fotoPerfil,
        rol
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
      mensaje: 'Usuario actualizado correctamente',
      usuario
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar usuario',
      error: error.message
    });
  }
};


const desactivarUsuario = async (req, res) => {
  try {
    const usuario = await Usuario.findByIdAndUpdate(
      req.params.id,
      {
        activo: false
      },
      {
        new: true
      }
    ).select('-password');

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    res.json({
      mensaje: 'Usuario desactivado correctamente',
      usuario
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al desactivar usuario',
      error: error.message
    });
  }
};


const eliminarUsuario = async (req, res) => {
  try {
    const usuario = await Usuario.findByIdAndDelete(
      req.params.id
    );

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    res.json({
      mensaje: 'Usuario eliminado correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar usuario',
      error: error.message
    });
  }
};


module.exports = {
  obtenerUsuarios,
  obtenerUsuario,
  actualizarUsuario,
  desactivarUsuario,
  eliminarUsuario
};