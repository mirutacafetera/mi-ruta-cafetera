const mongoose = require('mongoose');

const mapaOfflineSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      default: ''
    },

    archivo: {
      type: String,
      required: true
    },

    fechaDescarga: {
      type: Date,
      default: Date.now
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

module.exports = mongoose.model('MapaOffline', mapaOfflineSchema);