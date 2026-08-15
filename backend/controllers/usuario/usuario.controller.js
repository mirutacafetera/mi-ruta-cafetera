const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const Usuario = require('../../models/usuario/usuario');


// =====================================================
// REGISTRAR USUARIO
// =====================================================

const registrarUsuario = async (req, res) => {
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


    // Normalizar correo
    const correoNormalizado = correo.toLowerCase().trim();


    // Verificar si el correo ya existe
    const usuarioExistente = await Usuario.findOne({
      correo: correoNormalizado
    });

    if (usuarioExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }


    // Encriptar contraseña
    const passwordEncriptada = await bcrypt.hash(
      password,
      10
    );


    // Crear usuario
    const usuario = new Usuario({
      nombre,
      apellido,
      correo: correoNormalizado,
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

    console.error(
      'Error al registrar usuario:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al registrar usuario',
      error: error.message
    });
  }
};


// =====================================================
// INICIAR SESIÓN
// =====================================================

const iniciarSesionUsuario = async (req, res) => {
  try {

    const {
      correo,
      password
    } = req.body;


    // Validar campos
    if (!correo || !password) {
      return res.status(400).json({
        mensaje: 'Correo y contraseña son obligatorios'
      });
    }


    // Normalizar correo
    const correoNormalizado = correo.toLowerCase().trim();


    // Buscar usuario
    const usuario = await Usuario
      .findOne({
        correo: correoNormalizado
      })
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
        expiresIn:
          process.env.JWT_EXPIRES_IN || '1d'
      }
    );


    // Respuesta
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

    console.error(
      'Error al iniciar sesión:',
      error
    );

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


    res.status(200).json(usuario);

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


    // Verificar propietario
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


    res.status(200).json({
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

    // Verificar propietario
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


    res.status(200).json({
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
// EXPORTAR
// =====================================================

module.exports = {
  registrarUsuario,
  iniciarSesionUsuario,
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
};