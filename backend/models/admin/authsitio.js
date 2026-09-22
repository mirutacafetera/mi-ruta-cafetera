const mongoose = require('mongoose');

const authAdminSchema = new mongoose.Schema(
  {
    nombre: {
      type: String,
      required: true,
      trim: true
    },

    apellido: {
      type: String,
      required: true,
      trim: true
    },

    correo: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },

    password: {
      type: String,
      required: true,
      select: false
    },

    telefono: {
      type: String,
      default: '',
      trim: true
    },

    rol: {
      type: String,
      default: 'admin',
      enum: ['admin']
    },

    activo: {
      type: Boolean,
      default: true
    },

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

const AuthAdmin =
  mongoose.models.AuthAdmin ||
  mongoose.model(
    'AuthAdmin',
    authAdminSchema
  );

module.exports = AuthAdmin;