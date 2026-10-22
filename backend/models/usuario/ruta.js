const mongoose = require('mongoose');

// ============================================================
// PARADA DE UNA RUTA PREDEFINIDA (itinerario)
// ============================================================
// Es opcional: las rutas personalizadas existentes solo usan
// sitios[]. En las rutas con paradas, sitios[] se mantiene
// sincronizado (mismo orden) para no romper a los clientes.
//
// La distancia y el tiempo de viaje NO se guardan: se calculan
// en cada consulta con el servicio de rutas por carretera.
// duracionMin es el tiempo planificado de la ACTIVIDAD en el
// sitio, distinto del tiempo de desplazamiento.
// ============================================================
const paradaSchema = new mongoose.Schema(
  {
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },
    orden: {
      type: Number,
      required: true,
      min: 1
    },
    tipoActividad: {
      type: String,
      trim: true,
      default: 'visita'
    },
    descripcion: {
      type: String,
      trim: true,
      default: ''
    },
    duracionMin: {
      type: Number,
      min: 5,
      max: 480,
      default: null
    },
    horaLlegada: {
      type: String,
      match: /^([01]\d|2[0-3]):[0-5]\d$/,
      default: null
    },
    horaSalida: {
      type: String,
      match: /^([01]\d|2[0-3]):[0-5]\d$/,
      default: null
    },
    indicaciones: {
      type: String,
      trim: true,
      default: ''
    },
    requiereReserva: {
      type: Boolean,
      default: false
    },
    actividad: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Actividad',
      default: null
    }
  },
  { _id: false }
);

const rutaSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      default: null
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

      sitios: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'SitioTuristico'
      }
    ],
    paradas: {
      type: [paradaSchema],
      default: undefined
    },
    tipoExperiencia: {
      type: String,
      trim: true,
      default: ''
    },
    duracionPlanificadaMin: {
      type: Number,
      min: 0,
      default: null
    },
    tipo: {
      type: String,
      enum: ['personalizada', 'predefinida'],
      default: 'personalizada'
    },

    activa: {
      type: Boolean,
      default: true
    },

    expiraEn: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

// ============================================================
// TTL
// ============================================================
// MongoDB eliminará automáticamente los documentos cuando
// llegue la fecha almacenada en expiraEn.
//
// Las rutas predefinidas tienen expiraEn = null,
// por lo tanto nunca son eliminadas por este índice.
// ============================================================

rutaSchema.index(
  { expiraEn: 1 },
  {
    expireAfterSeconds: 0
  }
);

module.exports = mongoose.model('Ruta', rutaSchema);

