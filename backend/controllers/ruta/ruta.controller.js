const https = require('https');

const OSRM_BASE_URL =
  'https://router.project-osrm.org';

const MAX_PUNTOS = 20;
const TIMEOUT_MS = 60000;

const calcularRuta = async (req, res) => {
  try {
    const { puntos } = req.body;

    if (!Array.isArray(puntos)) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'El campo puntos debe ser un arreglo.',
      });
    }

    if (puntos.length < 2) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'Se necesitan mínimo 2 puntos para calcular una ruta.',
      });
    }

    if (puntos.length > MAX_PUNTOS) {
      return res.status(400).json({
        ok: false,
        mensaje:
          `La ruta no puede contener mas de ${MAX_PUNTOS} puntos.`,
      });
    }

    const puntosValidos = puntos.map(
      (punto, index) => {
        const latitud = Number(
          punto?.latitud
        );

        const longitud = Number(
          punto?.longitud
        );

        if (
          !Number.isFinite(latitud) ||
          !Number.isFinite(longitud)
        ) {
          throw new Error(
            `Coordenadas invalidas en el punto ${index + 1}.`
          );
        }

        if (
          latitud < -90 ||
          latitud > 90
        ) {
          throw new Error(
            `Latitud invalida en el punto ${index + 1}.`
          );
        }

        if (
          longitud < -180 ||
          longitud > 180
        ) {
          throw new Error(
            `Longitud invalida en el punto ${index + 1}.`
          );
        }

        return {
          latitud,
          longitud,
        };
      }
    );

    const coordenadas =
      puntosValidos
        .map(
          (punto) =>
            `${punto.longitud},${punto.latitud}`
        )
        .join(';');

    const url =
      `${OSRM_BASE_URL}/route/v1/driving/` +
      `${coordenadas}` +
      '?overview=full' +
      '&geometries=geojson' +
      '&steps=true';

    console.log(
      '============================================'
    );

    console.log(
      'CALCULANDO RUTA POR CARRETERA'
    );

    console.log(
      'PUNTOS:',
      puntosValidos.length
    );

    console.log(
      '============================================'
    );

    const datosOSRM =
      await consultarOSRM(url);

    if (
      !datosOSRM ||
      datosOSRM.code !== 'Ok'
    ) {
      return res.status(502).json({
        ok: false,
        mensaje:
          'OSRM no pudo calcular la ruta.',
        detalle:
          datosOSRM?.message ??
          datosOSRM?.code ??
          'Respuesta desconocida.',
      });
    }

    if (
      !Array.isArray(datosOSRM.routes) ||
      datosOSRM.routes.length === 0
    ) {
      return res.status(502).json({
        ok: false,
        mensaje:
          'OSRM no encontró una ruta entre los puntos.',
      });
    }

    const ruta =
      datosOSRM.routes[0];

    if (
      !ruta.geometry ||
      !Array.isArray(
        ruta.geometry.coordinates
      ) ||
      ruta.geometry.coordinates.length < 2
    ) {
      return res.status(502).json({
        ok: false,
        mensaje:
          'La ruta no contiene una geometría valida.',
      });
    }

    return res.status(200).json({
      ok: true,
      mensaje:
        'Ruta calculada correctamente.',
      ruta: {
        distancia:
          Number(ruta.distance) || 0,

        duracion:
          Number(ruta.duration) || 0,

        geometria:
          ruta.geometry,

        waypoints:
          Array.isArray(
            datosOSRM.waypoints
          )
            ? datosOSRM.waypoints.map(
                (waypoint) => ({
                  nombre:
                    waypoint.name ?? '',
                  ubicacion:
                    waypoint.location ?? [],
                })
              )
            : [],

        pasos:
          Array.isArray(ruta.legs)
            ? ruta.legs.flatMap(
                (leg) =>
                  Array.isArray(
                    leg.steps
                  )
                    ? leg.steps.map(
                        (step) => ({
                          distancia:
                            Number(
                              step.distance
                            ) || 0,
                          duracion:
                            Number(
                              step.duration
                            ) || 0,
                          nombre:
                            step.name ?? '',
                          modo:
                            step.mode ?? '',
                          maniobra:
                            step.maneuver ??
                            null,
                        })
                      )
                    : []
              )
            : [],
      },
    });
  } catch (error) {
    console.error(
      'ERROR CALCULANDO RUTA:',
      error
    );

    return res.status(500).json({
      ok: false,
      mensaje:
        'Error interno al calcular la ruta.',
      error:
        error.message,
    });
  }
};

function consultarOSRM(url) {
  return new Promise(
    (resolve, reject) => {
      const request =
        https.get(
          url,
          {
            headers: {
              'User-Agent':
                'Mi-Ruta-Magica-del-Cafe/1.0',
            },
          },
          (response) => {
            let data = '';

            response.on(
              'data',
              (chunk) => {
                data += chunk;
              }
            );

            response.on(
              'end',
              () => {
                if (
                  response.statusCode < 200 ||
                  response.statusCode >= 300
                ) {
                  reject(
                    new Error(
                      `OSRM respondió HTTP ${response.statusCode}`
                    )
                  );
                  return;
                }

                try {
                  resolve(
                    JSON.parse(data)
                  );
                } catch (error) {
                  reject(
                    new Error(
                      'OSRM devolvió una respuesta JSON inválida.'
                    )
                  );
                }
              }
            );
          }
        );

      request.setTimeout(
        TIMEOUT_MS,
        () => {
          request.destroy();

          reject(
            new Error(
              'Tiempo de espera agotado consultando OSRM.'
            )
          );
        }
      );

      request.on(
        'error',
        reject
      );
    }
  );
}

module.exports = {
  calcularRuta,
};