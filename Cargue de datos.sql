USE analisis_territorial;

-- ============================================================
-- 1. CARGAR REGIONES
-- ============================================================

LOAD DATA LOCAL INFILE 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
IGNORE INTO TABLE Region
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @region,
    @cod_departamento,
    @departamento,
    @cod_municipio,
    @municipio
)
SET Nombre = TRIM(@region);

-- ============================================================
-- 2. ELIMINAR LAS DOS FILAS MAL INTERPRETADAS
-- ============================================================

DELETE FROM region
WHERE Nombre LIKE 'Región Caribe,88,%';

-- ============================================================
-- 3. CARGAR DEPARTAMENTOS
--    NOTA: el CSV trae el codigo DANE de departamento como numero
--    (ej. "5" en vez de "05") porque Excel elimina los ceros a la
--    izquierda al tratarlo como numero. Se normaliza aqui a 2
--    digitos con LPAD, sin modificar el CSV original.
--
--    NOTA 2: la base se crea con COLLATE utf8mb4_general_ci
--    ("Crear base de datos.sql"), pero MySQL 8.0 asigna a las
--    variables de sesion (@region, @cod_departamento, etc.) el
--    collation utf8mb4_0900_ai_ci por defecto. Comparar una
--    columna contra una variable con collations distintos lanza
--    "Illegal mix of collations". Por eso las subconsultas que
--    usan variables en el WHERE llevan COLLATE utf8mb4_general_ci
--    explicito, para forzar que ambos lados usen el mismo.
-- ============================================================

LOAD DATA LOCAL INFILE 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
IGNORE INTO TABLE departamento
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @region,
    @cod_departamento,
    @departamento,
    @cod_municipio,
    @municipio
)
SET
    Cod_DANE = LPAD(TRIM(@cod_departamento), 2, '0'),
    Nombre = TRIM(@departamento),
    Id_region = (
        SELECT Id_region
        FROM region
        WHERE Nombre = TRIM(@region) COLLATE utf8mb4_general_ci
        LIMIT 1
    );

SET GLOBAL local_infile = 1;

SET GLOBAL local_infile = ON;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
-- ============================================================
-- 4. CARGAR MUNICIPIOS
--    NOTA: el codigo DANE de municipio viene en el CSV como
--    "departamento.sufijo" (ej. "5.001", "13.188", "5.4"), donde
--    Excel tambien elimino los ceros finales del sufijo de 3
--    digitos al tratarlo como un numero decimal (5.4 en realidad
--    es 5.400). Se reconstruye el codigo real de 5 digitos:
--    - la parte antes del punto se rellena a 2 digitos por la
--      izquierda (LPAD) -> el departamento.
--    - la parte despues del punto se rellena a 3 digitos por la
--      derecha (RPAD) -> el sufijo del municipio, porque los
--      ceros que se perdieron eran los de la derecha.
--    Ejemplos verificados contra el codigo DANE real:
--      "5.001"  -> 05001 (Medellin)
--      "5.4"    -> 05400 (La Union, Antioquia)
--      "13.188" -> 13188 (Cicuco, Bolivar)
--      "23.67"  -> 23670 (San Andres de Sotavento, Cordoba)
-- ============================================================

LOAD DATA LOCAL INFILE 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
IGNORE INTO TABLE Municipio
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @region,
    @cod_departamento,
    @departamento,
    @cod_municipio,
    @municipio
)
SET
    Cod_DANE = CONCAT(
        LPAD(TRIM(SUBSTRING_INDEX(@cod_municipio, '.', 1)), 2, '0'),
        RPAD(
            CASE
                WHEN LOCATE('.', @cod_municipio) > 0
                    THEN SUBSTRING_INDEX(@cod_municipio, '.', -1)
                ELSE '0'
            END,
            3, '0'
        )
    ),
    Nombre = TRIM(@municipio),
    Id_departamento = (
        SELECT Id_departamento
        FROM Departamento
        WHERE Cod_DANE = LPAD(TRIM(@cod_departamento), 2, '0') COLLATE utf8mb4_general_ci
        LIMIT 1
    );

-- ============================================================
-- 5. SAN ANDRÉS (departamento)
-- ============================================================

INSERT IGNORE INTO departamento
    (Cod_DANE, Nombre, Id_region)
SELECT
    '88',
    'Archipiélago de San Andrés, Providencia y Santa Catalina',
    Id_region
FROM region
WHERE Nombre = 'Región Caribe'
LIMIT 1;

-- ============================================================
-- 6. PROVIDENCIA
--    (codigo DANE real 88564, sin el punto que traia el CSV)
-- ============================================================

INSERT IGNORE INTO municipio
    (Cod_DANE, Nombre, Id_departamento)
SELECT
    '88564',
    'Providencia',
    Id_departamento
FROM departamento
WHERE Cod_DANE = '88'
LIMIT 1;

-- ============================================================
-- 7. SAN ANDRÉS
--    (codigo DANE real 88001, sin el punto que traia el CSV)
-- ============================================================

INSERT IGNORE INTO municipio
    (Cod_DANE, Nombre, Id_departamento)
SELECT
    '88001',
    'San Andrés',
    Id_departamento
FROM departamento
WHERE Cod_DANE = '88'
LIMIT 1;

-- ============================================================
-- 8. VERIFICACIÓN
-- ============================================================

SELECT COUNT(*) AS regiones
FROM region;

SELECT COUNT(*) AS departamentos
FROM departamento;

SELECT COUNT(*) AS municipios
FROM municipio;
