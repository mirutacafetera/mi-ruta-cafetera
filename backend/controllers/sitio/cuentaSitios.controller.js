const CuentaSitio = require('../../models/sitio/cuentaSitios');

// CREAR CUENTA DE SITIO
const crearCuentaSitio = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      correo,
      password,
      telefono
    } = req.body;

    const cuentaExistente = await CuentaSitio.findOne({ correo });

    if (cuentaExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    const nuevaCuenta = new CuentaSitio({
      nombre,
      apellido,
      correo,
      password,
      telefono
    });

    await nuevaCuenta.save();

    res.status(201).json({
      mensaje: 'Cuenta del sitio creada correctamente',
      cuenta: {
        id: nuevaCuenta._id,
        nombre: nuevaCuenta.nombre,
        apellido: nuevaCuenta.apellido,
        correo: nuevaCuenta.correo,
        telefono: nuevaCuenta.telefono,
        activo: nuevaCuenta.activo
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear la cuenta del sitio',
      error: error.message
    });
  }
};


// OBTENER CUENTA
const obtenerCuentaSitio = async (req, res) => {
  try {
    const cuenta = await CuentaSitio.findById(req.params.id);

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta del sitio no encontrada'
      });
    }

    res.json(cuenta);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener la cuenta',
      error: error.message
    });
  }
};


// ACTUALIZAR CUENTA
const actualizarCuentaSitio = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      telefono
    } = req.body;

    const cuenta = await CuentaSitio.findByIdAndUpdate(
      req.params.id,
      {
        nombre,
        apellido,
        telefono
      },
      {
        new: true,
        runValidators: true
      }
    );

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta del sitio no encontrada'
      });
    }

    res.json({
      mensaje: 'Cuenta actualizada correctamente',
      cuenta
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar la cuenta',
      error: error.message
    });
  }
};


// ELIMINAR CUENTA
const eliminarCuentaSitio = async (req, res) => {
  try {
    const cuenta = await CuentaSitio.findByIdAndDelete(req.params.id);

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta del sitio no encontrada'
      });
    }

    res.json({
      mensaje: 'Cuenta del sitio eliminada correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar la cuenta',
      error: error.message
    });
  }
};


module.exports = {
  crearCuentaSitio,
  obtenerCuentaSitio,
  actualizarCuentaSitio,
  eliminarCuentaSitio
};