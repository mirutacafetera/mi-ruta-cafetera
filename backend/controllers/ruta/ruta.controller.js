const https = require('https');

// Tiempo máximo de espera de OSRM. Debe ser menor que el tiempo de
// espera de la aplicación Flutter (30 s) para que el usuario reciba
// un mensaje claro del servidor y no un corte de conexión.
const TIEMPO_MAXIMO_OSRM_MS = 20000;

// ============================================================
// CALCULAR RUTA REAL POR CARRETERA
// ============================================================
//
// Este controlador recibe mínimo 2 coordenadas y consulta
// OSRM para obtener una ruta real utilizando la red vial.
//
// Flutter NO dibuja una línea directa.
//
// OSRM devuelve la geometría real de las carreteras y Flutter
// dibuja esa geometría mediante Polyline.
//
// Las rutas pueden ser:
// - Gigante -> Zuluaga -> Garzón
// - Gigante -> Garzón
// - Cualquier combinación de sitios turísticos
// - Rutas creadas por categorías
// - Ubicación del usuario -> sitios
//
// Cuerpo de la solicitud:
//
//   { "puntos": [ { "latitud": 2.19, "longitud": -75.62 }, ... ] }
//
// Respuesta:
//
//   { ok, mensaje, ruta: { distancia, duracion, geometria,
//                          tramos, waypoints, pasos } }
// ============================================================
const calcularRuta = async (req, res) => {
  try {
    const { puntos } = req.body || {};

    // ========================================================
    // VALIDAR PUNTOS
    // ========================================================
    if (!Array.isArray(puntos)) {
      return res.status(400).json({
        ok: false,
        mensaje: 'El campo puntos debe ser un arreglo.'
      });
    }

    // ========================================================
    // MÍNIMO 2 PUNTOS
    // ========================================================
    if (puntos.length < 2) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'Se necesitan mínimo 2 puntos para calcular una ruta.'
      });
    }

    // ========================================================
    // MÁXIMO RAZONABLE
    // ========================================================
    //
    // Permitimos hasta 10 puntos.
    // ========================================================
    if (puntos.length > 10) {
      return res.status(400).json({
        ok: false,
        mensaje: 'La ruta no puede contener más de 10 puntos.'
      });
    }

    // ========================================================
    // VALIDAR COORDENADAS
    // ========================================================
    //
    // Una coordenada inválida es un error del cliente (400),
    // no un error interno del servidor (500).
    // ========================================================
    const puntosValidos = [];

    for (let index = 0; index < puntos.length; index++) {
      const punto = puntos[index];

      if (punto === null || typeof punto !== 'object') {
        return res.status(400).json({
          ok: false,
          mensaje: `Coordenadas inválidas en el punto ${index + 1}.`
        });
      }

      const latitud = Number(punto.latitud);
      const longitud = Number(punto.longitud);

      if (
        punto.latitud === null ||
        punto.longitud === null ||
        punto.latitud === '' ||
        punto.longitud === '' ||
        !Number.isFinite(latitud) ||
        !Number.isFinite(longitud)
      ) {
        return res.status(400).json({
          ok: false,
          mensaje: `Coordenadas inválidas en el punto ${index + 1}.`
        });
      }

      if (latitud < -90 || latitud > 90) {
        return res.status(400).json({
          ok: false,
          mensaje: `Latitud inválida en el punto ${index + 1}.`
        });
      }

      if (longitud < -180 || longitud > 180) {
        return res.status(400).json({
          ok: false,
          mensaje: `Longitud inválida en el punto ${index + 1}.`
        });
      }

      puntosValidos.push({
        latitud,
        longitud
      });
    }

    // ========================================================
    // CONSTRUIR COORDENADAS PARA OSRM
    // ========================================================
    //
    // IMPORTANTE:
    //
    // OSRM utiliza:
    //
    // longitud,latitud
    //
    // NO:
    //
    // latitud,longitud
    // ========================================================
    const coordenadas = puntosValidos
      .map(punto => `${punto.longitud},${punto.latitud}`)
      .join(';');

    // ========================================================
    // URL OSRM
    // ========================================================
    //
    // driving:
    // rutas para vehículos.
    //
    // overview=full:
    // devuelve toda la geometría.
    //
    // geometries=geojson:
    // devuelve coordenadas GeoJSON.
    //
    // steps=true:
    // devuelve pasos de navegación.
    // ========================================================
    const url =
      'https://router.project-osrm.org/route/v1/driving/' +
      coordenadas +
      '?overview=full&geometries=geojson&steps=true';

    console.log('============================================');
    console.log('🛣️ CALCULANDO RUTA POR CARRETERA');
    console.log('PUNTOS:', puntosValidos.length);
    console.log('COORDENADAS:', coordenadas);
    console.log('============================================');

    // ========================================================
    // CONSULTAR OSRM
    // ========================================================
    const datosOSRM = await consultarOSRM(url);

    // ========================================================
    // VALIDAR RESPUESTA OSRM
    // ========================================================
    if (!datosOSRM || datosOSRM.code !== 'Ok') {
      console.error('Respuesta OSRM:', datosOSRM);

      return res.status(502).json({
        ok: false,
        mensaje:
          'El servicio de rutas no pudo calcular el recorrido.',
        detalle:
          datosOSRM?.message ??
          datosOSRM?.code ??
          'Respuesta desconocida de OSRM.'
      });
    }

    // ========================================================
    // VALIDAR RUTAS
    // ========================================================
    if (
      !Array.isArray(datosOSRM.routes) ||
      datosOSRM.routes.length === 0
    ) {
      return res.status(502).json({
        ok: false,
        mensaje:
          'OSRM no encontró una ruta entre los puntos seleccionados.'
      });
    }

    // ========================================================
    // TOMAR PRIMERA RUTA
    // ========================================================
    const ruta = datosOSRM.routes[0];

    // ========================================================
    // VALIDAR GEOMETRÍA
    // ========================================================
    if (
      !ruta.geometry ||
      !Array.isArray(ruta.geometry.coordinates) ||
      ruta.geometry.coordinates.length < 2
    ) {
      return res.status(502).json({
        ok: false,
        mensaje: 'La ruta no contiene una geometría válida.'
      });
    }

    // ========================================================
    // CONSTRUIR PASOS DE NAVEGACIÓN
    // ========================================================
    const pasos =
      ruta.legs?.flatMap(
        leg =>
          leg.steps?.map(step => {
            return {
              distancia: Number(step.distance ?? 0),
              duracion: Number(step.duration ?? 0),
              nombre: step.name ?? '',
              modo: step.mode ?? '',
              maniobra: step.maneuver ?? null
            };
          }) ?? []
      ) ?? [];

    // ========================================================
    // TRAMOS (UNO POR CADA LEG DE OSRM)
    // ========================================================
    //
    // Un tramo por cada par de puntos consecutivos de la
    // solicitud (metros y segundos), en el mismo orden.
    // ========================================================
    const tramos = Array.isArray(ruta.legs)
      ? ruta.legs.map(leg => ({
          distancia: Number(leg.distance ?? 0),
          duracion: Number(leg.duration ?? 0)
        }))
      : [];

    // ========================================================
    // WAYPOINTS
    // ========================================================
    const waypoints =
      datosOSRM.waypoints?.map(waypoint => {
        return {
          nombre: waypoint.name ?? '',
          ubicacion: waypoint.location ?? []
        };
      }) ?? [];

    // ========================================================
    // RESPUESTA PARA FLUTTER
    // ========================================================
    return res.status(200).json({
      ok: true,
      mensaje: 'Ruta calculada correctamente.',
      ruta: {
        // Metros.
        distancia: Number(ruta.distance ?? 0),

        // Segundos.
        duracion: Number(ruta.duration ?? 0),

        // Geometría real: sigue la red vial, NO es una línea
        // recta entre sitios. Es la línea que Flutter dibuja.
        geometria: ruta.geometry,

        // Un tramo por cada par de puntos consecutivos.
        tramos,

        waypoints,

        pasos
      }
    });
  } catch (error) {
    console.error('============================================');
    console.error('❌ ERROR CALCULANDO RUTA');
    console.error(error);
    console.error('============================================');

    if (error && error.codigo === 'OSRM_TIMEOUT') {
      return res.status(504).json({
        ok: false,
        mensaje: 'El servicio de rutas tardó demasiado en responder.'
      });
    }

    if (error && error.codigo === 'OSRM_NO_DISPONIBLE') {
      return res.status(502).json({
        ok: false,
        mensaje:
          'No fue posible comunicarse con el servicio de rutas.'
      });
    }

    return res.status(500).json({
      ok: false,
      mensaje: 'Error interno al calcular la ruta.',
      error: error.message
    });
  }
};

