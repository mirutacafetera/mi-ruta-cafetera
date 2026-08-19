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
            trim: true
        },

        estado: {
            type: Boolean,
            default: true
        }
    },
    {
        timestamps: true
    }
);

module.exports = mongoose.model('CategoriaSitio', categoriaSchema);