const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');

const formatosPermitidos = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/avif'
];

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
    fileSize: 10 * 1024 * 1024,
    files: 10
  },
  fileFilter: (req, file, callback) => {
    if (!formatosPermitidos.includes(file.mimetype)) {
      return callback(
        new Error('Solo se permiten imágenes JPG, PNG, WEBP o AVIF.')
      );
    }

    callback(null, true);
  }
});

module.exports = uploadResenas;
