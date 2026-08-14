const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const Administrador = require('../../models/admin/administrador');


// ==========================================
// REGISTRAR ADMINISTRADOR
// ==========================================
const registrar = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      email,
      password
    } = req.body;

    // Validar campos obligatorios
    if (!nombre || !apellido || !email || !password) {
      return res.status(400).json({
        mensaje: 'Nombre, apellido, email y contraseña son obligatorios'
      });
    }

    // Comprobar si ya existe
    const administradorExistente = await Administrador.findOne({
      email: email.toLowerCase()
    });

    if (administradorExistente) {
      return res.status(400).json({
        mensaje: 'El email ya está registrado'
      });
    }

    // Encriptar contraseña
    const passwordEncriptada = await bcrypt.hash(password, 10);

    // Crear administrador
    const administrador = new Administrador({
      nombre,
      apellido,
      email: email.toLowerCase(),
      password: passwordEncriptada
    });

    await administrador.save();

    res.status(201).json({
      mensaje: 'Administrador registrado correctamente',
      administrador: {
        id: administrador._id,
        nombre: administrador.nombre,
        apellido: administrador.apellido,
        email: administrador.email,
        activo: administrador.activo
      }
    });

  } catch (error) {
    console.error('Error al registrar administrador:', error);

    res.status(500).json({
      mensaje: 'Error al registrar administrador',
      error: error.message
    });
  }
};


// ==========================================
// LOGIN ADMINISTRADOR
// ==========================================
const iniciarSesion = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validar
    if (!email || !password) {
      return res.status(400).json({
        mensaje: 'Email y contraseña son obligatorios'
      });
    }

    // Buscar administrador
    const administrador = await Administrador.findOne({
      email: email.toLowerCase()
    });

    if (!administrador) {
      return res.status(401).json({
        mensaje: 'Email o contraseña incorrectos'
      });
    }

    // Comprobar si está activo
    if (!administrador.activo) {
      return res.status(403).json({
        mensaje: 'El administrador está inactivo'
      });
    }

    // Comparar contraseña
    const passwordCorrecta = await bcrypt.compare(
      password,
      administrador.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Email o contraseña incorrectos'
      });
    }

    // Crear token ADMIN
    const token = jwt.sign(
      {
        id: administrador._id,
        email: administrador.email,
        rol: 'admin'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '24h'
      }
    );

    res.status(200).json({
      mensaje: 'Inicio de sesión de administrador exitoso',
      token,
      administrador: {
        id: administrador._id,
        nombre: administrador.nombre,
        apellido: administrador.apellido,
        email: administrador.email,
        rol: 'admin',
        activo: administrador.activo
      }
    });

  } catch (error) {
    console.error('Error al iniciar sesión como administrador:', error);

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