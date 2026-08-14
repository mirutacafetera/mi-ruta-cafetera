const mongoose = require('mongoose');

const actividadSchema = new mongoose.Schema(
  {
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },

    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      default: '',
      trim: true
    },

    precio: {
      type: Number,
      default: 0
    },

    horario: {
      type: String,
      default: '',
      trim: true
    },

    duracion: {
      type: String,
      default: '',
      trim: true
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

module.exports = mongoose.model('Actividad', actividadSchema);