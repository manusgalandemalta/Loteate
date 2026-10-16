-- ============================================================
-- LoteaTE+ — Renombrar lotes Balconada 4: B4 → UF
-- Pegar en: Supabase Dashboard → SQL Editor → New Query
-- EJECUTAR PRIMERO el SELECT para verificar los nombres actuales
-- ============================================================

-- 1. VER los nombres actuales antes de cambiar
SELECT id, lote FROM terrenos WHERE loteo_id = 3 ORDER BY lote;

-- ============================================================
-- 2. EJECUTAR el renombrado (correr DESPUÉS de verificar arriba)
--    Ajustar el prefijo si los lotes usan otro formato (ej: 'B4 ' con espacio)
-- ============================================================

BEGIN;

-- Terrenos
UPDATE terrenos
  SET lote = REPLACE(lote, 'B4', 'UF')
  WHERE loteo_id = 3 AND lote LIKE 'B4%';

-- Ventas (lote denormalizado)
UPDATE ventas
  SET lote = REPLACE(lote, 'B4', 'UF')
  WHERE loteo_id = 3 AND lote LIKE 'B4%';

-- Cobranzas (lote denormalizado)
UPDATE cobranzas
  SET lote = REPLACE(lote, 'B4', 'UF')
  WHERE loteo_id = 3 AND lote LIKE 'B4%';

-- Cuotas (lote denormalizado)
UPDATE cuotas
  SET lote = REPLACE(lote, 'B4', 'UF')
  WHERE loteo_id = 3 AND lote LIKE 'B4%';

COMMIT;

-- 3. VERIFICAR el resultado
SELECT id, lote FROM terrenos WHERE loteo_id = 3 ORDER BY lote;
