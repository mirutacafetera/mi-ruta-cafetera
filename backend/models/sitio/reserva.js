const mongoose = require('mongoose');

const reservaSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },

    actividad: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Actividad',
      required: true
    },

    fecha: {
      type: Date,
      required: true
    },

    cantidadPersonas: {
      type: Number,
      required: true,
      min: 1
    },

    precioTotal: {
      type: Number,
      required: true,
      min: 0
    },

    estado: {
      type: String,
      enum: [
        'pendiente',
        'confirmada',
        'cancelada',
        'completada'
      ],
      default: 'pendiente'
    },

    observaciones: {
      type: String,
      default: '',
      trim: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Reserva', reservaSchema);