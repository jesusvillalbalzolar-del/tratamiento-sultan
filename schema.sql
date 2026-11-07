-- ==============================================================================
-- BASE DE DATOS SUPABASE: TRATAMIENTO SULTÁN (VETERINARIO)
-- Tablas integradas en el proyecto SIGNE (con prefijo sultan_ para aislamiento total)
-- ==============================================================================

-- 1. Tabla de Configuración del Tratamiento
CREATE TABLE IF NOT EXISTS public.sultan_treatment_settings (
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

INSERT INTO public.sultan_treatment_settings (id, patient_name, doctor_name, doctor_phone, start_date, total_days)
VALUES ('sultan_main', 'Sultán', 'Dr. José Marcano', '0416-9957400', CURRENT_DATE, 21)
ON CONFLICT (id) DO NOTHING;

-- 2. Tabla de Registro de Tomas Administradas (Dose Logs)
CREATE TABLE IF NOT EXISTS public.sultan_dose_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dose_id TEXT NOT NULL,
    dose_name TEXT NOT NULL,
    log_date DATE NOT NULL,
    scheduled_time TEXT NOT NULL,
    taken_at TIMESTAMPTZ DEFAULT NOW(),
    administered_by TEXT DEFAULT 'Familiar',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(dose_id, log_date)
);

-- 3. Tabla de Días Completados
CREATE TABLE IF NOT EXISTS public.sultan_completed_days (
    day_date DATE PRIMARY KEY,
    day_number INT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Tabla de Bitácora Clínica y Signos Vitales
CREATE TABLE IF NOT EXISTS public.sultan_clinical_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    appetite_score INT CHECK (appetite_score BETWEEN 1 AND 5),
    hydration_status TEXT,
    mucous_membranes TEXT,
    energy_level TEXT,
    temperature NUMERIC(4,1),
    vomit_or_diarrhea BOOLEAN DEFAULT FALSE,
    observations TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(log_date)
);

-- 5. Tabla de Mensajes / Consultas con la IA
CREATE TABLE IF NOT EXISTS public.sultan_ai_chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.sultan_treatment_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sultan_dose_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sultan_completed_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sultan_clinical_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sultan_ai_chat_messages ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura/escritura anónima
DROP POLICY IF EXISTS "Permitir anon sultan_treatment_settings" ON public.sultan_treatment_settings;
CREATE POLICY "Permitir anon sultan_treatment_settings" ON public.sultan_treatment_settings FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir anon sultan_dose_logs" ON public.sultan_dose_logs;
CREATE POLICY "Permitir anon sultan_dose_logs" ON public.sultan_dose_logs FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir anon sultan_completed_days" ON public.sultan_completed_days;
CREATE POLICY "Permitir anon sultan_completed_days" ON public.sultan_completed_days FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir anon sultan_clinical_logs" ON public.sultan_clinical_logs;
CREATE POLICY "Permitir anon sultan_clinical_logs" ON public.sultan_clinical_logs FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir anon sultan_ai_chat_messages" ON public.sultan_ai_chat_messages;
CREATE POLICY "Permitir anon sultan_ai_chat_messages" ON public.sultan_ai_chat_messages FOR ALL USING (true) WITH CHECK (true);

-- Agregar a Realtime sin afectar otras publicaciones
ALTER PUBLICATION supabase_realtime ADD TABLE 
  public.sultan_treatment_settings,
  public.sultan_dose_logs, 
  public.sultan_completed_days,
  public.sultan_clinical_logs;
