const mongoose = require('mongoose');


// ==========================================
// ESQUEMA DE CUENTA DEL SITIO
// ==========================================

const authSitioSchema = new mongoose.Schema(
  {

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
      trim: true
    },

    activo: {
      type: Boolean,
      default: true
    },


    // ==========================================
    // VERIFICACIÓN DE CORREO
    // ==========================================

    isVerified: {
      type: Boolean,
      default: false
    },

    codigoVerificacion: {
      type: String,
      default: null
    },

    codigoVerificacionExpiracion: {
      type: Date,
      default: null
    },


    // ==========================================
    // RECUPERACIÓN DE CONTRASEÑA
    // ==========================================

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
    timestamps: true
  }
);


// ==========================================
// MODELO
// ==========================================

// Evita registrar nuevamente el modelo
// si Mongoose ya lo tiene cargado.

const CuentaSitio =
  mongoose.models.authSitio ||
  mongoose.model(
    'authSitio',
    authSitioSchema
  );


// ==========================================
// EXPORTAR
// ==========================================

module.exports = CuentaSitio;