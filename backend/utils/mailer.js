const {
  BrevoClient
} = require('@getbrevo/brevo');


// =====================================================
// CONFIGURACIÓN DE BREVO
// =====================================================

const brevo = new BrevoClient({
  apiKey: process.env.BREVO_API_KEY
});


// =====================================================
// ENVIAR CÓDIGO DE VERIFICACIÓN
// =====================================================

const enviarCodigoVerificacion = async (
  correo,
  nombre,
  codigo
) => {

  try {

    const resultado =
      await brevo.transactionalEmails.sendTransacEmail({

        subject:
          'Código de verificación - Mi Ruta Cafetera',

        sender: {
          name:
            process.env.BREVO_NOMBRE ||
            'Mi Ruta Cafetera',

          email:
            process.env.BREVO_EMAIL
        },

        to: [
          {
            email: correo,
            name: nombre
          }
        ],

        htmlContent: `

          <!DOCTYPE html>

          <html>

          <head>

            <meta charset="UTF-8">

            <title>
              Verificación de cuenta
            </title>

          </head>

          <body
            style="
              margin: 0;
              padding: 0;
              background-color: #f5f5f5;
              font-family: Arial, sans-serif;
            "
          >

            <div
              style="
                max-width: 550px;
                margin: 40px auto;
                background-color: #ffffff;
                padding: 35px;
                border-radius: 12px;
              "
            >

              <h2
                style="
                  text-align: center;
                  color: #4a2c11;
                "
              >
                ☕ Mi Ruta Cafetera
              </h2>

              <h3>
                ¡Hola ${nombre}!
              </h3>

              <p
                style="
                  color: #555555;
                  line-height: 1.6;
                "
              >
                Gracias por registrarte en
                <strong>Mi Ruta Cafetera</strong>.
              </p>

              <p
                style="
                  color: #555555;
                  line-height: 1.6;
                "
              >
                Para completar tu registro y
                verificar tu cuenta, utiliza
                el siguiente código:
              </p>

              <div
                style="
                  text-align: center;
                  margin: 30px 0;
                "
              >

                <span
                  style="
                    display: inline-block;
                    background-color: #f7f3ee;
                    color: #4a2c11;
                    padding: 15px 25px;
                    border-radius: 8px;
                    font-size: 28px;
                    font-weight: bold;
                    letter-spacing: 6px;
                  "
                >
                  ${codigo}
                </span>

              </div>

              <p
                style="
                  font-size: 14px;
                  color: #777777;
                "
              >
                Este código es válido durante
                <strong>10 minutos</strong>.
              </p>

              <p
                style="
                  font-size: 13px;
                  color: #999999;
                "
              >
                Si no creaste esta cuenta,
                puedes ignorar este mensaje.
              </p>

              <hr
                style="
                  border: none;
                  border-top: 1px solid #eeeeee;
                  margin: 30px 0;
                "
              >

              <p
                style="
                  text-align: center;
                  font-size: 12px;
                  color: #999999;
                "
              >
                Mi Ruta Cafetera
              </p>

            </div>

          </body>

          </html>

        `
      });


    console.log(
      '=========================================='
    );

    console.log(
      '📧 CORREO DE VERIFICACIÓN ENVIADO'
    );

    console.log(
      `📨 Destinatario: ${correo}`
    );

    console.log(
      `🆔 Message ID: ${resultado.messageId}`
    );

    console.log(
      '=========================================='
    );


    return resultado;

  } catch (error) {

    console.error(
      '=========================================='
    );

    console.error(
      '❌ ERROR AL ENVIAR CORREO DE VERIFICACIÓN'
    );

    console.error(
      error.message
    );

    console.error(
      '=========================================='
    );

    throw error;
  }
};


// =====================================================
// ENVIAR CÓDIGO DE RECUPERACIÓN
// =====================================================

const enviarCodigoRecuperacion = async (
  correo,
  nombre,
  codigo
) => {

  try {

    const resultado =
      await brevo.transactionalEmails.sendTransacEmail({

        subject:
          'Recuperación de contraseña - Mi Ruta Cafetera',

        sender: {
          name:
            process.env.BREVO_NOMBRE ||
            'Mi Ruta Cafetera',

          email:
            process.env.BREVO_EMAIL
        },

        to: [
          {
            email: correo,
            name: nombre
          }
        ],

        htmlContent: `

          <!DOCTYPE html>

          <html>

          <head>

            <meta charset="UTF-8">

            <title>
              Recuperación de contraseña
            </title>

          </head>

          <body
            style="
              margin: 0;
              padding: 0;
              background-color: #f5f5f5;
              font-family: Arial, sans-serif;
            "
          >

            <div
              style="
                max-width: 550px;
                margin: 40px auto;
                background-color: #ffffff;
                padding: 35px;
                border-radius: 12px;
              "
            >

              <h2
                style="
                  text-align: center;
                  color: #4a2c11;
                "
              >
                ☕ Mi Ruta Cafetera
              </h2>

              <h3>
                ¡Hola ${nombre}!
              </h3>

              <p
                style="
                  color: #555555;
                  line-height: 1.6;
                "
              >
                Recibimos una solicitud para
                recuperar la contraseña de tu cuenta.
              </p>

              <p
                style="
                  color: #555555;
                  line-height: 1.6;
                "
              >
                Tu código de recuperación es:
              </p>

              <div
                style="
                  text-align: center;
                  margin: 30px 0;
                "
              >

                <span
                  style="
                    display: inline-block;
                    background-color: #f7f3ee;
                    color: #4a2c11;
                    padding: 15px 25px;
                    border-radius: 8px;
                    font-size: 28px;
                    font-weight: bold;
                    letter-spacing: 6px;
                  "
                >
                  ${codigo}
                </span>

              </div>

              <p
                style="
                  font-size: 14px;
                  color: #777777;
                "
              >
                Este código es válido durante
                <strong>10 minutos</strong>.
              </p>

              <p
                style="
                  font-size: 13px;
                  color: #999999;
                "
              >
                Si no solicitaste recuperar tu
                contraseña, puedes ignorar este mensaje.
              </p>

              <hr
                style="
                  border: none;
                  border-top: 1px solid #eeeeee;
                  margin: 30px 0;
                "
              >

              <p
                style="
                  text-align: center;
                  font-size: 12px;
                  color: #999999;
                "
              >
                Mi Ruta Cafetera
              </p>

            </div>

          </body>

          </html>

        `
      });


    console.log(
      '=========================================='
    );

    console.log(
      '📧 CORREO DE RECUPERACIÓN ENVIADO'
    );

    console.log(
      `📨 Destinatario: ${correo}`
    );

    console.log(
      `🆔 Message ID: ${resultado.messageId}`
    );

    console.log(
      '=========================================='
    );


    return resultado;

  } catch (error) {

    console.error(
      '=========================================='
    );

    console.error(
      '❌ ERROR AL ENVIAR CORREO DE RECUPERACIÓN'
    );

    console.error(
      error.message
    );

    console.error(
      '=========================================='
    );

    throw error;
  }
};


// =====================================================
// EXPORTAR FUNCIONES
// =====================================================

module.exports = {

  enviarCodigoVerificacion,

  enviarCodigoRecuperacion

};