-- ============================================================
-- LoteaTE+ — Limpiar cuotas duplicadas en Supabase
-- Pegar en: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- 1. VER cuotas duplicadas (mismo venta_id + nro)
SELECT venta_id, nro, lote, count(*) as cantidad, array_agg(id ORDER BY id) as ids
FROM cuotas
WHERE loteo_id = 3
GROUP BY venta_id, nro, lote
HAVING count(*) > 1
ORDER BY venta_id, nro;

-- ============================================================
-- 2. ELIMINAR duplicados conservando el registro de menor id
--    (correr DESPUÉS de verificar que el SELECT de arriba muestra duplicados)
-- ============================================================

DELETE FROM cuotas
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY venta_id, nro ORDER BY id ASC) AS rn
    FROM cuotas
    WHERE loteo_id = 3
  ) t
  WHERE rn > 1
);

-- 3. VERIFICAR que ya no hay duplicados
SELECT venta_id, nro, lote, count(*) as cantidad
FROM cuotas
WHERE loteo_id = 3
GROUP BY venta_id, nro, lote
HAVING count(*) > 1;
-- Si no devuelve filas, está limpio.
