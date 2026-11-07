// Vercel Serverless Function: /api/chat
export default async function handler(req, res) {
  // Configuración de CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido. Usa POST.' });
  }

  const apiKey = process.env.GEMINI_API_KEY || req.body?.apiKey;
  if (!apiKey) {
    return res.status(500).json({
      error: 'Falta la clave GEMINI_API_KEY en las variables de entorno de Vercel.',
      hint: 'Configura GEMINI_API_KEY en Vercel > Settings > Environment Variables.'
    });
  }

  try {
    const { messages = [], currentDay = 1, todayChecks = {} } = req.body || {};

    const systemInstruction = `
Eres el Asistente Clínico Veterinario de Sultán, un canino en tratamiento médico intensivo domiciliario.
Médico tratante: Dr. José Marcano (Contacto directo: 0416-9957400).
Día actual del tratamiento: Día ${currentDay} de 21.

Protocolo farmacológico estricto que sigue Sultán:
1. Omeprazol: 1 tableta a las 08:00 AM en ayunas (protector gástrico previo al antibiótico).
2. Doxiciclina 100 mg: 2 cc (vía oral) a las 09:00 AM. REGLA DE ORO: Administrar SIEMPRE con comida y agua. NUNCA administrar con leche, queso ni antiácidos (el calcio quela el fármaco e impide su absorción). Debe completar estrictamente los 21 días continuos sin saltarse ninguna dosis.
3. Metrifol: 2 cc a las 10:00 AM (suplemento hepático y vitamínico con alimento).
4. Pentaviral: 5 cc a las 10:00 AM cada 24 horas.
5. Suero Subcutáneo: 20 cc cada 4 horas (00:00, 04:00, 08:00, 12:00, 16:00, 20:00 - 6 tomas diarias). Se aplica con aguja subcutánea en el lomo/nuca levantando la piel ("carpa"), aspirando primero para verificar que no salga sangre. Alternar siempre los puntos de punción.

Dieta permitida: Pechuga de pollo hervida sin sal ni condimentos, caldo de pollo desgrasado sin cebolla ni ajo, arroz blanco hervido suave, alimento medicado gastrointestinal húmedo, agua limpia fresca 24/7.
Dieta prohibida: Lácteos, huesos cocidos, embutidos, sal, comida condimentada, cebolla, ajo, uvas, chocolate.

Instrucciones para tus respuestas:
- Responde siempre de forma clara, tranquilizadora, directa y empática a la familia de Sultán.
- Usa listas con viñetas y negritas para facilitar la lectura en el celular.
- Si preguntan qué hacer ante un vómito de medicamento: Si ocurrió antes de 20 minutos de la toma, suele requerir reposición tras reposo gástrico, pero siempre recomienda confirmar con el Dr. Marcano si es recurrente.
- Si detectas señales de emergencia crítica (encías pálidas o blancas como porcelana, temperatura <37°C o >39.8°C, sangrado nasal o en heces, convulsiones, desmayo): Indicar inmediatamente llamar al Dr. José Marcano al 0416-9957400 o llevarlo a urgencias veterinarias.
- Firma o recuerda amablemente la supervisión del Dr. José Marcano cuando sea pertinente.
`.trim();

    // Formatear mensajes para la API de Gemini
    const contents = [];

    // Inyectar el historial de mensajes
    for (const msg of messages) {
      contents.push({
        role: msg.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: msg.content }]
      });
    }

    if (contents.length === 0) {
      return res.status(400).json({ error: 'No se enviaron mensajes.' });
    }

    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`;

    const payload = {
      system_instruction: {
        parts: [{ text: systemInstruction }]
      },
      contents: contents,
      generationConfig: {
        temperature: 0.3,
        maxOutputTokens: 1000,
      }
    };

    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error('Error de Gemini API:', errorData);
      return res.status(response.status).json({
        error: 'Error en la respuesta del modelo de IA',
        details: errorData
      });
    }

    const data = await response.json();
    const replyText = data.candidates?.[0]?.content?.parts?.[0]?.text || 'No se pudo generar respuesta.';

    return res.status(200).json({ reply: replyText });
  } catch (error) {
    console.error('Error interno en /api/chat:', error);
    return res.status(500).json({ error: 'Error interno del servidor', message: error.message });
  }
}
