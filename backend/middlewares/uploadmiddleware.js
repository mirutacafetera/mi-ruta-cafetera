const multer = require('multer');

const { CloudinaryStorage } = require('multer-storage-cloudinary');

const cloudinary = require('../config/cloudinary');

const storage = new CloudinaryStorage({
  cloudinary,

  params: {
    folder: 'mi-ruta-cafetera/sitios',

    allowed_formats: [
      'jpg',
      'jpeg',
      'png',
      'webp',
    ],

    transformation: [
      {
        width: 1200,
        height: 1200,
        crop: 'limit',
      },
    ],
  },
});

const filtroImagenes = (req, file, cb) => {
  const tiposPermitidos = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  if (tiposPermitidos.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        'Solo se permiten imágenes JPG, JPEG, PNG o WEBP',
      ),
      false,
    );
  }
};

const upload = multer({
  storage,
  fileFilter: filtroImagenes,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

module.exports = {
  upload,
};