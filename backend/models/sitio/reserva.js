const mongoose = require('mongoose');

// Solicitud de reserva de una actividad de un sitio turístico.
//
// Cambios respecto a la versión anterior (todos compatibles con los
// documentos que ya existen: los campos nuevos tienen valor por defecto):
//   - estado 'rechazada'.
//   - respuestaSitio / respondidaAt: respuesta del establecimiento.
//   - actividadNombre / precioUnitario: copia al momento de la solicitud.
//   - claveSolicitud: evita duplicados si se reintenta el envío.

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
        'rechazada',
        'cancelada',
        'completada'
      ],
      default: 'pendiente'
    },

    observaciones: {
      type: String,
      default: '',
      trim: true
    },

    // Copia de los datos de la actividad al momento de la solicitud.
    actividadNombre: {
      type: String,
      default: '',
      trim: true
    },

    precioUnitario: {
      type: Number,
      default: 0,
      min: 0
    },

    // Motivo del rechazo, o indicaciones del establecimiento al confirmar.
    respuestaSitio: {
      type: String,
      default: '',
      trim: true
    },

    respondidaAt: {
      type: Date,
      default: null
    },

    // Identificador opcional enviado por la app para que un reintento
    // no cree una segunda solicitud.
    claveSolicitud: {
      type: String,
      trim: true
    }
  },
  {
    timestamps: true
  }
);

reservaSchema.index({ sitio: 1, estado: 1, fecha: 1 });
reservaSchema.index({ usuario: 1, createdAt: -1 });

// Única por usuario solo cuando existe la clave (no afecta a las
// reservas anteriores, que no tienen este campo).
reservaSchema.index(
  { usuario: 1, claveSolicitud: 1 },
  {
    unique: true,
    partialFilterExpression: {
      claveSolicitud: { $type: 'string' }
    }
  }
);

module.exports =
  mongoose.models.Reserva ||
  mongoose.model('Reserva', reservaSchema);
