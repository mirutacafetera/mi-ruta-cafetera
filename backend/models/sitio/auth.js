
const mongoose = require('mongoose');

const authSitioSchema = new mongoose.Schema(
  {
    // Sitio turístico al que pertenece la cuenta
    sitioId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true,
      unique: true
    },

    nombre: {
      type: String,
      required: true,
      trim: true,
      minlength: 2
    },

    apellido: {
      type: String,
      required: true,
      trim: true,
      minlength: 2
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
      trim: true,
      default: ''
    },

    // Identificador de Google
    googleId: {
      type: String,
      unique: true,
      sparse: true,
      trim: true
    },

    // Estado de la cuenta
    activo: {
      type: Boolean,
      default: true
    },

    // VERIFICACIÓN DEL CORREO
    correoVerificado: {
      type: Boolean,
      default: false
    },

    codigoVerificacionCorreo: {
      type: String,
      default: null,
      select: false
    },

    codigoVerificacionExpiracion: {
      type: Date,
      default: null,
      select: false
    },

    // RECUPERACIÓN DE CONTRASEÑA
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

const CuentaSitio =
  mongoose.models.authSitio ||
  mongoose.model('authSitio', authSitioSchema);

module.exports = CuentaSitio;
