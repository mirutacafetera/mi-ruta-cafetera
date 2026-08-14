const Administrador = require('../../models/admin/administrador');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const iniciarSesion = async (req, res) => {
  try {
    const { email, password } = req.body;

    const administrador = await Administrador.findOne({ email });

    if (!administrador) {
      return res.status(404).json({
        mensaje: 'Administrador no encontrado'
      });
    }

    if (!administrador.activo) {
      return res.status(403).json({
        mensaje: 'Administrador inactivo'
      });
    }

    const passwordCorrecta = await bcrypt.compare(
      password,
      administrador.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Contraseña incorrecta'
      });
    }

    const token = jwt.sign(
      {
        id: administrador._id,
        rol: 'administrador'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    res.json({
      mensaje: 'Inicio de sesión administrativo exitoso',
      token,
      administrador: {
        id: administrador._id,
        nombre: administrador.nombre,
        apellido: administrador.apellido,
        email: administrador.email,
        rol: 'administrador'
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al iniciar sesión como administrador',
      error: error.message
    });
  }
};

module.exports = {
  iniciarSesion
};