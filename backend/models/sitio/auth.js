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

    // Identificador estable ("sub") de la cuenta de Google vinculada.
    // Es opcional: solo existe si la cuenta inició sesión con Google.
    // El índice único y disperso impide que dos cuentas compartan la
    // misma identidad de Google sin afectar a las cuentas sin vincular.
    googleId: {
      type: String,
      unique: true,
      sparse: true,
      trim: true
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

const CuentaSitio =
  mongoose.models.authSitio ||
  mongoose.model('authSitio', authSitioSchema);

module.exports = CuentaSitio;
