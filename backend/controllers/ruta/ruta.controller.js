const https = require('https');


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
// ============================================================


const calcularRuta = async (req, res) => {

  try {

    const { puntos } = req.body;


    // ========================================================
    // VALIDAR PUNTOS
    // ========================================================

    if (!Array.isArray(puntos)) {

      return res.status(400).json({
        ok: false,
        mensaje:
          'El campo puntos debe ser un arreglo.'
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
    // Una ruta turística normal no debería tener cientos
    // de puntos.
    //
    // Permitimos hasta 20 sitios.
    // ========================================================

    if (puntos.length > 20) {

      return res.status(400).json({
        ok: false,
        mensaje:
          'La ruta no puede contener más de 20 puntos.'
      });

    }


    // ========================================================
    // VALIDAR COORDENADAS
    // ========================================================

    const puntosValidos = puntos.map(
      (punto, index) => {

        const latitud =
          Number(
            punto.latitud
          );

        const longitud =
          Number(
            punto.longitud
          );


        if (
          !Number.isFinite(latitud) ||
          !Number.isFinite(longitud)
        ) {

          throw new Error(
            `Coordenadas inválidas en el punto ${index + 1}.`
          );

        }


        // ----------------------------------------------------
        // VALIDAR LATITUD
        // ----------------------------------------------------

        if (
          latitud < -90 ||
          latitud > 90
        ) {

          throw new Error(
            `Latitud inválida en el punto ${index + 1}.`
          );

        }


        // ----------------------------------------------------
        // VALIDAR LONGITUD
        // ----------------------------------------------------

        if (
          longitud < -180 ||
          longitud > 180
        ) {

          throw new Error(
            `Longitud inválida en el punto ${index + 1}.`
          );

        }


        return {
          latitud,
          longitud
        };

      }
    );


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

    const coordenadas =
      puntosValidos
        .map(
          punto =>
            `${punto.longitud},${punto.latitud}`
        )
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


    console.log(
      '============================================'
    );

    console.log(
      '🛣️ CALCULANDO RUTA POR CARRETERA'
    );

    console.log(
      'PUNTOS:',
      puntosValidos.length
    );

    console.log(
      'COORDENADAS:',
      coordenadas
    );

    console.log(
      '============================================'
    );


    // ========================================================
    // CONSULTAR OSRM
    // ========================================================

    const datosOSRM =
      await consultarOSRM(url);


    // ========================================================
    // VALIDAR RESPUESTA OSRM
    // ========================================================

    if (
      !datosOSRM ||
      datosOSRM.code !== 'Ok'
    ) {

      console.error(
        'Respuesta OSRM:',
        datosOSRM
      );


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
      !Array.isArray(
        datosOSRM.routes
      ) ||
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

    const ruta =
      datosOSRM.routes[0];


    // ========================================================
    // VALIDAR GEOMETRÍA
    // ========================================================

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
          'La ruta no contiene una geometría válida.'

      });

    }


    // ========================================================
    // CONSTRUIR PASOS DE NAVEGACIÓN
    // ========================================================

    const pasos =
      ruta.legs?.flatMap(
        leg =>
          leg.steps?.map(
            step => {

              return {

                distancia:
                  Number(
                    step.distance ?? 0
                  ),

                duracion:
                  Number(
                    step.duration ?? 0
                  ),

                nombre:
                  step.name ?? '',

                modo:
                  step.mode ?? '',

                maniobra:
                  step.maneuver ?? null

              };

            }
          ) ?? []
      ) ?? [];


    // ========================================================
    // WAYPOINTS
    // ========================================================

    const waypoints =
      datosOSRM.waypoints?.map(
        waypoint => {

          return {

            nombre:
              waypoint.name ?? '',

            ubicacion:
              waypoint.location ?? []

          };

        }
      ) ?? [];


    // ========================================================
    // RESPUESTA PARA FLUTTER
    // ========================================================

    return res.status(200).json({

      ok: true,

      mensaje:
        'Ruta calculada correctamente.',

      ruta: {

        // ----------------------------------------------------
        // DISTANCIA TOTAL
        // ----------------------------------------------------
        //
        // Metros.
        //
        distancia:
          Number(
            ruta.distance ?? 0
          ),


        // ----------------------------------------------------
        // DURACIÓN TOTAL
        // ----------------------------------------------------
        //
        // Segundos.
        //
        duracion:
          Number(
            ruta.duration ?? 0
          ),


        // ----------------------------------------------------
        // GEOMETRÍA REAL
        // ----------------------------------------------------
        //
        // Esta es la línea que Flutter dibujará.
        //
        // NO es una línea recta entre sitios.
        //
        // Sigue la red vial.
        //
        geometria:
          ruta.geometry,


        // ----------------------------------------------------
        // WAYPOINTS
        // ----------------------------------------------------

        waypoints,


        // ----------------------------------------------------
        // PASOS
        // ----------------------------------------------------

        pasos

      }

    });


  } catch (error) {

    console.error(
      '============================================'
    );

    console.error(
      '❌ ERROR CALCULANDO RUTA'
    );

    console.error(
      error
    );

    console.error(
      '============================================'
    );


    return res.status(500).json({

      ok: false,

      mensaje:
        'Error interno al calcular la ruta.',

      error:
        error.message

    });

  }

};


// ============================================================
// CONSULTAR OSRM
// ============================================================

function consultarOSRM(url) {

  return new Promise(
    (resolve, reject) => {

      const request =
        https.get(
          url,
          {

            headers: {

              'User-Agent':
                'Mi-Ruta-Magica-del-Cafe/1.0'

            }

          },

          response => {

            let data = '';


            // ==================================================
            // RECIBIR DATOS
            // ==================================================

            response.on(
              'data',
              chunk => {

                data += chunk;

              }
            );


            // ==================================================
            // FINALIZAR RESPUESTA
            // ==================================================

            response.on(
              'end',
              () => {

                if (
                  response.statusCode < 200 ||
                  response.statusCode >= 300
                ) {

                  return reject(
                    new Error(
                      `OSRM respondió HTTP ${response.statusCode}`
                    )
                  );

                }


                try {

                  const json =
                    JSON.parse(
                      data
                    );

                  resolve(
                    json
                  );

                } catch (error) {

                  reject(
                    new Error(
                      'OSRM devolvió una respuesta que no es JSON válida.'
                    )
                  );

                }

              }
            );

          }

        );


      // ========================================================
      // TIMEOUT
      // ========================================================

      request.setTimeout(
        60000,
        () => {

          request.destroy();

          reject(
            new Error(
              'Tiempo de espera agotado al consultar OSRM.'
            )
          );

        }
      );


      // ========================================================
      // ERROR DE CONEXIÓN
      // ========================================================

      request.on(
        'error',
        error => {

          reject(
            error
          );

        }
      );

    }
  );

}


// ============================================================
// EXPORTAR
// ============================================================

module.exports = {

  calcularRuta

};