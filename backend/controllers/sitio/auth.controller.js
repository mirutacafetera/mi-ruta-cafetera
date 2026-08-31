const CuentaSitio = require('../../models/sitio/cuentaSitios');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');


// ==========================================
// REGISTRAR CUENTA DEL SITIO
// ==========================================
const registrar = async (req, res) => {
  try {
    const {
      nombre,
      apellido,
      correo,
      password,
      telefono
    } = req.body;

    // Validar campos obligatorios
    if (!nombre || !apellido || !correo || !password) {
      return res.status(400).json({
        mensaje: 'Nombre, apellido, correo y contraseña son obligatorios'
      });
    }

    // Comprobar si ya existe
    const cuentaExistente = await CuentaSitio.findOne({
      correo: correo.toLowerCase()
    });

    if (cuentaExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    // Encriptar contraseña
    const passwordEncriptada = await bcrypt.hash(password, 10);

    // Crear cuenta
    const nuevaCuenta = new CuentaSitio({
      nombre,
      apellido,
      correo: correo.toLowerCase(),
      password: passwordEncriptada,
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
        activo: nuevaCuenta.activo,
        rol: 'sitio'
      }
    });

  } catch (error) {
    console.error('Error al registrar cuenta del sitio:', error);

    res.status(500).json({
      mensaje: 'Error al crear la cuenta del sitio',
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

    // Buscar cuenta
    const cuenta = await CuentaSitio.findOne({
      correo: correo.toLowerCase()
    }).select('+password');

    if (!cuenta) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    // Verificar si está activa
    if (!cuenta.activo) {
      return res.status(403).json({
        mensaje: 'La cuenta del sitio está inactiva'
      });
    }

    // Comparar contraseña
    const passwordCorrecta = await bcrypt.compare(
      password,
      cuenta.password
    );

    if (!passwordCorrecta) {
      return res.status(401).json({
        mensaje: 'Correo o contraseña incorrectos'
      });
    }

    // Crear token
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

    // Respuesta
    res.status(200).json({
      mensaje: 'Inicio de sesión del sitio exitoso',
      token,
      cuenta: {
        id: cuenta._id,
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono,
        rol: 'sitio',
        activo: cuenta.activo
      }
    });

  } catch (error) {

    console.error(
      'Error al iniciar sesión como sitio:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al iniciar sesión como sitio',
      error: error.message
    });
  }
};

module.exports = {
  registrar,
  iniciarSesion
};