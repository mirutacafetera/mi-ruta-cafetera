const mongoose = require('mongoose');

const authAdminSchema = new mongoose.Schema(
  {
    // =====================================================
    // DATOS PERSONALES
    // =====================================================

    nombre: {
      type: String,
      required: [true, 'El nombre es obligatorio'],
      trim: true,
      minlength: [2, 'El nombre debe tener al menos 2 caracteres']
    },

    apellido: {
      type: String,
      required: [true, 'El apellido es obligatorio'],
      trim: true,
      minlength: [2, 'El apellido debe tener al menos 2 caracteres']
    },

    // =====================================================
    // CREDENCIALES
    // =====================================================

    correo: {
      type: String,
      required: [true, 'El correo es obligatorio'],
      unique: true,
      lowercase: true,
      trim: true
    },

    password: {
      type: String,
      required: [true, 'La contraseña es obligatoria'],
      select: false
    },

    // =====================================================
    // CONTACTO
    // =====================================================

    telefono: {
      type: String,
      trim: true,
      default: ''
    },

    // =====================================================
    // ROL
    // =====================================================

    rol: {
      type: String,
      enum: ['admin'],
      default: 'admin'
    },

    // =====================================================
    // ESTADO
    // =====================================================

    activo: {
      type: Boolean,
      default: true
    },

    // =====================================================
    // RECUPERACIÓN DE CONTRASEÑA
    // =====================================================

    codigoRecuperacion: {
      type: String,
      default: null
    },

    codigoRecuperacionExpiracion: {
      type: Date,
      default: null
    },

    tokenRecuperacion: {
      type: String,
      default: null
    },

    tokenRecuperacionExpiracion: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true,
    collection: 'authadmins'
  }
);

// =====================================================
// MODELO
// =====================================================

const AuthAdmin =
  mongoose.models.AuthAdmin ||
  mongoose.model(
    'AuthAdmin',
    authAdminSchema
  );

module.exports = AuthAdmin;