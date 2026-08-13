const Usuario = require('../../models/usuario/usuario');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// REGISTRAR USUARIO
const registrar = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      email,
      password,
      telefono,
      ciudad
    } = req.body;

    const usuarioExiste = await Usuario.findOne({ email });

    if (usuarioExiste) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    const passwordEncriptada = await bcrypt.hash(password, 10);

    const usuario = new Usuario({
      nombre,
      apellido,
      email,
      password: passwordEncriptada,
      telefono,
      ciudad
    });

    await usuario.save();

    res.status(201).json({
      mensaje: 'Usuario registrado correctamente',
      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        email: usuario.email,
        rol: usuario.rol
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al registrar usuario',
      error: error.message
    });
  }
};


// INICIAR SESIÓN
const iniciarSesion = async (req, res) => {
  try {
    const { email, password } = req.body;

    const usuario = await Usuario.findOne({ email });

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    const passwordCorrecta = await bcrypt.compare(
      password,
      usuario.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Contraseña incorrecta'
      });
    }

    const token = jwt.sign(
      {
        id: usuario._id,
        rol: usuario.rol
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    res.json({
      mensaje: 'Inicio de sesión exitoso',
      token,
      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        email: usuario.email,
        rol: usuario.rol
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al iniciar sesión',
      error: error.message
    });
  }
};

module.exports = {
  registrar,
  iniciarSesion
};