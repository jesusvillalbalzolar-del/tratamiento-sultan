-- ==============================================================================
-- BASE DE DATOS SUPABASE: TRATAMIENTO SULTÁN (VETERINARIO)
-- ==============================================================================
-- Copia y pega este script completo en el SQL Editor de tu proyecto en Supabase.
-- Crea las tablas, índices, políticas de seguridad (RLS) y activa Realtime.

-- 1. Tabla de Configuración del Tratamiento
CREATE TABLE IF NOT EXISTS public.treatment_settings (
    id TEXT PRIMARY KEY DEFAULT 'sultan_main',
    patient_name TEXT NOT NULL DEFAULT 'Sultán',
    species TEXT DEFAULT 'Canino',
    doctor_name TEXT DEFAULT 'Dr. José Marcano',
    doctor_phone TEXT DEFAULT '0416-9957400',
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_days INT NOT NULL DEFAULT 21,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar configuración inicial por defecto si no existe
INSERT INTO public.treatment_settings (id, patient_name, doctor_name, doctor_phone, start_date, total_days)
VALUES ('sultan_main', 'Sultán', 'Dr. José Marcano', '0416-9957400', CURRENT_DATE, 21)
ON CONFLICT (id) DO NOTHING;

-- 2. Tabla de Registro de Tomas Administradas (Dose Logs)
CREATE TABLE IF NOT EXISTS public.dose_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dose_id TEXT NOT NULL,                  -- ej: 'sue-1', 'dox', 'ome'
    dose_name TEXT NOT NULL,                -- ej: 'Doxiciclina 100mg'
    log_date DATE NOT NULL,                 -- Fecha local ej: '2026-11-07'
    scheduled_time TEXT NOT NULL,           -- '09:00'
    taken_at TIMESTAMPTZ DEFAULT NOW(),     -- Hora exacta del check
    administered_by TEXT DEFAULT 'Familiar', -- Nombre de quien la administró
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(dose_id, log_date)               -- Evita duplicados en un mismo día
);

-- 3. Tabla de Días Completados (Seguimiento 21 Días)
CREATE TABLE IF NOT EXISTS public.completed_days (
    day_date DATE PRIMARY KEY,
    day_number INT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Tabla de Bitácora Clínica y Signos Vitales
CREATE TABLE IF NOT EXISTS public.clinical_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    appetite_score INT CHECK (appetite_score BETWEEN 1 AND 5), -- 1=Muy malo, 5=Excelente
    hydration_status TEXT,                   -- 'Normal', 'Leve deshidratación', 'Buena turgencia'
    mucous_membranes TEXT,                   -- 'Rosadas (Normal)', 'Pálidas (Alerta)', 'Rojizas'
    energy_level TEXT,                       -- 'Decaído', 'Moderado', 'Activo'
    temperature NUMERIC(4,1),                -- Temperatura rectal ej: 38.5
    vomit_or_diarrhea BOOLEAN DEFAULT FALSE,
    observations TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Tabla de Mensajes / Consultas con la IA Veterinaria
CREATE TABLE IF NOT EXISTS public.ai_chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- POLÍTICAS DE SEGURIDAD (Row Level Security - RLS)
-- Permite lectura y escritura con la clave anónima (anon public key)
-- ==============================================================================

ALTER TABLE public.treatment_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dose_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.completed_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_chat_messages ENABLE ROW LEVEL SECURITY;

-- Políticas para acceso público / anónimo para la app familiar
CREATE POLICY "Permitir todo a usuarios anon en treatment_settings" 
ON public.treatment_settings FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Permitir todo a usuarios anon en dose_logs" 
ON public.dose_logs FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Permitir todo a usuarios anon en completed_days" 
ON public.completed_days FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Permitir todo a usuarios anon en clinical_logs" 
ON public.clinical_logs FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Permitir todo a usuarios anon en ai_chat_messages" 
ON public.ai_chat_messages FOR ALL USING (true) WITH CHECK (true);

-- ==============================================================================
-- ACTIVACIÓN DE REALTIME (Sincronización instantánea entre celulares)
-- ==============================================================================
BEGIN;
  -- Agrega las tablas a la publicación de supabase_realtime
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE 
    public.treatment_settings,
    public.dose_logs, 
    public.completed_days,
    public.clinical_logs;
COMMIT;
