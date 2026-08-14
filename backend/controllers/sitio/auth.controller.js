const CuentaSitio = require('../../models/sitio/cuentaSitios');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const iniciarSesion = async (req, res) => {
  try {
    const { correo, password } = req.body;

    const cuenta = await CuentaSitio.findOne({ correo });

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta del sitio no encontrada'
      });
    }

    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje: 'Cuenta del sitio inactiva'
      });
    }

    const passwordCorrecta = await bcrypt.compare(
      password,
      cuenta.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Contraseña incorrecta'
      });
    }

    const token = jwt.sign(
      {
        id: cuenta._id,
        rol: 'sitio'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    res.json({
      mensaje: 'Inicio de sesión del sitio exitoso',
      token,
      cuenta: {
        id: cuenta._id,
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono,
        rol: 'sitio'
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al iniciar sesión como sitio',
      error: error.message
    });
  }
};

module.exports = {
  iniciarSesion
};