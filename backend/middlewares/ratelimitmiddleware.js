// =====================================================
// LIMITADOR DE PETICIONES (EN MEMORIA)
// =====================================================
//
// Limita cuántas peticiones puede hacer cada usuario
// autenticado en una ventana de tiempo. No requiere
// paquetes adicionales.
//
// Nota: el contador vive en la memoria del proceso. Es
// suficiente para una sola instancia del servidor; si el
// backend se ejecuta en varias instancias, cada una
// llevaría su propio contador.
// =====================================================

const crearLimitador = ({
  ventanaMs = 10 * 60 * 1000,
  maximo = 10,
  mensaje = 'Has hecho demasiadas solicitudes. Intenta de nuevo en unos minutos.'
} = {}) => {
  const registros = new Map();

  // Limpieza periódica para que el mapa no crezca sin límite.
  const limpieza = setInterval(() => {
    const ahora = Date.now();

    for (const [clave, marcas] of registros) {
      const vigentes = marcas.filter(
        (marca) => ahora - marca < ventanaMs
      );

      if (vigentes.length === 0) {
        registros.delete(clave);
      } else {
        registros.set(clave, vigentes);
      }
    }
  }, ventanaMs);

  // No impide que el proceso termine.
  if (typeof limpieza.unref === 'function') {
    limpieza.unref();
  }

  return (req, res, next) => {
    const clave =
      req.usuario?.id || req.ip || 'anonimo';

    const ahora = Date.now();

    const marcas = (registros.get(clave) || []).filter(
      (marca) => ahora - marca < ventanaMs
    );

    if (marcas.length >= maximo) {
      const esperaSegundos = Math.ceil(
        (ventanaMs - (ahora - marcas[0])) / 1000
      );

      res.set('Retry-After', String(esperaSegundos));

      return res.status(429).json({
        mensaje,
        reintentarEnSegundos: esperaSegundos
      });
    }

    marcas.push(ahora);
    registros.set(clave, marcas);

    next();
  };
};

module.exports = {
  crearLimitador
};