const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const Administrador = require('../../models/admin/administrador');


// =====================================================
// REGISTRAR ADMINISTRADOR
// =====================================================

const registrarAdministrador = async (req, res) => {
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

    // Normalizar email
    const emailNormalizado = email.toLowerCase().trim();

    // Verificar si ya existe
    const administradorExistente = await Administrador.findOne({
      email: emailNormalizado
    });

    if (administradorExistente) {
      return res.status(400).json({
        mensaje: 'El email ya esta registrado'
      });
    }

    // Encriptar contraseña
    const passwordEncriptada = await bcrypt.hash(password, 10);

    // Crear administrador
    const administrador = new Administrador({
      nombre,
      apellido,
      email: emailNormalizado,
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


// =====================================================
// INICIAR SESIÓN
// =====================================================

const iniciarSesionAdministrador = async (req, res) => {
  try {
    const {
      email,
      password
    } = req.body;

    // Validar campos
    if (!email || !password) {
      return res.status(400).json({
        mensaje: 'Email y contraseña son obligatorios'
      });
    }

    // Normalizar email
    const emailNormalizado = email.toLowerCase().trim();

    // Buscar administrador
    const administrador = await Administrador.findOne({
      email: emailNormalizado
    });

    if (!administrador) {
      return res.status(401).json({
        mensaje: 'Email o contraseña incorrectos'
      });
    }

    // Verificar estado
    if (!administrador.activo) {
      return res.status(403).json({
        mensaje: 'El administrador esta inactivo'
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

    // Crear JWT
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
      mensaje: 'Inicio de sesión exitoso',
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
    console.error('Error al iniciar sesión:', error);

    res.status(500).json({
      mensaje: 'Error al iniciar sesión',
      error: error.message
    });
  }
};


// =====================================================
// OBTENER ADMINISTRADOR POR ID
// =====================================================

const obtenerAdministrador = async (req, res) => {
  try {
    const administrador = await Administrador.findById(req.params.id)
      .select('-password');

    if (!administrador) {
      return res.status(404).json({
        mensaje: 'Administrador no encontrado'
      });
    }

    res.status(200).json(administrador);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener el administrador',
      error: error.message
    });
  }
};


// =====================================================
// ACTUALIZAR ADMINISTRADOR
// =====================================================

const actualizarAdministrador = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      email,
      activo
    } = req.body;

    const datosActualizar = {
      nombre,
      apellido,
      email: email ? email.toLowerCase().trim() : undefined,
      activo
    };

    const administrador = await Administrador.findByIdAndUpdate(
      req.params.id,
      datosActualizar,
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

    res.status(200).json({
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


// =====================================================
// CAMBIAR ESTADO DEL ADMINISTRADOR
// =====================================================

const cambiarEstadoAdministrador = async (req, res) => {
  try {
    const {
      activo
    } = req.body;

    if (typeof activo !== 'boolean') {
      return res.status(400).json({
        mensaje: 'El campo activo debe ser true o false'
      });
    }

    const administrador = await Administrador.findByIdAndUpdate(
      req.params.id,
      {
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

    res.status(200).json({
      mensaje: activo
        ? 'Administrador activado correctamente'
        : 'Administrador desactivado correctamente',
      administrador
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al cambiar el estado del administrador',
      error: error.message
    });
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  registrarAdministrador,
  iniciarSesionAdministrador,
  obtenerAdministrador,
  actualizarAdministrador,
  cambiarEstadoAdministrador
};