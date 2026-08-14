const Usuario = require('../../models/usuario/usuario');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// ==========================================
// REGISTRAR USUARIO
// ==========================================
const registrar = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      correo,
      password,
      telefono,
      ciudad,
      fotoPerfil
    } = req.body;

    // Validar campos obligatorios
    if (!nombre || !apellido || !correo || !password) {
      return res.status(400).json({
        mensaje: 'Nombre, apellido, correo y contraseña son obligatorios'
      });
    }

    // Comprobar si el correo ya existe
    const usuarioExiste = await Usuario.findOne({
      correo: correo.toLowerCase()
    });

    if (usuarioExiste) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    // Encriptar contraseña
    const passwordEncriptada = await bcrypt.hash(password, 10);

    // Crear usuario
    const usuario = new Usuario({
      nombre,
      apellido,
      correo: correo.toLowerCase(),
      password: passwordEncriptada,
      telefono,
      ciudad,
      fotoPerfil
    });

    await usuario.save();

    // Respuesta sin contraseña
    res.status(201).json({
      mensaje: 'Usuario registrado correctamente',
      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        correo: usuario.correo,
        telefono: usuario.telefono,
        ciudad: usuario.ciudad,
        fotoPerfil: usuario.fotoPerfil
      }
    });

  } catch (error) {
    console.error('Error al registrar usuario:', error);

    res.status(500).json({
      mensaje: 'Error al registrar usuario',
      error: error.message
    });
  }
};


// ==========================================
// INICIAR SESIÓN
// ==========================================
const iniciarSesion = async (req, res) => {
  try {
    const { correo, password } = req.body;

    // Validar campos
    if (!correo || !password) {
      return res.status(400).json({
        mensaje: 'Correo y contraseña son obligatorios'
      });
    }

    // Buscar usuario incluyendo password
    const usuario = await Usuario.findOne({
      correo: correo.toLowerCase()
    }).select('+password');

    if (!usuario) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    // Comparar contraseña
    const passwordCorrecta = await bcrypt.compare(
      password,
      usuario.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    // Crear JWT
    const token = jwt.sign(
      {
        id: usuario._id
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    // Respuesta sin contraseña
    res.status(200).json({
      mensaje: 'Inicio de sesión exitoso',
      token,
      usuario: {
        id: usuario._id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        correo: usuario.correo,
        telefono: usuario.telefono,
        ciudad: usuario.ciudad,
        fotoPerfil: usuario.fotoPerfil
      }
    });

  } catch (error) {
    console.error('Error al iniciar sesión:', error);

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