const mongoose = require('mongoose');

const categoriaSchema = new mongoose.Schema(
  {
    nombre: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },

    descripcion: {
      type: String,
      default: '',
      trim: true
    },

    estado: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true,
    collection: 'categoriasitios'
  }
);

module.exports = mongoose.model('Categoria', categoriaSchema);