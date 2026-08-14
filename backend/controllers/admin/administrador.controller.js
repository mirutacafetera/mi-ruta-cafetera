const Administrador = require('../../models/admin/administrador');
const bcrypt = require('bcryptjs');

const crearAdministrador = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      email,
      password
    } = req.body;

    const administradorExistente = await Administrador.findOne({ email });

    if (administradorExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    const passwordEncriptada = await bcrypt.hash(password, 10);

    const nuevoAdministrador = new Administrador({
      nombre,
      apellido,
      email,
      password: passwordEncriptada
    });

    await nuevoAdministrador.save();

    res.status(201).json({
      mensaje: 'Administrador creado correctamente',
      administrador: {
        id: nuevoAdministrador._id,
        nombre: nuevoAdministrador.nombre,
        apellido: nuevoAdministrador.apellido,
        email: nuevoAdministrador.email,
        activo: nuevoAdministrador.activo
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear el administrador',
      error: error.message
    });
  }
};

const obtenerAdministrador = async (req, res) => {
  try {
    const administrador = await Administrador.findById(req.params.id)
      .select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje: 'Administrador no encontrado'
      });
    }

    res.json(administrador);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener el administrador',
      error: error.message
    });
  }
};

const actualizarAdministrador = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      email,
      activo
    } = req.body;

    const administrador = await Administrador.findByIdAndUpdate(
      req.params.id,
      {
        nombre,
        apellido,
        email,
        activo
      },
      {
        new: true,
        runValidators: true
      }
    ).select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje: 'Administrador no encontrado'
      });
    }

    res.json({
      mensaje: 'Administrador actualizado correctamente',
      administrador
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar el administrador',
      error: error.message
    });
  }
};

const eliminarAdministrador = async (req, res) => {
  try {
    const administrador = await Administrador.findByIdAndDelete(req.params.id);

    if (!administrador) {
      return res.status(404).json({
        mensaje: 'Administrador no encontrado'
      });
    }

    res.json({
      mensaje: 'Administrador eliminado correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar el administrador',
      error: error.message
    });
  }
};

module.exports = {
  crearAdministrador,
  obtenerAdministrador,
  actualizarAdministrador,
  eliminarAdministrador
};
