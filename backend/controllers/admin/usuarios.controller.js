const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');

const Usuario = require('../../models/usuario/usuario');
const Administrador = require('../../models/admin/administrador');

// =====================================================
// OBTENER TODOS LOS USUARIOS
// =====================================================

const obtenerUsuarios = async (req, res) => {
  try {
    const usuarios = await Usuario.find()
      .select('-password')
      .sort({ createdAt: -1 });

    return res.status(200).json(usuarios);
  } catch (error) {
    console.error('Error al obtener usuarios:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener usuarios'
    });
  }
};

// =====================================================
// OBTENER UN USUARIO POR ID
// =====================================================

const obtenerUsuario = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El identificador del usuario no es válido'
      });
    }

    const usuario = await Usuario.findById(id)
      .select('-password');

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    return res.status(200).json(usuario);
  } catch (error) {
    console.error('Error al obtener usuario:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener usuario'
    });
  }
};

// =====================================================
// DESACTIVAR USUARIO
// =====================================================

const desactivarUsuario = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El identificador del usuario no es válido'
      });
    }

    const usuario = await Usuario.findById(id);

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    if (usuario.eliminadoAt || usuario.eliminacion?.fecha) {
      return res.status(400).json({
        mensaje: 'No se puede desactivar una cuenta eliminada'
      });
    }

    if (usuario.activo === false) {
      return res.status(400).json({
        mensaje: 'La cuenta ya está desactivada'
      });
    }

    usuario.activo = false;

    await usuario.save();

    const usuarioActualizado = await Usuario.findById(id)
      .select('-password');

    return res.status(200).json({
      mensaje: 'Usuario desactivado correctamente',
      usuario: usuarioActualizado
    });
  } catch (error) {
    console.error('Error al desactivar usuario:', error);

    return res.status(500).json({
      mensaje: 'Error al desactivar usuario'
    });
  }
};

// =====================================================
// ACTIVAR USUARIO
// =====================================================

const activarUsuario = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El identificador del usuario no es válido'
      });
    }

    const usuario = await Usuario.findById(id);

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    if (usuario.eliminadoAt || usuario.eliminacion?.fecha) {
      return res.status(400).json({
        mensaje: 'No se puede activar una cuenta eliminada'
      });
    }

    if (usuario.activo === true) {
      return res.status(400).json({
        mensaje: 'La cuenta ya está activa'
      });
    }

    usuario.activo = true;

    await usuario.save();

    const usuarioActualizado = await Usuario.findById(id)
      .select('-password');

    return res.status(200).json({
      mensaje: 'Usuario activado correctamente',
      usuario: usuarioActualizado
    });
  } catch (error) {
    console.error('Error al activar usuario:', error);

    return res.status(500).json({
      mensaje: 'Error al activar usuario'
    });
  }
};

// =====================================================
// ELIMINAR Y ANONIMIZAR USUARIO
// =====================================================

const eliminarUsuario = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El identificador del usuario no es válido'
      });
    }

    const usuario = await Usuario.findById(id)
      .select('+password');

    if (!usuario) {
      return res.status(404).json({
        mensaje: 'Usuario no encontrado'
      });
    }

    if (usuario.eliminadoAt || usuario.eliminacion?.fecha) {
      return res.status(400).json({
        mensaje: 'Esta cuenta ya fue eliminada'
      });
    }

    // -------------------------------------------------
    // IDENTIFICAR AL ADMINISTRADOR RESPONSABLE
    // -------------------------------------------------

    const administradorId = req.usuario?.id;

    if (
      !administradorId ||
      !mongoose.Types.ObjectId.isValid(administradorId)
    ) {
      return res.status(401).json({
        mensaje: 'No se pudo identificar al administrador'
      });
    }

    const administrador = await Administrador.findById(
      administradorId
    ).select('nombre apellido correo');

    if (!administrador) {
      return res.status(401).json({
        mensaje: 'No se encontró al administrador responsable'
      });
    }

    const responsableNombre = [
      administrador.nombre,
      administrador.apellido
    ]
      .filter(
        (parte) =>
          typeof parte === 'string' && parte.trim()
      )
      .join(' ')
      .trim();

    if (!responsableNombre) {
      return res.status(400).json({
        mensaje: 'El administrador no tiene un nombre registrado'
      });
    }

    // -------------------------------------------------
    // GUARDAR LOS DATOS ORIGINALES ANTES DE ANONIMIZAR
    // -------------------------------------------------

    const fechaEliminacion = new Date();

    const nombreUsuario = [
      usuario.nombre,
      usuario.apellido
    ]
      .filter(
        (parte) =>
          typeof parte === 'string' && parte.trim()
      )
      .join(' ')
      .trim();

    const correoOriginal = usuario.correo;

    const motivo =
      typeof req.body?.motivo === 'string'
        ? req.body.motivo.trim().slice(0, 500)
        : '';

    usuario.eliminacion = {
      tipo: 'administrador',
      usuarioNombre: nombreUsuario,
      usuarioCorreo: correoOriginal,
      responsableId: administrador._id,
      responsableNombre,
      fecha: fechaEliminacion,
      motivo
    };

    // -------------------------------------------------
    // ANONIMIZAR LA CUENTA
    // -------------------------------------------------

    usuario.nombre = 'Usuario';
    usuario.apellido = 'eliminado';

    usuario.correo =
      `eliminado-${usuario._id.toString()}@anonimo.invalid`;

    const contraseñaAleatoria = crypto
      .randomBytes(32)
      .toString('hex');

    usuario.password = await bcrypt.hash(
      contraseñaAleatoria,
      10
    );

    usuario.telefono = '';
    usuario.ciudad = '';
    usuario.fotoPerfil = '';

    usuario.avatar = {
      usar: false
    };

    usuario.activo = false;
    usuario.eliminadoAt = fechaEliminacion;
    usuario.correoVerificado = false;

    usuario.codigoVerificacion = null;
    usuario.codigoVerificacionExpiracion = null;
    usuario.codigoRecuperacion = null;
    usuario.codigoRecuperacionExpiracion = null;
    usuario.tokenRecuperacion = null;
    usuario.tokenRecuperacionExpiracion = null;

    // -------------------------------------------------
    // GUARDAR LOS CAMBIOS
    // -------------------------------------------------

    await usuario.save();

    return res.status(200).json({
      mensaje: 'Usuario eliminado y anonimizado correctamente',
      usuario: {
        _id: usuario._id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        correo: usuario.correo,
        activo: usuario.activo,
        eliminadoAt: usuario.eliminadoAt,
        eliminacion: usuario.eliminacion
      }
    });
  } catch (error) {
    console.error('Error al eliminar usuario:', error);

    return res.status(500).json({
      mensaje: 'Error al eliminar usuario'
    });
  }
};

// =====================================================
// EXPORTACIONES
// =====================================================

module.exports = {
  obtenerUsuarios,
  obtenerUsuario,
  desactivarUsuario,
  activarUsuario,
  eliminarUsuario
};