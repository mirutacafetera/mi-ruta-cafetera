const mongoose = require('mongoose');

// =====================================================
// OPCIONES DEL AVATAR CAFETERO
// =====================================================
//
// El avatar se guarda como una configuración pequeña de
// identificadores (no como imagen). La app los dibuja con
// widgets. Estas listas son la fuente de validación del
// backend; deben coincidir con avatar_cafetero_model.dart.
// =====================================================

const AVATAR_OPCIONES = {
  piel: ['clara', 'trigo', 'canela', 'morena', 'oscura'],
  peinado: ['corto', 'ondulado', 'trenza', 'cola', 'rizado', 'calvo'],
  colorPelo: ['negro', 'castano', 'cafe', 'rubio', 'gris'],
  ropa: ['verde', 'cafe', 'crema', 'naranja'],
  sombrero: ['ninguno', 'aguadeno', 'paja', 'gorra'],
  accesorio: ['ninguno', 'canasto', 'taza', 'gafas', 'mochila'],
  fondo: ['montanas', 'cafetal', 'amanecer', 'tatacoa']
};

const usuarioSchema = new mongoose.Schema(
  {
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

    ciudad: {
      type: String,
      trim: true
    },

    fotoPerfil: {
      type: String,
      default: ''
    },

    // ==================================================
    // AVATAR CAFETERO
    // ==================================================
    //
    // `usar` indica si la app debe mostrar el avatar en
    // lugar de la fotografía (por ejemplo, la de Google).
    // La fotografía en `fotoPerfil` nunca se reemplaza.
    // ==================================================

    avatar: {
      usar: {
        type: Boolean,
        default: false
      },
      piel: { type: String, enum: AVATAR_OPCIONES.piel },
      peinado: { type: String, enum: AVATAR_OPCIONES.peinado },
      colorPelo: { type: String, enum: AVATAR_OPCIONES.colorPelo },
      ropa: { type: String, enum: AVATAR_OPCIONES.ropa },
      sombrero: { type: String, enum: AVATAR_OPCIONES.sombrero },
      accesorio: { type: String, enum: AVATAR_OPCIONES.accesorio },
      fondo: { type: String, enum: AVATAR_OPCIONES.fondo }
    },
    
    activo: {
      type: Boolean,
      default: true
    },

    // ==================================================
    // ANONIMIZACIÓN DE CUENTA
    // ==================================================
    //
    // Fecha en que el usuario eliminó su cuenta. Los datos
    // personales ya fueron anonimizados; el documento se
    // conserva para no romper reseñas y reservas.
    // ==================================================

    eliminadoAt: {
      type: Date,
      default: null
    },


    // ==================================================
    // VERIFICACIÓN DE CORREO
    // ==================================================

    correoVerificado: {
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
    timestamps: true
  }
);

const Usuario = mongoose.model(
  'Usuario',
  usuarioSchema
);

Usuario.AVATAR_OPCIONES = AVATAR_OPCIONES;

module.exports = Usuario;