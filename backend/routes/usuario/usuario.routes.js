const express = require('express');

const router = express.Router();

const {
  crearLimitador
} = require(
  '../../middlewares/ratelimitmiddleware'
);

// Edición del perfil: 30 solicitudes cada 10 minutos.
const limitarEdicion = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 30,
  mensaje:
    'Has hecho muchos cambios seguidos. Intenta de nuevo en unos minutos.'
});

// Eliminación de cuenta: 5 intentos cada 10 minutos
// (protege la comprobación de contraseña).
const limitarEliminacion = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 5,
  mensaje:
    'Demasiados intentos. Intenta de nuevo en unos minutos.'
});

// Recuperación de contraseña. Se limita por IP y por correo para
// frenar el envío masivo de códigos y la adivinanza del código de
// 6 dígitos. Los límites aplican exista o no el correo.
const claveCorreo = (req) =>
  `correo:${String(req.body?.correo ?? '').trim().toLowerCase().slice(0, 254)}`;

const limitarSolicitudIp = crearLimitador({
  ventanaMs: 15 * 60 * 1000,
  maximo: 10,
  mensaje:
    'Demasiadas solicitudes de recuperación. Intenta de nuevo en unos minutos.',
  clave: (req) => `recuperar-ip:${req.ip}`
});

const limitarSolicitudCorreo = crearLimitador({
  ventanaMs: 15 * 60 * 1000,
  maximo: 3,
  mensaje:
    'Ya solicitaste varios códigos. Espera unos minutos antes de pedir otro.',
  clave: (req) => `recuperar-${claveCorreo(req)}`
});

const limitarVerificacionIp = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 20,
  mensaje:
    'Demasiados intentos. Intenta de nuevo en unos minutos.',
  clave: (req) => `verificar-ip:${req.ip}`
});

const limitarVerificacionCorreo = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 5,
  mensaje:
    'Demasiados intentos con este código. Solicita uno nuevo e inténtalo más tarde.',
  clave: (req) => `verificar-${claveCorreo(req)}`
});

const limitarRestablecer = crearLimitador({
  ventanaMs: 10 * 60 * 1000,
  maximo: 10,
  mensaje:
    'Demasiados intentos. Intenta de nuevo en unos minutos.',
  clave: (req) => `restablecer-ip:${req.ip}`
});

const {
  loginWithGoogle
} = require(
  '../../controllers/usuario/google.controller'
);

const {
  verificarToken
} = require(
  '../../middlewares/authmiddleware'
);

const {
  registrarUsuario,
  verificarCorreo,
  iniciarSesionUsuario,
  obtenerMiPerfil,
  actualizarUsuario,
  eliminarUsuario
} = require(
  '../../controllers/usuario/usuario.controller'
);

// Recuperación de contraseña (controlador propio; las funciones
// anteriores de usuario.controller.js ya no se enlazan a rutas).
const {
  recuperarPassword,
  verificarCodigoRecuperacion,
  restablecerPassword
} = require(
  '../../controllers/usuario/recuperacion.controller'
);

// ======================================================
// AUTENTICACIÓN DE USUARIOS
// ======================================================

// Registrar usuario
router.post(
  '/registrar',
  registrarUsuario
);

// Verificar correo
router.post(
  '/verificar-correo',
  verificarCorreo
);

// Iniciar sesión
router.post(
  '/login',
  iniciarSesionUsuario
);

// Iniciar sesión con Google
router.post(
  '/login-google',
  loginWithGoogle
);

// Recuperar contraseña
router.post(
  '/recuperar-password',
  limitarSolicitudIp,
  limitarSolicitudCorreo,
  recuperarPassword
);

// Verificar código de recuperación
router.post(
  '/verificar-codigo-recuperacion',
  limitarVerificacionIp,
  limitarVerificacionCorreo,
  verificarCodigoRecuperacion
);

// Restablecer contraseña
router.post(
  '/restablecer-password',
  limitarRestablecer,
  restablecerPassword
);

// ======================================================
// USUARIO
// ======================================================

// Obtener mi perfil
router.get(
  '/perfil',
  verificarToken,
  obtenerMiPerfil
);

// Actualizar mi perfil (nombre, apellido, teléfono, ciudad, foto y avatar)
router.put(
  '/:id',
  verificarToken,
  limitarEdicion,
  actualizarUsuario
);

// Eliminar cuenta (anonimiza; exige confirmación e identidad)
router.delete(
  '/:id',
  verificarToken,
  limitarEliminacion,
  eliminarUsuario
);

module.exports = router;

