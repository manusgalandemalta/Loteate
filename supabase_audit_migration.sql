-- ============================================================
-- LoteaTE+ — Migración Soft Delete + Audit Log
-- Pegar en: Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================================

-- 1. Columnas de soft delete en GASTOS
ALTER TABLE gastos
  ADD COLUMN IF NOT EXISTS deleted_at  timestamptz DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by  text        DEFAULT NULL;

-- 2. Columnas de soft delete en COBRANZAS
ALTER TABLE cobranzas
  ADD COLUMN IF NOT EXISTS deleted_at  timestamptz DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by  text        DEFAULT NULL;

-- 3. Columnas de soft delete en VENTAS
ALTER TABLE ventas
  ADD COLUMN IF NOT EXISTS deleted_at  timestamptz DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by  text        DEFAULT NULL;

-- 4. Tabla de auditoría
CREATE TABLE IF NOT EXISTS audit_log (
  id          bigserial    PRIMARY KEY,
  timestamp   timestamptz  NOT NULL DEFAULT now(),
  usuario     text         NOT NULL,
  accion      text         NOT NULL,   -- 'BORRO', 'EDITO', 'CREO'
  tabla       text         NOT NULL,   -- 'gastos', 'cobranzas', 'ventas'
  registro_id text,
  loteo_id    int,
  datos       jsonb                    -- snapshot del registro antes del cambio
);

-- 5. Habilitar RLS en audit_log (solo usuarios autenticados)
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated puede leer audit" ON audit_log;
CREATE POLICY "authenticated puede leer audit"
  ON audit_log FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "authenticated puede insertar audit" ON audit_log;
CREATE POLICY "authenticated puede insertar audit"
  ON audit_log FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 6. Índice para filtrar por loteo y fecha en el historial
CREATE INDEX IF NOT EXISTS idx_audit_log_loteo_ts
  ON audit_log (loteo_id, timestamp DESC);

-- ============================================================
-- LISTO. Verificar con:
-- SELECT column_name FROM information_schema.columns
--   WHERE table_name = 'gastos' AND column_name LIKE 'deleted%';
-- SELECT * FROM audit_log LIMIT 1;
-- ============================================================
