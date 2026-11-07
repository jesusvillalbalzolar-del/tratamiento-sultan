# 🐾 Tratamiento Sultán · Panel Médico, IA & Sincronización en la Nube

Aplicación médica y veterinaria especializada para el tratamiento intensivo de 21 días de **Sultán** (Doxiciclina, Metrifol, Pentaviral, Omeprazol y Suero Subcutáneo cada 4 horas), bajo la supervisión del **Dr. José Marcano** (`0416-9957400`).

---

## 🚀 ¿Qué se mejoró en el proyecto?

1. **Sincronización en Tiempo Real con Supabase**:
   - Múltiples familiares y cuidadores pueden abrir la web en sus teléfonos al mismo tiempo.
   - Cuando alguien marca una toma administrada, se actualiza al instante en todos los celulares conectados mediante **Supabase Realtime**.
   - Si no hay conexión o no has configurado Supabase aún, funciona **100% en modo local** sin perder datos.

2. **Asistente Clínico Veterinario con IA (Google Gemini)**:
   - Integrado en la pestaña **"Asistente IA"**.
   - Conoce todo el historial, peso, fármacos de Sultán y las reglas críticas (ej. prohibición de lácteos con la Doxiciclina, hidratación, técnica de inyección subcutánea en la nuca).
   - Botones rápidos: ¿Qué hacer si vomita?, ¿Cómo evaluar deshidratación con pliegue cutáneo?, etc.

3. **Bitácora Diaria & Generador de Reporte WhatsApp**:
   - Registro de apetito (1 a 5), nivel de hidratación, ánimo, temperatura y vómitos.
   - Botón directo de **"Reporte WhatsApp al Dr. José Marcano"**: genera un mensaje ordenado y formateado con las tomas cumplidas y el estado de Sultán para enviárselo al doctor con un solo toque.

4. **Despliegue Listo para Vercel**:
   - Backend Serverless seguro en `/api/chat.js` que protege tu clave de Gemini para que nadie te la robe en el frontend.

---

## 🗄️ Paso 1: Configurar Supabase

1. Entra a tu proyecto en [Supabase](https://supabase.com/).
2. En el menú lateral izquierdo, haz clic en **SQL Editor**.
3. Abre el archivo [`schema.sql`](schema.sql) que creamos en este proyecto, copia todo su contenido y pégalo en el editor de Supabase.
4. Presiona el botón verde **RUN**.
5. ¡Listo! Esto crea las tablas:
   - `treatment_settings`
   - `dose_logs` (con Realtime activado)
   - `completed_days`
   - `clinical_logs`
   - `ai_chat_messages`
6. Ve a **Project Settings > API** y copia:
   - **Project URL**
   - **anon public key**

Puedes ingresarlas directamente desde la aplicación web tocando el botón **"Nube"** en la barra superior.

---

## ⚡ Paso 2: Despliegue en Vercel

### Opción A: Desde la consola (Vercel CLI)
Si tienes `vercel` instalado:
```bash
vercel
```

### Opción B: Conectando tu repositorio de GitHub a Vercel
1. Sube esta carpeta a tu repositorio de GitHub.
2. En [vercel.com](https://vercel.com/), haz clic en **Add New... > Project** e importa el repositorio.
3. En **Settings > Environment Variables**, agrega las siguientes variables:
   - `GEMINI_API_KEY`: Tu clave de Google Gemini (puedes obtenerla gratis en [Google AI Studio](https://aistudio.google.com/)).
   - `SUPABASE_URL`: Tu URL de Supabase (opcional para el backend, el frontend la puede cargar directamente).
   - `SUPABASE_ANON_KEY`: Tu clave anon de Supabase.
4. Haz clic en **Deploy**.

---

## 📱 Instalar como App en el Celular (PWA)
En iPhone (Safari) o Android (Chrome):
- Toca **Compartir** o los **3 puntos de menú**.
- Selecciona **"Agregar a la pantalla de inicio"** (Add to Home Screen).
- Sultán aparecerá como una app nativa a pantalla completa con notificaciones y alarmas sonoras.
