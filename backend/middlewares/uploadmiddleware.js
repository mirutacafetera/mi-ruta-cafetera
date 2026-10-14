const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');

// ============================================================
// CARGA DE IMÁGENES: SE CONSERVA LA CONFIGURACIÓN ACTUAL
// ============================================================

const storageImagenes = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'mi-ruta-cafetera/sitios',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
    transformation: [
      { width: 1200, height: 1200, crop: 'limit' },
    ],
  },
});

const TIPOS_IMAGEN = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
];

const EXTENSIONES_IMAGEN = ['jpg', 'jpeg', 'png', 'webp'];

const filtroImagenes = (req, file, cb) => {
  const tipo = (file.mimetype || '').toLowerCase();
  const nombre = (file.originalname || '').toLowerCase();
  const extension = nombre.includes('.')
    ? nombre.split('.').pop()
    : '';

  if (TIPOS_IMAGEN.includes(tipo)) {
    return cb(null, true);
  }

  if (
    tipo === 'application/octet-stream' &&
    EXTENSIONES_IMAGEN.includes(extension)
  ) {
    return cb(null, true);
  }

  return cb(
    new Error('Formato no permitido. Usa JPG, PNG o WEBP.'),
  );
};

const upload = multer({
  storage: storageImagenes,
  fileFilter: filtroImagenes,
  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 10,
  },
});

// ============================================================
// CARGA DE AUDIOGUÍAS
// Cloudinary almacena audio mediante resource_type: video.
// ============================================================

const storageAudios = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'mi-ruta-cafetera/sitios/audioguias',
    resource_type: 'video',
    allowed_formats: [
      'mp3',
      'wav',
      'm4a',
      'aac',
      'ogg',
      'oga',
      'opus',
      'webm',
    ],
  },
});

const TIPOS_AUDIO = [
  'audio/mpeg',
  'audio/mp3',
  'audio/wav',
  'audio/x-wav',
  'audio/wave',
  'audio/mp4',
  'audio/x-m4a',
  'audio/aac',
  'audio/ogg',
  'audio/opus',
  'audio/webm',
];

const EXTENSIONES_AUDIO = [
  'mp3',
  'wav',
  'm4a',
  'aac',
  'ogg',
  'oga',
  'opus',
  'webm',
];

const filtroAudios = (req, file, cb) => {
  const tipo = (file.mimetype || '').toLowerCase();
  const nombre = (file.originalname || '').toLowerCase();
  const extension = nombre.includes('.')
    ? nombre.split('.').pop()
    : '';

  if (
    TIPOS_AUDIO.includes(tipo) &&
    EXTENSIONES_AUDIO.includes(extension)
  ) {
    return cb(null, true);
  }

  // Flutter Web puede enviar octet-stream.
  if (
    tipo === 'application/octet-stream' &&
    EXTENSIONES_AUDIO.includes(extension)
  ) {
    return cb(null, true);
  }

  return cb(
    new Error(
      'Formato de audio no permitido. Usa MP3, WAV, M4A, AAC, OGG o WebM.',
    ),
  );
};

const uploadAudio = multer({
  storage: storageAudios,
  fileFilter: filtroAudios,
  limits: {
    fileSize: 25 * 1024 * 1024,
    files: 1,
  },
});

module.exports = {
  upload,
  uploadAudio,
};
