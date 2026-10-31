const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'mi-ruta-cafetera/resenas',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp', 'avif'],
    resource_type: 'image'
  }
});

const uploadResenas = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB
    files: 10
  },
  fileFilter: (req, file, callback) => {
    // Permitir si mimetype es de imagen o si viene como binario genérico de la web
    const mimetypesValidos = [
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/avif',
      'application/octet-stream'
    ];

    if (!file.mimetype || mimetypesValidos.includes(file.mimetype)) {
      return callback(null, true);
    }

    callback(
      new Error('Solo se permiten archivos de imagen válidos (JPG, PNG, WEBP, AVIF).')
    );
  }
});

module.exports = uploadResenas;