// ============================================================
// CONSULTAR OSRM
// ============================================================
function consultarOSRM(url) {
  return new Promise((resolve, reject) => {
    const request = https.get(
      url,
      {
        headers: {
          'User-Agent': 'Mi-Ruta-Cafetera/1.0'
        }
      },
      response => {
        let data = '';

        response.on('data', chunk => {
          data += chunk;
        });

        response.on('end', () => {
          if (
            response.statusCode < 200 ||
            response.statusCode >= 300
          ) {
            const error = new Error(
              `OSRM respondió HTTP ${response.statusCode}`
            );

            error.codigo = 'OSRM_NO_DISPONIBLE';

            return reject(error);
          }

          try {
            resolve(JSON.parse(data));
          } catch (error) {
            const errorJson = new Error(
              'OSRM devolvió una respuesta que no es JSON válida.'
            );

            errorJson.codigo = 'OSRM_NO_DISPONIBLE';

            reject(errorJson);
          }
        });
      }
    );

    // ========================================================
    // TIMEOUT
    // ========================================================
    request.setTimeout(TIEMPO_MAXIMO_OSRM_MS, () => {
      const error = new Error(
        'Tiempo de espera agotado al consultar OSRM.'
      );

      error.codigo = 'OSRM_TIMEOUT';

      request.destroy();

      reject(error);
    });

    // ========================================================
    // ERROR DE CONEXIÓN
    // ========================================================
    request.on('error', error => {
      if (!error.codigo) {
        error.codigo = 'OSRM_NO_DISPONIBLE';
      }

      reject(error);
    });
  });
}

// ============================================================
// EXPORTAR
// ============================================================
module.exports = {
  calcularRuta
};
