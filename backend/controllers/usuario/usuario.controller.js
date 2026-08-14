const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const Usuario = require('../../models/usuario/usuario');

// =====================================================
// CREAR USUARIO
// =====================================================
const crearUsuario = async (req, res) => {
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

    // Verificar que el correo no exista
    const usuarioExistente = await Usuario.findOne({ correo });

    if (usuarioExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    // Encriptar contraseña
    const passwordHash = await bcrypt.hash(password, 10);

    // Crear usuario
    const nuevoUsuario = new Usuario({
      nombre,
      apellido,
      correo,
      password: passwordHash,
      telefono,
      ciudad,
      fotoPerfil
    });

    await nuevoUsuario.save();

    // Respuesta sin contraseña
    res.status(201).json({
      mensaje: 'Usuario creado correctamente',
      usuario: {
        id: nuevoUsuario._id,
        nombre: nuevoUsuario.nombre,
        apellido: nuevoUsuario.apellido,
        correo: nuevoUsuario.correo,
        telefono: nuevoUsuario.telefono,
        ciudad: nuevoUsuario.ciudad,
        fotoPerfil: nuevoUsuario.fotoPerfil
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear el usuario',
      error: error.message
    });
  }
};


// =====================================================
// LOGIN
// =====================================================
const loginUsuario = async (req, res) => {
  try {
    const { correo, password } = req.body;

    // Buscar usuario incluyendo password
    const usuario = await Usuario
      .findOne({ correo })
      .select('+password');

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
        id: usuario._id.toString(),
        correo: usuario.correo,
        rol: 'usuario'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRES_IN || '1d'
      }
    );

    // Respuesta
    res.json({
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
    res.status(500).json({
      mensaje: 'Error al iniciar sesión',
      error: error.message
    });
  }
};


// =====================================================
// OBTENER USUARIO
// =====================================================
const obtenerUsuario = async (req, res) => {
  try {
    const usuario = await Usuario
      .findById(req.params.id)
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


// =====================================================
// ACTUALIZAR USUARIO
// =====================================================
const actualizarUsuario = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      telefono,
      ciudad,
      fotoPerfil
    } = req.body;

    // Verificar que el usuario autenticado
    // sea el dueño de la cuenta
    if (req.usuario.id !== req.params.id) {
      return res.status(403).json({
        mensaje: 'No puedes modificar otro usuario'
      });
    }

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


// =====================================================
// ELIMINAR USUARIO
// =====================================================
const eliminarUsuario = async (req, res) => {
  try {
    // Verificar que el usuario autenticado
    // sea el dueño de la cuenta
    if (req.usuario.id !== req.params.id) {
      return res.status(403).json({
        mensaje: 'No puedes eliminar otro usuario'
      });
    }

    const usuario = await Usuario.findByIdAndDelete(
      req.params.id
    );

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


// =====================================================
// EXPORTAR FUNCIONES
// =====================================================
module.exports = {
  crearUsuario,
  loginUsuario,
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
};