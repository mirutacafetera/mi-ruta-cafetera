const mongoose = require('mongoose');

const authSitioSchema = new mongoose.Schema(
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
      default: 'sitio',
      enum: ['sitio']
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
    collection: 'authsitios'
  }
);

const AuthSitio =
  mongoose.models.AuthSitio ||
  mongoose.model('AuthSitio', authSitioSchema);

module.exports = AuthSitio;