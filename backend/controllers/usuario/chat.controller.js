const Groq = require('groq-sdk');

const SitioTuristico = require(
  '../../models/admin/sitio'
);

// ======================================================
// CONFIGURACIÓN DE GROQ
// ======================================================

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY
});

// ======================================================
// CHAT CON GROQ
// ======================================================

const chatConGroq = async (req, res) => {
  try {
    const { mensaje } = req.body;

    // --------------------------------------------------
    // VALIDAR MENSAJE
    // --------------------------------------------------

    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({
        mensaje: 'Debes enviar un mensaje válido'
      });
    }

    // --------------------------------------------------
    // CONSULTAR SITIOS TURÍSTICOS
    // --------------------------------------------------

    const sitios = await SitioTuristico.find({
      activo: true
    })
      .populate('categoria')
      .lean();

    // --------------------------------------------------
    // CREAR CATÁLOGO PARA GROQ
    // --------------------------------------------------

    const catalogoTexto = sitios
      .map((sitio) => {
        const categoria =
          sitio.categoria?.nombre ||
          'Sin categoría';

        return `
Nombre: ${sitio.nombre}
Categoría: ${categoria}
Descripción: ${
  sitio.descripcion || 'Sin descripción'
}
Ciudad: ${
  sitio.ciudad || 'No disponible'
}
Dirección: ${
  sitio.direccion || 'No disponible'
}
Horario: ${
  sitio.horario || 'No disponible'
}
Precio desde: ${
  sitio.precioDesde || 0
}
`;
      })
      .join('\n');

    // --------------------------------------------------
    // PERSONALIDAD DEL ASISTENTE
    // --------------------------------------------------

    const systemPrompt = `
Eres el asistente virtual de Mi Ruta Mágica del Café ☕🌿.

Tu personalidad es cordial, amable, carismática,
cercana y alegre.

Hablas como un anfitrión que disfruta ayudar a las
personas a descubrir los encantos del Huila.

REGLAS:

1. PERSONALIDAD:
Sé cálido, natural y agradable.
Haz que el usuario se sienta bienvenido.
Puedes utilizar emojis de forma moderada ☕🌿📍.

2. SALUDOS:
Si el usuario saluda, responde de manera alegre
y cercana.

Ejemplo:
"¡Hola! ☕😊 Qué gusto tenerte por aquí.
Soy tu asistente de Mi Ruta Mágica del Café.
¿Qué lugar del Huila te gustaría descubrir hoy?"

3. RESPUESTAS:
Sé breve, claro y carismático.
No des explicaciones largas si no son necesarias.

4. SITIOS TURÍSTICOS:
Utiliza únicamente la información disponible
en el catálogo.

No inventes sitios, precios, horarios,
ubicaciones ni servicios.

5. RECOMENDACIONES:
Cuando el usuario pida una recomendación,
busca en el catálogo el sitio que mejor
se adapte a lo que está buscando.

6. RUTAS:
Si el usuario quiere conocer varios lugares,
puedes sugerir una ruta utilizando únicamente
sitios existentes en el catálogo.

7. INFORMACIÓN NO DISPONIBLE:
Si un dato no está registrado, dilo de manera
amable.

No inventes información.

8. CONVERSACIÓN:
Mantén un tono humano, cercano y positivo.

9. CONCISIÓN:
Prioriza respuestas de 1 a 4 frases.
Solo proporciona más información cuando
el usuario la solicite.

CATÁLOGO DE SITIOS TURÍSTICOS:

${catalogoTexto}
`;

    // --------------------------------------------------
    // CONSULTAR GROQ
    // --------------------------------------------------

    const completion =
      await groq.chat.completions.create({
        model: 'openai/gpt-oss-20b',

        messages: [
          {
            role: 'system',
            content: systemPrompt
          },
          {
            role: 'user',
            content: mensaje
          }
        ],

        temperature: 0.3,

        max_completion_tokens: 500,

        reasoning_effort: 'low',

        include_reasoning: false
      });

    // --------------------------------------------------
    // OBTENER RESPUESTA
    // --------------------------------------------------

    const respuestaTexto =
      completion.choices[0]?.message?.content?.trim();

    if (!respuestaTexto) {
      console.error(
        '⚠️ Groq no devolvió contenido:',
        completion.choices[0]?.message
      );

      return res.status(500).json({
        mensaje: 'Groq no devolvió una respuesta'
      });
    }

    // --------------------------------------------------
    // RESPONDER
    // --------------------------------------------------

    return res.status(200).json({
      respuesta: respuestaTexto
    });

  } catch (error) {
    console.error(
      '❌ Error en Groq Chat:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al procesar la respuesta del asistente',
      error: error.message
    });
  }
};

// ======================================================
// EXPORTAR
// ======================================================

module.exports = {
  chatConGroq
};