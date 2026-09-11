USE analisis_territorial;

-- ============================================================
-- VERIFICACIÓN DE CONTEOS GLOBALES NORMALIZADOS
-- ============================================================
SELECT 'REGIONES' AS Tabla, COUNT(*) AS Cantidad FROM Region
UNION ALL
SELECT 'DEPARTAMENTOS', COUNT(*) FROM Departamento
UNION ALL
SELECT 'MUNICIPIOS', COUNT(*) FROM Municipio;

-- ============================================================
-- CONSULTA DE MUNICIPIOS DUPLICADOS
-- ============================================================
SELECT 
    m.Nombre AS municipio,

    GROUP_CONCAT(
        DISTINCT d.Nombre
        ORDER BY d.Nombre
        SEPARATOR ', '
    ) AS departamentos,

    COUNT(*) AS cantidad

FROM municipio m

JOIN departamento d
    ON m.Id_departamento = d.Id_departamento

GROUP BY m.Nombre

HAVING COUNT(*) > 1

ORDER BY m.Nombre;
