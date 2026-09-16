const mongoose = require('mongoose');

const authSitioSchema = new mongoose.Schema(
  {
    // ==================================================
    // SITIO TURÍSTICO ASOCIADO
    // ==================================================

    sitioId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true,
      unique: true
    },


    // ==================================================
    // DATOS DEL RESPONSABLE
    // ==================================================

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


    // ==================================================
    // DATOS DE ACCESO
    // ==================================================

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


    // ==================================================
    // INFORMACIÓN DE CONTACTO
    // ==================================================

    telefono: {
      type: String,
      default: '',
      trim: true
    },


    // ==================================================
    // ROL
    // ==================================================

    rol: {
      type: String,
      default: 'sitio',
      enum: ['sitio']
    },


    // ==================================================
    // ESTADO DE LA CUENTA
    // ==================================================

    activo: {
      type: Boolean,
      default: true
    },


    // ==================================================
    // RECUPERACIÓN DE CONTRASEÑA
    // ==================================================

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


// ======================================================
// MODELO
// ======================================================

const AuthSitio =
  mongoose.models.AuthSitio ||
  mongoose.model(
    'AuthSitio',
    authSitioSchema
  );


module.exports = AuthSitio;