const mongoose = require('mongoose');

const sitioSchema = new mongoose.Schema(
  {
    // ==============================
    // DATOS DE ACCESO
    // ==============================

    correo: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true
    },

    password: {
      type: String,
      required: true
    },

    // ==============================
    // INFORMACIÓN DEL SITIO
    // ==============================

    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      required: true,
      trim: true
    },

    categoria: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Categoria',
      required: true
    },

    direccion: {
      type: String,
      default: '',
      trim: true
    },

    ciudad: {
      type: String,
      default: 'Garzón',
      trim: true
    },

    departamento: {
      type: String,
      default: 'Huila',
      trim: true
    },

    latitud: {
      type: Number,
      required: true
    },

    longitud: {
      type: Number,
      required: true
    },

    telefono: {
      type: String,
      default: '',
      trim: true
    },

    sitioWeb: {
      type: String,
      default: '',
      trim: true
    },

    imagen: {
      type: String,
      default: '',
      trim: true
    },

    imagenes: {
      type: [String],
      default: []
    },

    horario: {
      type: String,
      default: '',
      trim: true
    },

    precioDesde: {
      type: Number,
      default: 0,
      min: 0
    },

    activo: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

module.exports =
  mongoose.models.Sitio || mongoose.model('Sitio', sitioSchema);