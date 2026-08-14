const mongoose = require('mongoose');

const estadisticaSchema = new mongoose.Schema(
  {
    tipo: {
      type: String,
      required: true,
      trim: true
    },

    cantidad: {
      type: Number,
      default: 0
    },

    descripcion: {
      type: String,
      default: '',
      trim: true
    },

    fecha: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Estadistica', estadisticaSchema);