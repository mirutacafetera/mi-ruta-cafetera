const bcrypt = require('bcryptjs');

const SitioTuristico = require('../../models/admin/sitio');
const CuentaSitio = require('../../models/sitio/auth');

// ======================================================
// CREAR CUENTA PARA UN SITIO
// ======================================================

const crearCuentaSitio = async (req, res) => {
  try {
    const {
      sitioId,
      nombre,
      apellido,
      correo,
      password,
      telefono
    } = req.body;

    // --------------------------------------------------
    // VALIDAR CAMPOS OBLIGATORIOS
    // --------------------------------------------------

    if (
      !sitioId ||
      !nombre ||
      !apellido ||
      !correo ||
      !password
    ) {
      return res.status(400).json({
        mensaje:
          'sitioId, nombre, apellido, correo y password son obligatorios'
      });
    }

    // --------------------------------------------------
    // VERIFICAR QUE EL SITIO EXISTA
    // --------------------------------------------------

    const sitio = await SitioTuristico.findById(sitioId);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'El sitio turístico no existe'
      });
    }

    // --------------------------------------------------
    // VERIFICAR QUE EL SITIO ESTÉ ACTIVO
    // --------------------------------------------------

    if (!sitio.activo) {
      return res.status(400).json({
        mensaje: 'El sitio turístico está inactivo'
      });
    }

    // --------------------------------------------------
    // VERIFICAR SI EL SITIO YA TIENE UNA CUENTA
    // --------------------------------------------------

    const cuentaExistente = await CuentaSitio.findOne({
      sitioId
    });

    if (cuentaExistente) {
      return res.status(400).json({
        mensaje: 'Este sitio ya tiene una cuenta'
      });
    }

    // --------------------------------------------------
    // NORMALIZAR CORREO
    // --------------------------------------------------

    const correoNormalizado = correo
      .toLowerCase()
      .trim();

    // --------------------------------------------------
    // VERIFICAR SI EL CORREO YA EXISTE
    // --------------------------------------------------

    const correoExistente = await CuentaSitio.findOne({
      correo: correoNormalizado
    });

    if (correoExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    // --------------------------------------------------
    // ENCRIPTAR CONTRASEÑA
    // --------------------------------------------------

    const passwordEncriptada = await bcrypt.hash(
      password,
      10
    );

    // --------------------------------------------------
    // CREAR CUENTA
    // --------------------------------------------------

    const cuenta = new CuentaSitio({
      sitioId,
      nombre: nombre.trim(),
      apellido: apellido.trim(),
      correo: correoNormalizado,
      password: passwordEncriptada,
      telefono: telefono ? telefono.trim() : ''
    });

    await cuenta.save();

    // --------------------------------------------------
    // RESPUESTA
    // --------------------------------------------------

    res.status(201).json({
      mensaje: 'Cuenta del sitio creada correctamente',

      cuenta: {
        id: cuenta._id,
        sitioId: cuenta.sitioId,
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono,
        activo: cuenta.activo
      }
    });
  } catch (error) {
    console.error('Error al crear cuenta del sitio:', error);

    res.status(500).json({
      mensaje: 'Error al crear la cuenta del sitio',
      error: error.message
    });
  }
};

// ======================================================
// EXPORTAR
// ======================================================

module.exports = {
  crearCuentaSitio
};